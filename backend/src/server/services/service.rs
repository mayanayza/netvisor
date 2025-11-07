use crate::server::{
    groups::{
        r#impl::{base::Group, types::GroupType},
        service::GroupService,
    },
    hosts::{
        r#impl::{base::Host, interfaces::Interface},
        service::HostService,
    },
    services::r#impl::{
        base::Service,
        bindings::Binding,
        patterns::{MatchConfidence, MatchDetails, MatchReason},
    },
    shared::{
        services::traits::CrudService,
        storage::{filter::EntityFilter, generic::GenericPostgresStorage, traits::Storage},
        types::entities::{EntitySource, EntitySourceDiscriminants},
    },
};
use anyhow::anyhow;
use anyhow::{Error, Result};
use async_trait::async_trait;
use futures::lock::Mutex;
use std::{
    collections::HashMap,
    sync::{Arc, OnceLock},
};
use strum::IntoDiscriminant;
use uuid::Uuid;

pub struct ServiceService {
    storage: Arc<GenericPostgresStorage<Service>>,
    host_service: OnceLock<Arc<HostService>>,
    group_service: Arc<GroupService>,
    group_update_lock: Arc<Mutex<()>>,
    service_locks: Arc<Mutex<HashMap<Uuid, Arc<Mutex<()>>>>>,
}

#[async_trait]
impl CrudService<Service> for ServiceService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Service>> {
        &self.storage
    }
}

impl ServiceService {
    pub fn new(
        storage: Arc<GenericPostgresStorage<Service>>,
        group_service: Arc<GroupService>,
    ) -> Self {
        Self {
            storage,
            group_service,
            host_service: OnceLock::new(),
            group_update_lock: Arc::new(Mutex::new(())),
            service_locks: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    async fn get_service_lock(&self, service_id: &Uuid) -> Arc<Mutex<()>> {
        let mut locks = self.service_locks.lock().await;
        locks
            .entry(*service_id)
            .or_insert_with(|| Arc::new(Mutex::new(())))
            .clone()
    }

    pub fn set_host_service(&self, host_service: Arc<HostService>) -> Result<(), Arc<HostService>> {
        self.host_service.set(host_service)
    }

    pub async fn create_service(&self, service: Service) -> Result<Service> {
        let lock = self.get_service_lock(&service.id).await;
        let _guard = lock.lock().await;

        let filter = EntityFilter::unfiltered().host_id(&service.base.host_id);
        let existing_services = self.get_all(filter).await?;

        let service_from_storage = match existing_services
            .into_iter()
            .find(|existing: &Service| *existing == service)
        {
            // If both are from discovery, or if they have the same ID but for some reason the create route is being used, upsert data
            Some(existing_service)
                if (service.base.source.discriminant()
                    == EntitySourceDiscriminants::DiscoveryWithMatch
                    && existing_service.base.source.discriminant()
                        == EntitySourceDiscriminants::DiscoveryWithMatch)
                    || service.id == existing_service.id =>
            {
                tracing::warn!(
                    "Duplicate service for {} found, {} - upserting discovery data...",
                    service,
                    existing_service,
                );
                self.upsert_service(existing_service, service).await?
            }
            _ => {
                self.storage.create(&service).await?;
                tracing::info!(
                    "Created service {} for host {}",
                    service,
                    service.base.host_id
                );
                tracing::debug!("Result: {:?}", service);
                service
            }
        };

        Ok(service_from_storage)
    }

    pub async fn upsert_service(
        &self,
        mut existing_service: Service,
        new_service_data: Service,
    ) -> Result<Service> {
        let mut binding_updates = 0;

        let lock = self.get_service_lock(&existing_service.id).await;
        let _guard = lock.lock().await;

        tracing::debug!(
            "Upserting new service data {:?} into {:?}",
            new_service_data,
            existing_service
        );

        for new_service_binding in &new_service_data.base.bindings {
            if !existing_service.base.bindings.contains(new_service_binding) {
                binding_updates += 1;
                existing_service.base.bindings.push(*new_service_binding);
            }
        }

        if let Some(virtualization) = &new_service_data.base.virtualization {
            existing_service.base.virtualization = Some(virtualization.clone())
        }

        existing_service.base.source = match (
            existing_service.base.source,
            new_service_data.base.source.clone(),
        ) {
            // Add latest discovery metadata to vec, update details to summarize what was discovered + highest confidence
            (
                EntitySource::DiscoveryWithMatch {
                    metadata: existing_service_metadata,
                    details: existing_service_details,
                },
                EntitySource::DiscoveryWithMatch {
                    metadata: new_service_metadata,
                    details: new_service_details,
                },
            ) => {
                let new_metadata = [
                    new_service_metadata.clone(),
                    existing_service_metadata.clone(),
                ]
                .concat();

                // Max confidence
                let confidence = existing_service_details
                    .confidence
                    .max(new_service_details.confidence);

                // If both matches are N/A, continue to use N/A reason string. If not, use whatever the non-N/A string is.
                // If somehow confidence changed, use the higher confidence string
                let reason_str = match (
                    &existing_service_details.confidence,
                    &new_service_details.confidence,
                ) {
                    (MatchConfidence::NotApplicable, MatchConfidence::NotApplicable) => {
                        existing_service_details.reason_string()
                    }
                    (_, MatchConfidence::NotApplicable) => new_service_details.reason_string(),
                    (MatchConfidence::NotApplicable, _) => existing_service_details.reason_string(),
                    (_, _) => {
                        if existing_service_details.confidence > new_service_details.confidence {
                            existing_service_details.reason_string()
                        } else {
                            new_service_details.reason_string()
                        }
                    }
                };

                let reason = match existing_service_details.reason {
                    // If data has already been upserted, just append to avoid a continuously nested structure
                    MatchReason::Container(_, reasons) if existing_service_metadata.len() > 1 => {
                        MatchReason::Container(
                            reason_str,
                            [vec![new_service_details.reason], reasons].concat(),
                        )
                    }
                    // Otherwise create a container
                    _ => MatchReason::Container(
                        reason_str,
                        vec![new_service_details.reason, existing_service_details.reason],
                    ),
                };

                EntitySource::DiscoveryWithMatch {
                    metadata: new_metadata,
                    details: MatchDetails { confidence, reason },
                }
            }

            // Less-likely scenario: new service data is upserted to a manually or system-created record
            (
                _,
                EntitySource::DiscoveryWithMatch {
                    metadata: new_service_metadata,
                    details: new_service_details,
                },
            ) => EntitySource::DiscoveryWithMatch {
                metadata: new_service_metadata,
                details: new_service_details,
            },

            // The following case shouldn't be possible since upsert only happens from discovered services, but cover with something reasonable just in case
            (existing_source, _) => existing_source,
        };

        self.storage.update(&mut existing_service).await?;

        let mut data = Vec::new();

        if binding_updates > 0 {
            data.push(format!("{} bindings", binding_updates))
        };

        if !data.is_empty() {
            tracing::info!(
                "Upserted service {} with new data: {}",
                existing_service,
                data.join(", ")
            );
            tracing::debug!("Result {:?}", existing_service);
        } else {
            tracing::info!(
                "No new information to upsert from service {} to service {}",
                new_service_data,
                existing_service,
            );
        }

        Ok(existing_service)
    }

    pub async fn update_service(&self, mut service: Service) -> Result<Service> {
        let lock = self.get_service_lock(&service.id).await;
        let _guard = lock.lock().await;

        tracing::debug!("Updating service: {:?}", service);

        let current_service = self
            .get_by_id(&service.id)
            .await?
            .ok_or_else(|| anyhow!("Could not find service"))?;

        self.update_group_service_bindings(&current_service, Some(&service))
            .await?;

        self.storage.update(&mut service).await?;
        tracing::info!(
            "Updated service {} for host {}",
            service,
            service.base.host_id
        );
        tracing::debug!("Result: {:?}", service);
        Ok(service)
    }

    async fn update_group_service_bindings(
        &self,
        current_service: &Service,
        updates: Option<&Service>,
    ) -> Result<(), Error> {
        tracing::debug!(
            "Updating group bindings referencing {:?}, with changes {:?}",
            current_service,
            updates
        );

        let filter = EntityFilter::unfiltered().network_ids(&[current_service.base.network_id]);
        let groups = self.group_service.get_all(filter).await?;

        let _guard = self.group_update_lock.lock().await;

        let current_service_binding_ids: Vec<Uuid> = current_service
            .base
            .bindings
            .iter()
            .map(|b| b.id())
            .collect();
        let updated_service_binding_ids: Vec<Uuid> = match updates {
            Some(updated_service) => updated_service
                .base
                .bindings
                .iter()
                .map(|b| b.id())
                .collect(),
            None => Vec::new(),
        };

        let groups_to_update: Vec<Group> = groups
            .into_iter()
            .filter_map(|mut group| match &mut group.base.group_type {
                GroupType::RequestPath { service_bindings }
                | GroupType::HubAndSpoke { service_bindings } => {
                    let initial_bindings_length = service_bindings.len();

                    service_bindings.retain(|sb| {
                        if current_service_binding_ids.contains(sb) {
                            return updated_service_binding_ids.contains(sb);
                        }
                        true
                    });

                    if service_bindings.len() != initial_bindings_length {
                        Some(group)
                    } else {
                        None
                    }
                }
            })
            .collect();

        // Execute updates sequentially
        for mut group in groups_to_update {
            self.group_service.update(&mut group).await?;
        }

        tracing::info!("Updated group bindings referencing {}", current_service);

        Ok(())
    }

    /// Update bindings to match ports and interfaces available on new host
    pub async fn reassign_service_interface_bindings(
        &self,
        service: Service,
        original_host: &Host,
        updated_host: &Host,
    ) -> Service {
        let lock = self.get_service_lock(&service.id).await;
        let _guard = lock.lock().await;

        tracing::debug!(
            "Preparing service {:?} for transfer from host {:?} to host {:?}",
            service,
            original_host,
            updated_host
        );

        let mut mutable_service = service.clone();

        mutable_service.base.bindings = mutable_service
            .base
            .bindings
            .iter_mut()
            .filter_map(|mut b| {
                let original_interface = original_host.get_interface(&b.interface_id());

                match &mut b {
                    Binding::Interface { interface_id, .. } => {
                        if let Some(original_interface) = original_interface {
                            let new_interface: Option<&Interface> = updated_host
                                .base
                                .interfaces
                                .iter()
                                .find(|i| *i == original_interface);

                            if let Some(new_interface) = new_interface {
                                *interface_id = new_interface.id;
                                return Some(*b);
                            }
                        }
                        // this shouldn't happen because we just transferred bindings from old host to new
                        None::<Binding>
                    }
                    Binding::Port {
                        port_id,
                        interface_id,
                        ..
                    } => {
                        if let Some(original_port) = original_host.get_port(port_id)
                            && let Some(new_port) =
                                updated_host.base.ports.iter().find(|p| *p == original_port)
                        {
                            let new_interface: Option<Option<Interface>> = match original_interface
                            {
                                // None interface = listen on all interfaces, assume same for new host
                                None => Some(None),
                                Some(original_interface) => updated_host
                                    .base
                                    .interfaces
                                    .iter()
                                    .find(|i| *i == original_interface)
                                    .map(|found_interface| Some(found_interface.clone())),
                            };

                            match new_interface {
                                None => return None,
                                Some(new_interface) => {
                                    *port_id = new_port.id;
                                    *interface_id = match new_interface {
                                        Some(new_interface) => Some(new_interface.id),
                                        None => None,
                                    };
                                    return Some(*b);
                                }
                            }
                        }
                        // this shouldn't happen because we just transferred bindings from old host to new
                        None::<Binding>
                    }
                };

                None
            })
            .collect();

        mutable_service.base.host_id = updated_host.id;

        mutable_service.base.network_id = updated_host.base.network_id;

        tracing::debug!(
            "Reassigned service {:?} bindings for from host {:?} to host {:?}",
            mutable_service,
            original_host,
            updated_host
        );

        mutable_service
    }

    pub async fn delete_service(&self, id: &Uuid) -> Result<()> {
        let lock = self.get_service_lock(id).await;
        let _guard = lock.lock().await;

        let service = self
            .get_by_id(id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Service {} not found", id))?;

        self.update_group_service_bindings(&service, None).await?;

        self.storage.delete(id).await?;
        tracing::info!(
            "Deleted service {}: {} for host {}",
            service.base.name,
            service.id,
            service.base.host_id
        );
        Ok(())
    }
}
