use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    bindings::r#impl::base::{Binding, BindingType},
    groups::{r#impl::base::Group, service::GroupService},
    hosts::{r#impl::base::Host, service::HostService},
    interfaces::r#impl::base::Interface,
    ports::r#impl::base::Port,
    services::r#impl::{base::Service, patterns::MatchDetails},
    shared::{
        entities::ChangeTriggersTopologyStaleness,
        events::{
            bus::EventBus,
            types::{EntityEvent, EntityOperation},
        },
        services::traits::{ChildCrudService, CrudService, EventBusService},
        storage::{
            child::GenericChildStorage,
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
    binding_storage: Arc<GenericChildStorage<Binding>>,
    host_service: OnceLock<Arc<HostService>>,
    group_service: Arc<GroupService>,
    group_update_lock: Arc<Mutex<()>>,
    service_locks: Arc<Mutex<HashMap<Uuid, Arc<Mutex<()>>>>>,
    event_bus: Arc<EventBus>,
}

impl EventBusService<Service> for ServiceService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, entity: &Service) -> Option<Uuid> {
        Some(entity.base.network_id)
    }
    fn get_organization_id(&self, _entity: &Service) -> Option<Uuid> {
        None
    }
}

#[async_trait]
impl CrudService<Service> for ServiceService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Service>> {
        &self.storage
    }

    async fn get_by_id(&self, id: &Uuid) -> Result<Option<Service>, anyhow::Error> {
        let service = self.storage().get_by_id(id).await?;
        match service {
            Some(mut s) => {
                s.base.bindings = self.binding_storage.get_for_parent(&s.id).await?;
                Ok(Some(s))
            }
            None => Ok(None),
        }
    }

    async fn get_all(&self, filter: EntityFilter) -> Result<Vec<Service>, anyhow::Error> {
        let mut services = self.storage().get_all(filter).await?;
        if services.is_empty() {
            return Ok(services);
        }

        let service_ids: Vec<Uuid> = services.iter().map(|s| s.id).collect();
        let bindings_map = self.binding_storage.get_for_parents(&service_ids).await?;

        for service in &mut services {
            if let Some(bindings) = bindings_map.get(&service.id) {
                service.base.bindings = bindings.clone();
            }
        }

        Ok(services)
    }

    async fn get_one(&self, filter: EntityFilter) -> Result<Option<Service>, anyhow::Error> {
        let service = self.storage().get_one(filter).await?;
        match service {
            Some(mut s) => {
                s.base.bindings = self.binding_storage.get_for_parent(&s.id).await?;
                Ok(Some(s))
            }
            None => Ok(None),
        }
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
                    service = %service,
                    existing_service = %existing_service,
                    "Duplicate service found, upserting discovery data...",
                );
                self.upsert_service(existing_service, service, authentication)
                    .await?
            }
            _ => {
                let created = self.storage.create(&service).await?;

                // Save bindings to separate table with correct service_id and network_id
                let bindings_with_ids: Vec<Binding> = service
                    .base
                    .bindings
                    .iter()
                    .cloned()
                    .map(|b| b.with_service(created.id, created.base.network_id))
                    .collect();
                self.binding_storage
                    .save_for_parent(&created.id, &bindings_with_ids)
                    .await?;

                let trigger_stale = created.triggers_staleness(None);

                self.event_bus()
                    .publish_entity(EntityEvent {
                        id: Uuid::new_v4(),
                        entity_id: created.id,
                        network_id: self.get_network_id(&created),
                        organization_id: self.get_organization_id(&created),
                        entity_type: created.into(),
                        operation: EntityOperation::Created,
                        timestamp: Utc::now(),
                        metadata: serde_json::json!({
                            "trigger_stale": trigger_stale
                        }),
                        authentication,
                    })
                    .await?;

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

        // Save bindings to separate table with correct service_id and network_id
        let bindings_with_ids: Vec<Binding> = service
            .base
            .bindings
            .iter()
            .cloned()
            .map(|b| b.with_service(updated.id, updated.base.network_id))
            .collect();
        self.binding_storage
            .save_for_parent(&updated.id, &bindings_with_ids)
            .await?;

        let trigger_stale = updated.triggers_staleness(Some(current_service));

        self.event_bus()
            .publish_entity(EntityEvent {
                id: Uuid::new_v4(),
                entity_id: updated.id,
                network_id: self.get_network_id(&updated),
                organization_id: self.get_organization_id(&updated),
                entity_type: updated.clone().into(),
                operation: EntityOperation::Updated,
                timestamp: Utc::now(),
                metadata: serde_json::json!({
                    "trigger_stale": trigger_stale
                }),
                authentication,
            })
            .await?;

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

        let trigger_stale = service.triggers_staleness(None);

        self.event_bus()
            .publish_entity(EntityEvent {
                id: Uuid::new_v4(),
                entity_id: service.id,
                network_id: self.get_network_id(&service),
                organization_id: self.get_organization_id(&service),
                entity_type: service.into(),
                operation: EntityOperation::Deleted,
                timestamp: Utc::now(),
                metadata: serde_json::json!({
                    "trigger_stale": trigger_stale
                }),
                authentication,
            })
            .await?;
        Ok(())
    }
}

impl ChildCrudService<Service> for ServiceService {}

impl ServiceService {
    pub fn new(
        storage: Arc<GenericPostgresStorage<Service>>,
        binding_storage: Arc<GenericChildStorage<Binding>>,
        group_service: Arc<GroupService>,
        event_bus: Arc<EventBus>,
    ) -> Self {
        Self {
            storage,
            binding_storage,
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

        let service_before_updates = existing_service.clone();

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

        // Save bindings to separate table with correct service_id and network_id
        let bindings_with_ids: Vec<Binding> = existing_service
            .base
            .bindings
            .iter()
            .cloned()
            .map(|b| b.with_service(existing_service.id, existing_service.base.network_id))
            .collect();
        self.binding_storage
            .save_for_parent(&existing_service.id, &bindings_with_ids)
            .await?;

        let mut data = Vec::new();

        if binding_updates > 0 {
            data.push(format!("{} bindings", binding_updates))
        };

        if !data.is_empty() {
            let trigger_stale = existing_service.triggers_staleness(Some(service_before_updates));

            self.event_bus()
                .publish_entity(EntityEvent {
                    id: Uuid::new_v4(),
                    entity_id: existing_service.id,
                    network_id: self.get_network_id(&existing_service),
                    organization_id: self.get_organization_id(&existing_service),
                    entity_type: existing_service.clone().into(),
                    operation: EntityOperation::Updated,
                    timestamp: Utc::now(),
                    metadata: serde_json::json!({
                        "trigger_stale": trigger_stale
                    }),
                    authentication,
                })
                .await?;
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
            .filter_map(|mut group| {
                let initial_bindings_length = group.base.binding_ids.len();

                group.base.binding_ids.retain(|sb| {
                    if current_service_binding_ids.contains(sb) {
                        return updated_service_binding_ids.contains(sb);
                    }
                    true
                });

                if group.base.binding_ids.len() != initial_bindings_length {
                    Some(group)
                } else {
                    None
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
    /// `original_interfaces` and `updated_interfaces` are the interfaces for the respective hosts
    /// `original_ports` and `updated_ports` are the ports for the respective hosts
    #[allow(clippy::too_many_arguments)]
    pub async fn reassign_service_interface_bindings(
        &self,
        service: Service,
        original_host: &Host,
        original_interfaces: &[Interface],
        original_ports: &[Port],
        updated_host: &Host,
        updated_interfaces: &[Interface],
        updated_ports: &[Port],
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
            .filter_map(|b| {
                // Look up original interface from the provided slice
                let original_interface = b
                    .interface_id()
                    .and_then(|id| original_interfaces.iter().find(|i| i.id == id));

                match &mut b.base.binding_type {
                    BindingType::Interface { interface_id } => {
                        if let Some(original_interface) = original_interface {
                            let new_interface: Option<&Interface> =
                                updated_interfaces.iter().find(|i| *i == original_interface);

                            if let Some(new_interface) = new_interface {
                                *interface_id = new_interface.id;
                                return Some(*b);
                            }
                        }
                        // this shouldn't happen because we just transferred bindings from old host to new
                        None::<Binding>
                    }
                    BindingType::Port {
                        port_id,
                        interface_id,
                    } => {
                        if let Some(original_port) =
                            original_ports.iter().find(|p| p.id == *port_id)
                            && let Some(new_port) =
                                updated_ports.iter().find(|p| *p == original_port)
                        {
                            let new_interface: Option<Option<Interface>> = match original_interface
                            {
                                // None interface = listen on all interfaces, assume same for new host
                                None => Some(None),
                                Some(original_interface) => updated_interfaces
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
