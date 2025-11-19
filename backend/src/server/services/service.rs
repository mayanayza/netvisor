use crate::server::{
    auth::middleware::AuthenticatedEntity,
    groups::{
        r#impl::{base::Group, types::GroupType},
        service::GroupService,
    },
    hosts::{
        r#impl::{base::Host, interfaces::Interface},
        service::HostService,
    },
    services::r#impl::{base::Service, bindings::Binding, patterns::MatchDetails},
    shared::{
        entities::Entity,
        events::{
            bus::EventBus,
            types::{EntityEvent, EntityOperation},
        },
        services::traits::CrudService,
        storage::{
            filter::EntityFilter,
            generic::GenericPostgresStorage,
            traits::{StorableEntity, Storage},
        },
        types::entities::{EntitySource, EntitySourceDiscriminants},
    },
};
use anyhow::anyhow;
use anyhow::{Error, Result};
use async_trait::async_trait;
use chrono::Utc;
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
    event_bus: Arc<EventBus>,
}

#[async_trait]
impl CrudService<Service> for ServiceService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Service>> {
        &self.storage
    }

    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn entity_type() -> Entity {
        Entity::Service
    }
    fn get_network_id(&self, entity: &Service) -> Option<Uuid> {
        Some(entity.base.network_id)
    }
    fn get_organization_id(&self, _entity: &Service) -> Option<Uuid> {
        None
    }

    async fn create(
        &self,
        service: Service,
        authentication: AuthenticatedEntity,
    ) -> Result<Service> {
        let service = if service.id == Uuid::nil() {
            Service::new(service.base)
        } else {
            service
        };

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
                self.upsert_service(existing_service, service, authentication)
                    .await?
            }
            _ => {
                let created = self.storage.create(&service).await?;

                self.event_bus()
                    .publish(EntityEvent {
                        id: Uuid::new_v4(),
                        entity_type: Entity::Service,
                        entity_id: created.id,
                        network_id: self.get_network_id(&created),
                        organization_id: self.get_organization_id(&created),
                        operation: EntityOperation::Created,
                        timestamp: Utc::now(),
                        metadata: serde_json::json!({}),
                        authentication,
                    })
                    .await?;

                tracing::info!(
                    service_id = %service.id,
                    service_name = %service.base.name,
                    host_id = %service.base.host_id,
                    binding_count = %service.base.bindings.len(),
                    "Service created"
                );
                tracing::trace!("Result: {:?}", service);
                service
            }
        };

        Ok(service_from_storage)
    }

    async fn update(
        &self,
        service: &mut Service,
        authentication: AuthenticatedEntity,
    ) -> Result<Service> {
        let lock = self.get_service_lock(&service.id).await;
        let _guard = lock.lock().await;

        tracing::trace!("Updating service: {:?}", service);

        let current_service = self
            .get_by_id(&service.id)
            .await?
            .ok_or_else(|| anyhow!("Could not find service"))?;

        self.update_group_service_bindings(&current_service, Some(service), authentication.clone())
            .await?;

        let updated = self.storage.update(service).await?;

        self.event_bus()
            .publish(EntityEvent {
                id: Uuid::new_v4(),
                entity_type: Entity::Service,
                entity_id: updated.id,
                network_id: self.get_network_id(&updated),
                organization_id: self.get_organization_id(&updated),
                operation: EntityOperation::Updated,
                timestamp: Utc::now(),
                metadata: serde_json::json!({}),
                authentication,
            })
            .await?;

        tracing::info!(
            service_id = %service.id,
            service_name = %service.base.name,
            host_id = %service.base.host_id,
            "Service updated"
        );
        tracing::trace!("Result: {:?}", service);
        Ok(updated)
    }

    async fn delete(&self, id: &Uuid, authentication: AuthenticatedEntity) -> Result<()> {
        let lock = self.get_service_lock(id).await;
        let _guard = lock.lock().await;

        let service = self
            .get_by_id(id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Service {} not found", id))?;

        self.update_group_service_bindings(&service, None, authentication.clone())
            .await?;

        self.storage.delete(id).await?;

        self.event_bus()
            .publish(EntityEvent {
                id: Uuid::new_v4(),
                entity_type: Entity::Service,
                entity_id: service.id,
                network_id: self.get_network_id(&service),
                organization_id: self.get_organization_id(&service),
                operation: EntityOperation::Deleted,
                timestamp: Utc::now(),
                metadata: serde_json::json!({}),
                authentication,
            })
            .await?;

        tracing::info!(
            "Deleted service {}: {} for host {}",
            service.base.name,
            service.id,
            service.base.host_id
        );
        Ok(())
    }
}

impl ServiceService {
    pub fn new(
        storage: Arc<GenericPostgresStorage<Service>>,
        group_service: Arc<GroupService>,
        event_bus: Arc<EventBus>,
    ) -> Self {
        Self {
            storage,
            group_service,
            host_service: OnceLock::new(),
            group_update_lock: Arc::new(Mutex::new(())),
            service_locks: Arc::new(Mutex::new(HashMap::new())),
            event_bus,
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

    pub async fn upsert_service(
        &self,
        mut existing_service: Service,
        new_service_data: Service,
        authentication: AuthenticatedEntity,
    ) -> Result<Service> {
        let mut binding_updates = 0;

        let lock = self.get_service_lock(&existing_service.id).await;
        let _guard = lock.lock().await;

        tracing::trace!(
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

                let reason = if new_service_details.confidence > existing_service_details.confidence
                {
                    new_service_details.reason // Use the better match reason
                } else {
                    existing_service_details.reason // Keep existing reason
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
            self.event_bus()
                .publish(EntityEvent {
                    id: Uuid::new_v4(),
                    entity_type: Entity::Service,
                    entity_id: existing_service.id,
                    network_id: self.get_network_id(&existing_service),
                    organization_id: self.get_organization_id(&existing_service),
                    operation: EntityOperation::Updated,
                    timestamp: Utc::now(),
                    metadata: serde_json::json!({}),
                    authentication,
                })
                .await?;

            tracing::info!(
                service_id = %existing_service.id,
                service_name = %existing_service.base.name,
                updates = %data.join(", "),
                "Upserted service with new data"
            );
            tracing::debug!("Result {:?}", existing_service);
        } else {
            tracing::debug!(
                "Service upsert - no changes needed for {}",
                existing_service
            );
        }

        Ok(existing_service)
    }

    async fn update_group_service_bindings(
        &self,
        current_service: &Service,
        updates: Option<&Service>,
        authenticated: AuthenticatedEntity,
    ) -> Result<(), Error> {
        tracing::trace!(
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

        if !groups_to_update.is_empty() {
            // Execute updates sequentially
            for mut group in groups_to_update {
                self.group_service
                    .update(&mut group, authenticated.clone())
                    .await?;
            }
            tracing::info!(
                service = %current_service,
                "Updated group bindings"
            );
        }

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

        tracing::trace!(
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

        tracing::info!(
            service = %mutable_service,
            origin_host = %original_host,
            destination_host = %updated_host,
            "Reassigned service bindings",
        );

        tracing::trace!(
            "Reassigned service {:?} bindings for from host {:?} to host {:?}",
            mutable_service,
            original_host,
            updated_host
        );

        mutable_service
    }
}
