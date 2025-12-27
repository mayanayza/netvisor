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
        types::{
            api::ValidationError,
            entities::{EntitySource, EntitySourceDiscriminants},
        },
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
        let mut service = if service.id == Uuid::nil() {
            Service::new(service.base)
        } else {
            service
        };

        // Deduplicate bindings before validation
        service.base.bindings = Self::deduplicate_bindings(service.base.bindings);

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
                // Validate bindings don't conflict with each other before creating
                Self::validate_bindings_no_conflicts(&service.base.bindings)?;

                // Validate bindings reference ports/interfaces on the service's host
                self.validate_bindings_belong_to_host(
                    &service.base.host_id,
                    &service.base.bindings,
                )
                .await?;

                let mut created = self.storage.create(&service).await?;

                // Save bindings to separate table with correct service_id and network_id
                let bindings_with_ids: Vec<Binding> = service
                    .base
                    .bindings
                    .iter()
                    .cloned()
                    .map(|b| b.with_service(created.id, created.base.network_id))
                    .collect();
                let saved_bindings = self
                    .binding_storage
                    .save_for_parent(&created.id, &bindings_with_ids)
                    .await?;

                // Update service with the saved bindings (which have actual IDs)
                created.base.bindings = saved_bindings;

                let trigger_stale = created.triggers_staleness(None);

                self.event_bus()
                    .publish_entity(EntityEvent {
                        id: Uuid::new_v4(),
                        entity_id: created.id,
                        network_id: self.get_network_id(&created),
                        organization_id: self.get_organization_id(&created),
                        entity_type: created.clone().into(),
                        operation: EntityOperation::Created,
                        timestamp: Utc::now(),
                        metadata: serde_json::json!({
                            "trigger_stale": trigger_stale
                        }),
                        authentication,
                    })
                    .await?;

                created
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

        // Deduplicate bindings before validation
        service.base.bindings =
            Self::deduplicate_bindings(std::mem::take(&mut service.base.bindings));

        // Validate bindings don't conflict with each other
        Self::validate_bindings_no_conflicts(&service.base.bindings)?;

        // Validate bindings reference ports/interfaces on the service's host
        self.validate_bindings_belong_to_host(&service.base.host_id, &service.base.bindings)
            .await?;

        self.update_group_service_bindings(&current_service, Some(service), authentication.clone())
            .await?;

        let mut updated = self.storage.update(service).await?;

        // Save bindings to separate table with correct service_id and network_id
        let bindings_with_ids: Vec<Binding> = service
            .base
            .bindings
            .iter()
            .cloned()
            .map(|b| b.with_service(updated.id, updated.base.network_id))
            .collect();
        let saved_bindings = self
            .binding_storage
            .save_for_parent(&updated.id, &bindings_with_ids)
            .await?;

        // Update service with the saved bindings (which have actual IDs and preserved created_at)
        updated.base.bindings = saved_bindings;

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

    /// Validate that all bindings reference ports/interfaces that belong to the service's host.
    /// Returns Ok(()) if all bindings are valid, Err with ValidationError if any are invalid.
    async fn validate_bindings_belong_to_host(
        &self,
        host_id: &Uuid,
        bindings: &[Binding],
    ) -> Result<()> {
        if bindings.is_empty() {
            return Ok(());
        }

        let host_service = self
            .host_service
            .get()
            .expect("host_service not initialized");

        // Get all ports and interfaces for this host
        let host_ports = host_service.get_ports_for_host(host_id).await?;
        let host_interfaces = host_service.get_interfaces_for_host(host_id).await?;

        let valid_port_ids: std::collections::HashSet<Uuid> =
            host_ports.iter().map(|p| p.id).collect();
        let valid_interface_ids: std::collections::HashSet<Uuid> =
            host_interfaces.iter().map(|i| i.id).collect();

        for binding in bindings {
            match &binding.base.binding_type {
                BindingType::Interface { interface_id } => {
                    if !valid_interface_ids.contains(interface_id) {
                        return Err(ValidationError::new(format!(
                            "Interface binding references interface {} which does not belong to this host",
                            interface_id
                        )).into());
                    }
                }
                BindingType::Port {
                    port_id,
                    interface_id,
                } => {
                    if !valid_port_ids.contains(port_id) {
                        return Err(ValidationError::new(format!(
                            "Port binding references port {} which does not belong to this host",
                            port_id
                        ))
                        .into());
                    }
                    if let Some(iface_id) = interface_id
                        && !valid_interface_ids.contains(iface_id)
                    {
                        return Err(ValidationError::new(format!(
                                "Port binding references interface {} which does not belong to this host",
                                iface_id
                            )).into());
                    }
                }
            }
        }

        Ok(())
    }

    /// Check if a new binding is already covered by existing bindings.
    /// A Port binding with a specific interface is covered if there's already
    /// a Port binding for the same port with interface_id = None (all interfaces).
    fn is_binding_covered_by_existing(
        new_binding: &Binding,
        existing_bindings: &[Binding],
    ) -> bool {
        match &new_binding.base.binding_type {
            // A Port binding with a specific interface is covered by an "all interfaces" binding for the same port
            BindingType::Port {
                port_id,
                interface_id: Some(_),
            } => existing_bindings.iter().any(|existing| {
                matches!(
                    &existing.base.binding_type,
                    BindingType::Port {
                        port_id: existing_port_id,
                        interface_id: None,
                    } if existing_port_id == port_id
                )
            }),
            // Other binding types are not covered by anything else
            _ => false,
        }
    }

    /// Validates that a binding doesn't conflict with existing bindings.
    /// Rules:
    /// - Interface binding conflicts with port bindings on same interface OR port bindings on all interfaces
    /// - Port binding (specific interface) conflicts with interface binding on same interface
    /// - Port binding (all interfaces) conflicts with ANY interface binding
    ///
    /// Returns None if valid, Some(error_message) if conflict found.
    fn validate_binding_no_conflict(
        new_binding: &BindingType,
        existing_bindings: &[Binding],
    ) -> Option<&'static str> {
        match new_binding {
            BindingType::Interface { interface_id } => {
                // Check for conflicting port bindings: same interface OR all-interfaces
                for existing in existing_bindings {
                    if let BindingType::Port {
                        interface_id: existing_iface,
                        ..
                    } = &existing.base.binding_type
                        && (*existing_iface == Some(*interface_id) || existing_iface.is_none())
                    {
                        return Some(
                            "Cannot add interface binding: service already has a port binding on this interface (or on all interfaces).",
                        );
                    }
                }
            }
            BindingType::Port {
                interface_id: Some(interface_id),
                ..
            } => {
                // Check for conflicting interface binding on same interface
                for existing in existing_bindings {
                    if let BindingType::Interface {
                        interface_id: existing_iface,
                    } = &existing.base.binding_type
                        && existing_iface == interface_id
                    {
                        return Some(
                            "Cannot add port binding: service already has an interface binding on this interface.",
                        );
                    }
                }
            }
            BindingType::Port {
                interface_id: None, ..
            } => {
                // Port binding on all interfaces: conflicts with ANY interface binding
                for existing in existing_bindings {
                    if matches!(existing.base.binding_type, BindingType::Interface { .. }) {
                        return Some(
                            "Cannot add port binding on all interfaces: service already has interface bindings.",
                        );
                    }
                }
            }
        }
        None
    }

    /// Deduplicate bindings in a list.
    /// - Removes exact duplicates (same binding_type)
    /// - When an all-interfaces port binding is present, removes specific-interface bindings for the same port
    fn deduplicate_bindings(bindings: Vec<Binding>) -> Vec<Binding> {
        use std::collections::HashSet;

        // First, collect all port_ids that have all-interfaces bindings
        let all_interface_port_ids: HashSet<Uuid> = bindings
            .iter()
            .filter_map(|b| {
                if let BindingType::Port {
                    port_id,
                    interface_id: None,
                } = &b.base.binding_type
                {
                    Some(*port_id)
                } else {
                    None
                }
            })
            .collect();

        // Track seen binding types for deduplication
        let mut seen_binding_types: HashSet<String> = HashSet::new();
        let mut result = Vec::new();

        for binding in bindings {
            // Skip specific-interface port bindings when an all-interfaces binding exists for the same port
            if let BindingType::Port {
                port_id,
                interface_id: Some(_),
            } = &binding.base.binding_type
                && all_interface_port_ids.contains(port_id)
            {
                tracing::debug!(
                    port_id = %port_id,
                    "Deduplicating specific-interface binding superseded by all-interfaces binding"
                );
                continue;
            }

            // Create a key for deduplication based on binding type
            let key = format!("{:?}", binding.base.binding_type);
            if seen_binding_types.contains(&key) {
                tracing::debug!(
                    binding_type = %key,
                    "Deduplicating duplicate binding"
                );
                continue;
            }

            seen_binding_types.insert(key);
            result.push(binding);
        }

        result
    }

    /// Validate all bindings in a list don't conflict with each other.
    /// Returns Ok(()) if all bindings are valid, Err with message if any conflict.
    fn validate_bindings_no_conflicts(bindings: &[Binding]) -> Result<()> {
        for (i, binding) in bindings.iter().enumerate() {
            // Check against all bindings before this one (to avoid duplicate checks)
            let preceding_bindings = &bindings[..i];
            if let Some(error_msg) =
                Self::validate_binding_no_conflict(&binding.base.binding_type, preceding_bindings)
            {
                return Err(ValidationError::new(error_msg).into());
            }
        }
        Ok(())
    }

    pub async fn upsert_service(
        &self,
        mut existing_service: Service,
        new_service_data: Service,
        authentication: AuthenticatedEntity,
    ) -> Result<Service> {
        // NOTE: This function assumes the caller already holds the service lock.
        // It's called from create() which acquires the lock before calling this.
        let mut binding_updates = 0;

        let service_before_updates = existing_service.clone();

        tracing::info!(
            service_id = %existing_service.id,
            service_name = %existing_service.base.name,
            existing_bindings_count = existing_service.base.bindings.len(),
            new_bindings_count = new_service_data.base.bindings.len(),
            ">>> UPSERT_SERVICE START"
        );

        // Log existing bindings in detail
        for (i, binding) in existing_service.base.bindings.iter().enumerate() {
            tracing::debug!(
                service_id = %existing_service.id,
                binding_index = i,
                binding_id = %binding.id,
                binding_type = ?binding.base.binding_type,
                "Existing binding before upsert"
            );
        }

        // Log new bindings in detail
        for (i, binding) in new_service_data.base.bindings.iter().enumerate() {
            tracing::debug!(
                service_id = %existing_service.id,
                binding_index = i,
                binding_id = %binding.id,
                binding_type = ?binding.base.binding_type,
                "New binding to process"
            );
        }

        tracing::trace!(
            "Upserting new service data {:?} into {:?}",
            new_service_data,
            existing_service
        );

        for new_service_binding in &new_service_data.base.bindings {
            // Check if this binding is already covered by existing bindings
            // (e.g., a specific interface binding is covered by an "all interfaces" binding for the same port)
            let is_covered = Self::is_binding_covered_by_existing(
                new_service_binding,
                &existing_service.base.bindings,
            );

            if is_covered {
                tracing::trace!(
                    "Skipping binding {:?} - already covered by existing all-interfaces binding",
                    new_service_binding.base.binding_type
                );
                continue;
            }

            // Check for binding type conflicts (Interface vs Port on same interface)
            if let Some(conflict_msg) = Self::validate_binding_no_conflict(
                &new_service_binding.base.binding_type,
                &existing_service.base.bindings,
            ) {
                tracing::warn!(
                    "Skipping binding {:?} - conflicts with existing binding: {}",
                    new_service_binding.base.binding_type,
                    conflict_msg
                );
                continue;
            }

            // If new binding is "all interfaces" port binding, remove specific interface bindings for same port
            // (the all-interfaces binding supersedes them)
            if let BindingType::Port {
                port_id,
                interface_id: None,
            } = &new_service_binding.base.binding_type
            {
                tracing::debug!(
                    service_id = %existing_service.id,
                    new_binding_port_id = %port_id,
                    "Processing all-interfaces port binding - checking for dominated specific bindings"
                );

                let before_count = existing_service.base.bindings.len();
                existing_service.base.bindings.retain(|existing| {
                    // Log each comparison for debugging
                    if let BindingType::Port {
                        port_id: existing_port_id,
                        interface_id: existing_interface_id,
                    } = &existing.base.binding_type
                    {
                        let dominated =
                            existing_interface_id.is_some() && existing_port_id == port_id;
                        tracing::debug!(
                            service_id = %existing_service.id,
                            existing_port_id = %existing_port_id,
                            new_port_id = %port_id,
                            existing_interface_id = ?existing_interface_id,
                            port_ids_match = (existing_port_id == port_id),
                            is_specific_interface = existing_interface_id.is_some(),
                            will_remove = dominated,
                            "Comparing port binding for domination"
                        );
                        if dominated {
                            tracing::info!(
                                service_id = %existing_service.id,
                                removed_binding_id = %existing.id,
                                removed_port_id = %existing_port_id,
                                removed_interface_id = ?existing_interface_id,
                                "Removing specific interface binding - superseded by all-interfaces"
                            );
                        }
                        return !dominated;
                    }
                    true // Keep non-port bindings
                });
                let removed = before_count - existing_service.base.bindings.len();
                tracing::debug!(
                    service_id = %existing_service.id,
                    bindings_before = before_count,
                    bindings_after = existing_service.base.bindings.len(),
                    removed_count = removed,
                    "Finished checking for dominated bindings"
                );
                if removed > 0 {
                    binding_updates += removed;
                }
            }

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

        // Log final bindings state before save
        tracing::debug!(
            service_id = %existing_service.id,
            final_bindings_count = existing_service.base.bindings.len(),
            binding_updates = binding_updates,
            "Final bindings state before save"
        );
        for (i, binding) in existing_service.base.bindings.iter().enumerate() {
            tracing::debug!(
                service_id = %existing_service.id,
                binding_index = i,
                binding_id = %binding.id,
                binding_type = ?binding.base.binding_type,
                "Final binding to be saved"
            );
        }

        tracing::debug!(service_id = %existing_service.id, "Updating service in storage...");
        self.storage.update(&mut existing_service).await?;
        tracing::debug!(service_id = %existing_service.id, "Service storage update complete");

        // Save bindings to separate table with correct service_id and network_id
        let bindings_with_ids: Vec<Binding> = existing_service
            .base
            .bindings
            .iter()
            .cloned()
            .map(|b| b.with_service(existing_service.id, existing_service.base.network_id))
            .collect();

        tracing::debug!(
            service_id = %existing_service.id,
            bindings_to_save = bindings_with_ids.len(),
            "Saving bindings to binding storage..."
        );
        let saved_bindings = self
            .binding_storage
            .save_for_parent(&existing_service.id, &bindings_with_ids)
            .await?;
        tracing::debug!(service_id = %existing_service.id, "Binding storage save complete");

        // Update service with the saved bindings (which have actual IDs and preserved created_at)
        existing_service.base.bindings = saved_bindings;

        let mut data = Vec::new();

        if binding_updates > 0 {
            data.push(format!("{} bindings", binding_updates))
        };

        if !data.is_empty() {
            let trigger_stale = existing_service.triggers_staleness(Some(service_before_updates));

            tracing::debug!(service_id = %existing_service.id, "Publishing entity event...");
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
            tracing::debug!(service_id = %existing_service.id, "Entity event published");
        } else {
            tracing::debug!(
                service_id = %existing_service.id,
                "Service upsert - no binding changes needed"
            );
        }

        tracing::info!(
            service_id = %existing_service.id,
            service_name = %existing_service.base.name,
            binding_updates = binding_updates,
            final_bindings_count = existing_service.base.bindings.len(),
            "<<< UPSERT_SERVICE END"
        );

        Ok(existing_service)
    }

    async fn update_group_service_bindings(
        &self,
        current_service: &Service,
        updates: Option<&Service>,
        authenticated: AuthenticatedEntity,
    ) -> Result<(), Error> {
        tracing::info!(
            service_id = %current_service.id,
            service_name = %current_service.base.name,
            is_delete = updates.is_none(),
            ">>> UPDATE_GROUP_SERVICE_BINDINGS START"
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

        tracing::info!(
            service_id = %current_service.id,
            current_binding_ids = ?current_service_binding_ids,
            updated_binding_ids = ?updated_service_binding_ids,
            current_count = current_service_binding_ids.len(),
            updated_count = updated_service_binding_ids.len(),
            groups_found = groups.len(),
            "UPDATE_GROUP_SERVICE_BINDINGS: Comparing binding IDs"
        );

        let groups_to_update: Vec<Group> = groups
            .into_iter()
            .filter_map(|mut group| {
                let initial_binding_ids = group.base.binding_ids.clone();
                let initial_bindings_length = group.base.binding_ids.len();

                group.base.binding_ids.retain(|sb| {
                    let in_current = current_service_binding_ids.contains(sb);
                    let in_updated = updated_service_binding_ids.contains(sb);
                    let keep = if in_current { in_updated } else { true };

                    if in_current && !keep {
                        tracing::warn!(
                            service_id = %current_service.id,
                            group_id = %group.id,
                            group_name = %group.base.name,
                            binding_id = %sb,
                            in_current = in_current,
                            in_updated = in_updated,
                            "UPDATE_GROUP_SERVICE_BINDINGS: REMOVING binding from group"
                        );
                    }

                    keep
                });

                if group.base.binding_ids.len() != initial_bindings_length {
                    tracing::info!(
                        service_id = %current_service.id,
                        group_id = %group.id,
                        group_name = %group.base.name,
                        before_binding_ids = ?initial_binding_ids,
                        after_binding_ids = ?group.base.binding_ids,
                        removed_count = initial_bindings_length - group.base.binding_ids.len(),
                        "UPDATE_GROUP_SERVICE_BINDINGS: Group will be updated"
                    );
                    Some(group)
                } else {
                    None
                }
            })
            .collect();

        if !groups_to_update.is_empty() {
            for mut group in groups_to_update {
                self.group_service
                    .update(&mut group, authenticated.clone())
                    .await?;
            }
            tracing::info!(
                service_id = %current_service.id,
                service_name = %current_service.base.name,
                "UPDATE_GROUP_SERVICE_BINDINGS: Groups updated"
            );
        }

        tracing::info!(
            service_id = %current_service.id,
            "<<< UPDATE_GROUP_SERVICE_BINDINGS END"
        );

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

        tracing::info!(
            service_id = %service.id,
            service_name = %service.base.name,
            original_host_id = %original_host.id,
            updated_host_id = %updated_host.id,
            original_interfaces_count = original_interfaces.len(),
            updated_interfaces_count = updated_interfaces.len(),
            original_ports_count = original_ports.len(),
            updated_ports_count = updated_ports.len(),
            bindings_count = service.base.bindings.len(),
            ">>> REASSIGN_BINDINGS START"
        );

        // Log original ports for debugging
        for port in original_ports {
            tracing::debug!(
                service_id = %service.id,
                port_id = %port.id,
                port_number = port.base.port_type.config().number,
                port_protocol = ?port.base.port_type.config().protocol,
                "Original port available for remapping"
            );
        }

        // Log updated ports for debugging
        for port in updated_ports {
            tracing::debug!(
                service_id = %service.id,
                port_id = %port.id,
                port_number = port.base.port_type.config().number,
                port_protocol = ?port.base.port_type.config().protocol,
                "Updated port available for remapping"
            );
        }

        // Log input bindings
        for binding in &service.base.bindings {
            tracing::debug!(
                service_id = %service.id,
                binding_id = %binding.id,
                binding_type = ?binding.base.binding_type,
                "Input binding to reassign"
            );
        }

        tracing::trace!(
            "Preparing service {:?} for transfer from host {:?} to host {:?}",
            service,
            original_host,
            updated_host
        );

        let mut mutable_service = service.clone();

        let service_name = service.base.name.clone();
        let service_id = service.id;

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
                        // Interface binding couldn't be matched - this can happen during consolidation
                        // when the source host's interface doesn't exist on the destination host.
                        // We drop the binding and warn.
                        tracing::warn!(
                            service_id = %service_id,
                            service_name = %service_name,
                            original_interface_id = ?b.interface_id(),
                            "Dropping interface binding during reassignment: \
                             no matching interface found on destination host"
                        );
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
                                Some(original_interface) => {
                                    match updated_interfaces
                                        .iter()
                                        .find(|i| *i == original_interface)
                                    {
                                        Some(found_interface) => {
                                            Some(Some(found_interface.clone()))
                                        }
                                        None => {
                                            // Interface not found on destination host - fall back to "all interfaces"
                                            // This is better than dropping the binding entirely
                                            tracing::warn!(
                                                service_id = %service_id,
                                                service_name = %service_name,
                                                port_number = %new_port.base.port_type.config().number,
                                                original_interface_ip = %original_interface.base.ip_address,
                                                "Port binding interface not found on destination host - \
                                                 falling back to 'all interfaces'"
                                            );
                                            Some(None)
                                        }
                                    }
                                }
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
                        // Port not found on destination host - drop the binding
                        tracing::warn!(
                            service_id = %service_id,
                            service_name = %service_name,
                            original_port_id = %port_id,
                            "Dropping port binding during reassignment: \
                             no matching port found on destination host"
                        );
                        None::<Binding>
                    }
                };

                None
            })
            .collect();

        mutable_service.base.host_id = updated_host.id;

        mutable_service.base.network_id = updated_host.base.network_id;

        tracing::info!(
            service_id = %service.id,
            service_name = %service.base.name,
            original_bindings_count = service.base.bindings.len(),
            reassigned_bindings_count = mutable_service.base.bindings.len(),
            origin_host_id = %original_host.id,
            destination_host_id = %updated_host.id,
            "<<< REASSIGN_BINDINGS END"
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
