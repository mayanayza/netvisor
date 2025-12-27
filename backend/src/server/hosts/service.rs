use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    bindings::r#impl::base::BindingType,
    daemons::service::DaemonService,
    hosts::r#impl::{
        api::{
            ConflictBehavior, CreateHostRequest, HostResponse, UpdateHostRequest,
            UpdateInterfaceInput, UpdatePortInput,
        },
        base::{Host, HostBase},
    },
    interfaces::{r#impl::base::Interface, service::InterfaceService},
    ports::{r#impl::base::Port, service::PortService},
    services::{r#impl::base::Service, service::ServiceService},
    shared::{
        entities::ChangeTriggersTopologyStaleness,
        events::{
            bus::EventBus,
            types::{EntityEvent, EntityOperation},
        },
        services::traits::{CrudService, EventBusService},
        storage::{
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
use anyhow::{Error, Result, anyhow};
use async_trait::async_trait;
use chrono::Utc;
use std::{collections::HashMap, sync::Arc};
use strum::IntoDiscriminant;
use tokio::sync::Mutex;
use uuid::Uuid;

pub struct HostService {
    storage: Arc<GenericPostgresStorage<Host>>,
    interface_service: Arc<InterfaceService>,
    port_service: Arc<PortService>,
    service_service: Arc<ServiceService>,
    daemon_service: Arc<DaemonService>,
    host_locks: Arc<Mutex<HashMap<Uuid, Arc<Mutex<()>>>>>,
    event_bus: Arc<EventBus>,
}

impl EventBusService<Host> for HostService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, entity: &Host) -> Option<Uuid> {
        Some(entity.base.network_id)
    }
    fn get_organization_id(&self, _entity: &Host) -> Option<Uuid> {
        None
    }
}

#[async_trait]
impl CrudService<Host> for HostService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Host>> {
        &self.storage
    }

    /// Create a new host, or upsert if a matching host exists.
    ///
    /// This method uses `Host::eq` (ID comparison) to find existing hosts.
    /// For discovery workflows, `create_with_children` sets the incoming host's ID
    /// to match an existing host found via interface comparison, so this method
    /// will find the match and trigger `upsert_host()`.
    ///
    /// Upsert conditions:
    /// - Both hosts are from discovery (merges discovery metadata)
    /// - OR the IDs already match (handles re-discovery of known hosts)
    async fn create(&self, host: Host, authentication: AuthenticatedEntity) -> Result<Host> {
        let host = if host.id == Uuid::nil() {
            Host::new(host.base.clone())
        } else {
            host
        };

        let lock = self.get_host_lock(&host.id).await;
        let _guard = lock.lock().await;

        tracing::trace!("Creating host {:?}", host);

        let filter = EntityFilter::unfiltered().network_ids(&[host.base.network_id]);
        let all_hosts = self.get_all(filter).await?;

        // Find existing host by ID (Host::eq only compares IDs)
        // For discovery, create_with_children already set host.id to the existing host's ID
        // if an interface match was found, so this will find the match
        let host_from_storage = match all_hosts.into_iter().find(|h| host.eq(h)) {
            // Upsert if both are discovery sources, or if IDs match exactly
            Some(existing_host)
                if (host.base.source.discriminant() == EntitySourceDiscriminants::Discovery
                    && existing_host.base.source.discriminant()
                        == EntitySourceDiscriminants::Discovery)
                    || host.id == existing_host.id =>
            {
                if host.id != existing_host.id {
                    tracing::warn!(
                        incoming_host_id = %host.id,
                        matched_host_id = %existing_host.id,
                        matched_host_name = %existing_host.base.name,
                        "Host matched via MAC/IP address but discovery reported a different host ID. \
                         This may indicate a daemon is using a stale configuration. \
                         To fix, update the daemon's config file with: host_id = \"{}\"",
                        existing_host.id
                    );
                }

                tracing::debug!(
                    "Duplicate host for {}: {} found, {}: {} - upserting discovery data...",
                    host.base.name,
                    host.id,
                    existing_host.base.name,
                    existing_host.id
                );

                self.upsert_host(existing_host, host, authentication)
                    .await?
            }
            _ => {
                if let Some(existing_host) = self.get_by_id(&host.id).await? {
                    return Err(ValidationError::new(format!(
                        "Network mismatch: Daemon is trying to update host '{}' (id: {}) but cannot proceed. \
                        The host belongs to network {} while the daemon is assigned to network {}. \
                        To resolve this, either reassign the daemon to the correct network or delete the mismatched host.",
                        existing_host.base.name,
                        host.id,
                        existing_host.base.network_id,
                        host.base.network_id
                    )).into());
                }

                let created = self.storage().create(&host).await?;
                let trigger_stale = created.triggers_staleness(None);

                self.event_bus()
                    .publish_entity(EntityEvent {
                        id: Uuid::new_v4(),
                        entity_id: created.id(),
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

                host
            }
        };

        Ok(host_from_storage)
    }

    async fn update(
        &self,
        updates: &mut Host,
        authentication: AuthenticatedEntity,
    ) -> Result<Host, Error> {
        let lock = self.get_host_lock(&updates.id).await;
        let _guard = lock.lock().await;

        let current_host = self
            .get_by_id(&updates.id)
            .await?
            .ok_or_else(|| anyhow!("Host '{}' not found", updates.id))?;

        let updated = self.storage().update(updates).await?;
        let trigger_stale = updated.triggers_staleness(Some(current_host));

        self.event_bus()
            .publish_entity(EntityEvent {
                id: Uuid::new_v4(),
                entity_id: updated.id(),
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
}

impl HostService {
    pub fn new(
        storage: Arc<GenericPostgresStorage<Host>>,
        interface_service: Arc<InterfaceService>,
        port_service: Arc<PortService>,
        service_service: Arc<ServiceService>,
        daemon_service: Arc<DaemonService>,
        event_bus: Arc<EventBus>,
    ) -> Self {
        Self {
            storage,
            interface_service,
            port_service,
            service_service,
            daemon_service,
            host_locks: Arc::new(Mutex::new(HashMap::new())),
            event_bus,
        }
    }

    /// Get ports for a specific host
    pub async fn get_ports_for_host(&self, host_id: &Uuid) -> Result<Vec<Port>> {
        self.port_service.get_for_host(host_id).await
    }

    /// Get interfaces for a specific host
    pub async fn get_interfaces_for_host(&self, host_id: &Uuid) -> Result<Vec<Interface>> {
        self.interface_service.get_for_host(host_id).await
    }

    // =========================================================================
    // HostResponse builders (hydrate children for API responses)
    // =========================================================================

    /// Get a single host with all children hydrated for API response
    pub async fn get_host_response(&self, id: &Uuid) -> Result<Option<HostResponse>> {
        let host = match self.get_by_id(id).await? {
            Some(h) => h,
            None => return Ok(None),
        };

        let (interfaces, ports, services) = self.load_children_for_host(&host.id).await?;
        Ok(Some(HostResponse::from_host_with_children(
            host, interfaces, ports, services,
        )))
    }

    /// Get all hosts with all children hydrated for API response
    pub async fn get_all_host_responses(&self, filter: EntityFilter) -> Result<Vec<HostResponse>> {
        let hosts = self.get_all(filter).await?;
        if hosts.is_empty() {
            return Ok(vec![]);
        }

        let host_ids: Vec<Uuid> = hosts.iter().map(|h| h.id).collect();
        let (interfaces_map, ports_map, services_map) =
            self.load_children_for_hosts(&host_ids).await?;

        let responses = hosts
            .into_iter()
            .map(|host| {
                let interfaces = interfaces_map.get(&host.id).cloned().unwrap_or_default();
                let ports = ports_map.get(&host.id).cloned().unwrap_or_default();
                let services = services_map.get(&host.id).cloned().unwrap_or_default();
                HostResponse::from_host_with_children(host, interfaces, ports, services)
            })
            .collect();

        Ok(responses)
    }

    /// Load all children for a single host
    async fn load_children_for_host(
        &self,
        host_id: &Uuid,
    ) -> Result<(Vec<Interface>, Vec<Port>, Vec<Service>)> {
        let interfaces = self.interface_service.get_for_host(host_id).await?;
        let ports = self.port_service.get_for_host(host_id).await?;
        let services = self
            .service_service
            .get_all(EntityFilter::unfiltered().host_id(host_id))
            .await?;

        Ok((interfaces, ports, services))
    }

    /// Batch load all children for multiple hosts
    async fn load_children_for_hosts(
        &self,
        host_ids: &[Uuid],
    ) -> Result<(
        HashMap<Uuid, Vec<Interface>>,
        HashMap<Uuid, Vec<Port>>,
        HashMap<Uuid, Vec<Service>>,
    )> {
        let interfaces_map = self.interface_service.get_for_hosts(host_ids).await?;
        let ports_map = self.port_service.get_for_hosts(host_ids).await?;

        // Load services and group by host_id
        let services = self
            .service_service
            .get_all(EntityFilter::unfiltered().host_ids(host_ids))
            .await?;

        let mut services_map: HashMap<Uuid, Vec<Service>> = HashMap::new();
        for service in services {
            services_map
                .entry(service.base.host_id)
                .or_default()
                .push(service);
        }

        Ok((interfaces_map, ports_map, services_map))
    }

    // =========================================================================
    // Host creation with children
    // =========================================================================

    /// Create a host from a CreateHostRequest with interfaces and ports.
    /// For API users: errors if a host with matching interfaces exists.
    /// Source is automatically set to Manual for API-created entities.
    ///
    /// Note: Services are created separately via the services endpoint after the host exists,
    /// as service bindings require the real IDs of the interfaces/ports to reference.
    pub async fn create_from_request(
        &self,
        request: CreateHostRequest,
        authentication: AuthenticatedEntity,
    ) -> Result<HostResponse> {
        // Destructure request to ensure compile error if fields change
        let CreateHostRequest {
            name,
            network_id,
            hostname,
            description,
            virtualization,
            hidden,
            tags,
            interfaces: interface_inputs,
            ports: port_inputs,
        } = request;

        // Auto-set source to Manual for API-created entities
        let source = EntitySource::Manual;

        // Create host base
        let host_base = HostBase {
            name: name.clone(),
            network_id,
            hostname,
            description,
            source,
            virtualization,
            hidden,
            tags,
        };
        let host = Host::new(host_base);

        // Build interfaces for conflict detection and creation
        let interfaces: Vec<Interface> = interface_inputs
            .into_iter()
            .map(|input| Interface::new(input.into_base(host.id, network_id)))
            .collect();

        // Build ports
        let ports: Vec<Port> = port_inputs
            .into_iter()
            .map(|input| Port::new(input.into_base(host.id, network_id)))
            .collect();

        // Use unified creation with Error behavior for API users
        // Services are created separately via POST /api/services
        self.create_with_children(
            host,
            interfaces,
            ports,
            vec![], // No services - added separately after host creation
            ConflictBehavior::Error,
            authentication,
        )
        .await
    }

    /// Create a host with all children, handling conflicts according to behavior.
    /// This is the unified internal method used by both API and discovery paths.
    ///
    /// ## Host Deduplication Flow
    ///
    /// Host deduplication happens in two stages:
    ///
    /// 1. **Interface-based matching** (this method): `find_matching_host_by_interfaces` compares
    ///    incoming interfaces against existing hosts using MAC address or subnet+IP matching.
    ///    - For API users (ConflictBehavior::Error): Returns an error telling them to edit the existing host.
    ///    - For discovery (ConflictBehavior::Upsert): Sets `host.id = existing_host.id` so the
    ///      subsequent create() call will recognize this as an existing host.
    ///
    /// 2. **ID-based matching** (in `create()`): Uses `Host::eq` which only compares IDs.
    ///    Since we set `host.id = existing_host.id` in step 1, the create() method will find
    ///    a match and call `upsert_host()` to merge discovery data.
    ///
    /// This two-stage approach means:
    /// - Interface matching handles the "is this the same physical host?" question
    /// - ID matching handles the "should we upsert?" question (relies on ID being set correctly)
    /// - Discovery always upserts when interfaces match, even if daemon reported a different host ID
    async fn create_with_children(
        &self,
        mut host: Host,
        interfaces: Vec<Interface>,
        ports: Vec<Port>,
        services: Vec<Service>,
        conflict_behavior: ConflictBehavior,
        authentication: AuthenticatedEntity,
    ) -> Result<HostResponse> {
        // Stage 1: Interface-based collision detection
        // Compares MAC addresses and subnet+IP to find hosts that represent the same physical machine
        let matching_result = self
            .find_matching_host_by_interfaces(&host.base.network_id, &interfaces)
            .await?;

        if let Some((existing_host, _)) = matching_result {
            match conflict_behavior {
                ConflictBehavior::Error => {
                    // API users should edit the existing host rather than create a duplicate
                    return Err(ValidationError::new(format!(
                        "A host with matching interfaces already exists: '{}' (id: {}). \
                         Edit the existing host instead of creating a new one.",
                        existing_host.base.name, existing_host.id
                    ))
                    .into());
                }
                ConflictBehavior::Upsert => {
                    // For discovery: align the incoming host ID with the existing host
                    // This ensures create() will match via Host::eq (which compares IDs)
                    // and trigger upsert_host() to merge discovery metadata
                    if host.id != existing_host.id {
                        tracing::debug!(
                            incoming_host_id = %host.id,
                            matched_host_id = %existing_host.id,
                            matched_host_name = %existing_host.base.name,
                            "Setting host ID to match existing host found via interface comparison"
                        );
                        host.id = existing_host.id;
                    }
                }
            }
        }

        // Store original entities for binding reassignment (discovery case)
        // These are needed because interface/port IDs may change during creation,
        // and service bindings need to be remapped to the new IDs
        let original_host = host.clone();
        let original_interfaces = interfaces.clone();
        let original_ports = ports.clone();

        // Stage 2: Create or upsert host via ID matching
        // If host.id was set to an existing host's ID above, this will trigger upsert_host()
        let created_host = self.create(host, authentication.clone()).await?;

        // Create interfaces with correct host_id
        // For Upsert: deduplicate by checking existing interfaces first
        // For Error: just create (will fail on duplicate constraint)
        let mut created_interfaces = Vec::new();
        for mut interface in interfaces {
            interface.base.host_id = created_host.id;

            if matches!(conflict_behavior, ConflictBehavior::Upsert) {
                // Check if interface already exists by ID
                if let Some(existing_iface) =
                    self.interface_service.get_by_id(&interface.id).await?
                {
                    created_interfaces.push(existing_iface);
                    continue;
                }

                // Check by unique constraint (host_id, subnet_id, ip_address)
                let filter = EntityFilter::unfiltered()
                    .host_id(&interface.base.host_id)
                    .subnet_id(&interface.base.subnet_id);
                let existing_by_key: Vec<Interface> =
                    self.interface_service.get_all(filter).await?;
                if let Some(existing_iface) = existing_by_key
                    .into_iter()
                    .find(|i| i.base.ip_address == interface.base.ip_address)
                {
                    created_interfaces.push(existing_iface);
                    continue;
                }
            }

            let created = self
                .interface_service
                .create(interface, authentication.clone())
                .await?;
            created_interfaces.push(created);
        }

        // Create ports with correct host_id
        // For Upsert: deduplicate by checking existing ports first
        // For Error: just create (will fail on duplicate constraint)
        let mut created_ports = Vec::new();
        for port in ports {
            let port_with_host = port.with_host(created_host.id, created_host.base.network_id);

            if matches!(conflict_behavior, ConflictBehavior::Upsert) {
                // Check if port already exists by ID
                if let Some(existing_port) = self.port_service.get_by_id(&port_with_host.id).await?
                {
                    created_ports.push(existing_port);
                    continue;
                }

                // Check by unique constraint (host_id, port_number, protocol)
                let existing_ports = self.port_service.get_for_host(&created_host.id).await?;
                let port_config = port_with_host.base.port_type.config();
                if let Some(existing_port) = existing_ports.into_iter().find(|p| {
                    let existing_config = p.base.port_type.config();
                    existing_config.number == port_config.number
                        && existing_config.protocol == port_config.protocol
                }) {
                    created_ports.push(existing_port);
                    continue;
                }
            }

            let created = self.port_service.create_direct(&port_with_host).await?;
            created_ports.push(created);
        }

        // Create services with bindings reassigned (for discovery where IDs may change)
        let mut created_services = Vec::new();
        for service in services {
            let reassigned = self
                .service_service
                .reassign_service_interface_bindings(
                    service,
                    &original_host,
                    &original_interfaces,
                    &original_ports,
                    &created_host,
                    &created_interfaces,
                    &created_ports,
                )
                .await;

            let created = self
                .service_service
                .create(reassigned, authentication.clone())
                .await?;
            created_services.push(created);
        }

        tracing::info!(
            host_id = %created_host.id,
            host_name = %created_host.base.name,
            interface_count = %created_interfaces.len(),
            port_count = %created_ports.len(),
            service_count = %created_services.len(),
            "Created host with children"
        );

        Ok(HostResponse::from_host_with_children(
            created_host,
            created_interfaces,
            created_ports,
            created_services,
        ))
    }

    /// Update a host from an UpdateHostRequest
    /// Optionally syncs interfaces and ports if provided in the request.
    pub async fn update_from_request(
        &self,
        request: UpdateHostRequest,
        authentication: AuthenticatedEntity,
    ) -> Result<HostResponse> {
        // Get existing host
        let existing = self
            .get_by_id(&request.id)
            .await?
            .ok_or_else(|| anyhow!("Host '{}' not found", request.id))?;

        let network_id = existing.base.network_id;

        // Destructure request for exhaustive field handling
        let UpdateHostRequest {
            id,
            name,
            hostname,
            description,
            virtualization,
            hidden,
            tags,
            expected_updated_at,
            interfaces: interface_inputs,
            ports: port_inputs,
        } = request;

        // Optimistic locking: check if host was modified since user loaded it
        if let Some(expected) = expected_updated_at
            && existing.updated_at != expected
        {
            tracing::warn!(
                host_id = %id,
                expected = %expected,
                actual = %existing.updated_at,
                "Host update conflict - host was modified since user loaded it"
            );
            return Err(ValidationError::new(format!(
                "Host was modified by another process (possibly discovery). \
                     Please reload and try again. Expected: {}, Actual: {}",
                expected, existing.updated_at
            ))
            .into());
        }

        // Build updated host preserving non-updatable fields
        let mut updated_host = Host {
            id,
            created_at: existing.created_at,
            updated_at: existing.updated_at,
            base: HostBase {
                name,
                network_id, // Not updatable
                hostname,
                description,
                source: existing.base.source, // Not updatable via API
                virtualization,
                hidden,
                tags,
            },
        };

        let updated = self
            .update(&mut updated_host, authentication.clone())
            .await?;

        // Sync interfaces if provided
        if let Some(inputs) = interface_inputs {
            self.sync_interfaces(&updated.id, &network_id, inputs, authentication.clone())
                .await?;
        }

        // Sync ports if provided
        if let Some(inputs) = port_inputs {
            self.sync_ports(&updated.id, &network_id, inputs, authentication.clone())
                .await?;
        }

        // Load fresh children after sync
        let (interfaces, ports, services) = self.load_children_for_host(&updated.id).await?;

        Ok(HostResponse::from_host_with_children(
            updated, interfaces, ports, services,
        ))
    }

    /// Sync interfaces for a host: delete removed, update existing, create new.
    async fn sync_interfaces(
        &self,
        host_id: &Uuid,
        network_id: &Uuid,
        inputs: Vec<UpdateInterfaceInput>,
        authentication: AuthenticatedEntity,
    ) -> Result<()> {
        use std::collections::HashSet;

        // Get existing interfaces for this host
        let existing = self.interface_service.get_for_host(host_id).await?;
        let existing_ids: HashSet<Uuid> = existing.iter().map(|i| i.id).collect();

        // Partition inputs into new vs existing
        let input_ids: HashSet<Uuid> = inputs
            .iter()
            .filter_map(|i| if i.is_new() { None } else { i.id })
            .collect();

        // Delete interfaces that are not in the input list
        let to_delete: Vec<Uuid> = existing_ids.difference(&input_ids).copied().collect();
        if !to_delete.is_empty() {
            self.interface_service
                .delete_many(&to_delete, authentication.clone())
                .await?;
        }

        // Process each input
        for input in inputs {
            let is_new = input.is_new();
            let mut interface = input.into_interface(*host_id, *network_id);

            if is_new {
                // Create new interface
                self.interface_service
                    .create(interface, authentication.clone())
                    .await?;
            } else if existing_ids.contains(&interface.id) {
                // Update existing interface - preserve created_at from existing
                if let Some(existing_iface) = existing.iter().find(|i| i.id == interface.id) {
                    interface.created_at = existing_iface.created_at;
                }
                self.interface_service
                    .update(&mut interface, authentication.clone())
                    .await?;
            }
            // Note: if ID doesn't exist in existing, it's silently skipped (invalid reference)
        }

        Ok(())
    }

    /// Sync ports for a host: delete removed, create new (ports are not updated, just kept or replaced).
    async fn sync_ports(
        &self,
        host_id: &Uuid,
        network_id: &Uuid,
        inputs: Vec<UpdatePortInput>,
        authentication: AuthenticatedEntity,
    ) -> Result<()> {
        use std::collections::HashSet;

        // Get existing ports for this host
        let existing = self.port_service.get_for_host(host_id).await?;
        let existing_ids: HashSet<Uuid> = existing.iter().map(|p| p.id).collect();

        // Partition inputs into new vs existing
        let input_ids: HashSet<Uuid> = inputs
            .iter()
            .filter_map(|p| if p.is_new() { None } else { p.id })
            .collect();

        // Delete ports that are not in the input list
        let to_delete: Vec<Uuid> = existing_ids.difference(&input_ids).copied().collect();
        if !to_delete.is_empty() {
            self.port_service
                .delete_many(&to_delete, authentication.clone())
                .await?;
        }

        // Create new ports (existing ports are kept as-is)
        for input in inputs {
            if input.is_new() {
                let port = input.into_port(*host_id, *network_id);
                self.port_service
                    .create(port, authentication.clone())
                    .await?;
            }
        }

        Ok(())
    }

    // =========================================================================
    // Discovery support (internal API)
    // =========================================================================

    /// Create or update a host from daemon discovery data.
    /// This handles interface/port matching for host deduplication and upserts on conflict.
    pub async fn discover_host(
        &self,
        host: Host,
        interfaces: Vec<Interface>,
        ports: Vec<Port>,
        services: Vec<Service>,
        authentication: AuthenticatedEntity,
    ) -> Result<HostResponse> {
        self.create_with_children(
            host,
            interfaces,
            ports,
            services,
            ConflictBehavior::Upsert,
            authentication,
        )
        .await
    }

    /// Find an existing host that matches based on interface data (MAC address or subnet+IP).
    pub async fn find_matching_host_by_interfaces(
        &self,
        network_id: &Uuid,
        incoming_interfaces: &[Interface],
    ) -> Result<Option<(Host, Vec<Interface>)>> {
        if incoming_interfaces.is_empty() {
            return Ok(None);
        }

        let filter = EntityFilter::unfiltered().network_ids(&[*network_id]);
        let all_hosts = self.get_all(filter).await?;

        if all_hosts.is_empty() {
            return Ok(None);
        }

        let host_ids: Vec<Uuid> = all_hosts.iter().map(|h| h.id).collect();
        let interfaces_by_host = self.interface_service.get_for_hosts(&host_ids).await?;

        for host in all_hosts {
            let host_interfaces = interfaces_by_host
                .get(&host.id)
                .cloned()
                .unwrap_or_default();

            for incoming_iface in incoming_interfaces {
                for existing_iface in &host_interfaces {
                    if incoming_iface == existing_iface {
                        tracing::debug!(
                            incoming_ip = %incoming_iface.base.ip_address,
                            existing_ip = %existing_iface.base.ip_address,
                            existing_host_id = %host.id,
                            existing_host_name = %host.base.name,
                            "Found matching host via interface comparison"
                        );
                        return Ok(Some((host, host_interfaces)));
                    }
                }
            }
        }

        Ok(None)
    }

    async fn get_host_lock(&self, host_id: &Uuid) -> Arc<Mutex<()>> {
        let mut locks = self.host_locks.lock().await;
        locks
            .entry(*host_id)
            .or_insert_with(|| Arc::new(Mutex::new(())))
            .clone()
    }

    /// Merge new discovery data with existing host
    async fn upsert_host(
        &self,
        mut existing_host: Host,
        new_host_data: Host,
        authentication: AuthenticatedEntity,
    ) -> Result<Host> {
        let host_before_updates = existing_host.clone();
        let mut has_updates = false;

        tracing::trace!(
            "Upserting new host data {:?} to host {:?}",
            new_host_data,
            existing_host
        );

        // Update hostname if not set
        if existing_host.base.hostname.is_none() && new_host_data.base.hostname.is_some() {
            has_updates = true;
            existing_host.base.hostname = new_host_data.base.hostname;
        }

        // Merge entity source metadata
        existing_host.base.source = match (existing_host.base.source, new_host_data.base.source) {
            (
                EntitySource::Discovery {
                    metadata: existing_metadata,
                },
                EntitySource::Discovery {
                    metadata: new_metadata,
                },
            ) => {
                has_updates = true;
                EntitySource::Discovery {
                    metadata: [new_metadata, existing_metadata].concat(),
                }
            }
            (
                _,
                EntitySource::Discovery {
                    metadata: new_metadata,
                },
            ) => {
                has_updates = true;
                EntitySource::Discovery {
                    metadata: new_metadata,
                }
            }
            (existing_source, _) => existing_source,
        };

        if has_updates {
            self.storage().update(&mut existing_host).await?;

            let trigger_stale = existing_host.triggers_staleness(Some(host_before_updates));

            self.event_bus()
                .publish_entity(EntityEvent {
                    id: Uuid::new_v4(),
                    entity_id: existing_host.id(),
                    network_id: self.get_network_id(&existing_host),
                    organization_id: self.get_organization_id(&existing_host),
                    entity_type: existing_host.clone().into(),
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
                "No new data to upsert from host {} to {}",
                new_host_data.base.name,
                existing_host.base.name
            );
        }

        Ok(existing_host)
    }

    pub async fn consolidate_hosts(
        &self,
        destination_host: Host,
        other_host: Host,
        authentication: AuthenticatedEntity,
    ) -> Result<HostResponse> {
        if destination_host.id == other_host.id {
            return Err(ValidationError::new("Can't consolidate a host with itself").into());
        }

        let host_filter = EntityFilter::unfiltered().host_id(&other_host.id);

        if self.daemon_service.get_one(host_filter).await?.is_some() {
            return Err(ValidationError::new(
                "Can't consolidate a host that has a daemon associated with it. \
                 Consolidate the other host into the host with the daemon instead.",
            )
            .into());
        }

        let lock = self.get_host_lock(&destination_host.id).await;
        let _guard1 = lock.lock().await;

        tracing::trace!(
            "Consolidating host {:?} into host {:?}",
            other_host,
            destination_host
        );

        // Get interfaces and ports for both hosts
        let dest_interfaces = self
            .interface_service
            .get_for_host(&destination_host.id)
            .await?;
        let other_interfaces = self.interface_service.get_for_host(&other_host.id).await?;

        let dest_ports = self.port_service.get_for_host(&destination_host.id).await?;
        let other_ports = self.port_service.get_for_host(&other_host.id).await?;

        // Build interface ID mapping: source_interface_id -> dest_interface_id
        // Transfer non-conflicting interfaces to destination
        let mut interface_id_map: HashMap<Uuid, Uuid> = HashMap::new();
        for other_iface in &other_interfaces {
            // Check for conflict: same (subnet_id + ip_address) or same MAC address
            let matching_dest_iface = dest_interfaces.iter().find(|dest_iface| {
                // Match by subnet + IP
                (dest_iface.base.subnet_id == other_iface.base.subnet_id
                    && dest_iface.base.ip_address == other_iface.base.ip_address)
                    // Or match by MAC if both have one
                    || (dest_iface.base.mac_address.is_some()
                        && dest_iface.base.mac_address == other_iface.base.mac_address)
            });

            if let Some(dest_iface) = matching_dest_iface {
                // Conflict: map source ID to destination ID
                tracing::debug!(
                    source_interface_id = %other_iface.id,
                    dest_interface_id = %dest_iface.id,
                    ip = %other_iface.base.ip_address,
                    "Interface conflict - mapping to existing destination interface"
                );
                interface_id_map.insert(other_iface.id, dest_iface.id);
            } else {
                // No conflict: transfer interface to destination host
                let mut transferred = other_iface.clone();
                transferred.base.host_id = destination_host.id;
                self.interface_service
                    .update(&mut transferred, authentication.clone())
                    .await?;
                tracing::debug!(
                    interface_id = %other_iface.id,
                    ip = %other_iface.base.ip_address,
                    "Transferred interface to destination host"
                );
                // Map to itself (ID unchanged, just host_id changed)
                interface_id_map.insert(other_iface.id, other_iface.id);
            }
        }

        // Build port ID mapping: source_port_id -> dest_port_id
        // Transfer non-conflicting ports to destination
        let mut port_id_map: HashMap<Uuid, Uuid> = HashMap::new();
        for other_port in &other_ports {
            let other_config = other_port.base.port_type.config();

            // Check for conflict: same (number + protocol)
            let matching_dest_port = dest_ports.iter().find(|dest_port| {
                let dest_config = dest_port.base.port_type.config();
                dest_config.number == other_config.number
                    && dest_config.protocol == other_config.protocol
            });

            if let Some(dest_port) = matching_dest_port {
                // Conflict: map source ID to destination ID
                tracing::debug!(
                    source_port_id = %other_port.id,
                    dest_port_id = %dest_port.id,
                    port = %other_config.number,
                    "Port conflict - mapping to existing destination port"
                );
                port_id_map.insert(other_port.id, dest_port.id);
            } else {
                // No conflict: transfer port to destination host
                let mut transferred =
                    other_port.with_host(destination_host.id, destination_host.base.network_id);
                self.port_service
                    .update(&mut transferred, authentication.clone())
                    .await?;
                tracing::debug!(
                    port_id = %other_port.id,
                    port = %other_config.number,
                    "Transferred port to destination host"
                );
                // Map to itself (ID unchanged, just host_id changed)
                port_id_map.insert(other_port.id, other_port.id);
            }
        }

        // Upsert host data (metadata merge)
        let updated_host = self
            .upsert_host(
                destination_host.clone(),
                other_host.clone(),
                authentication.clone(),
            )
            .await?;

        // Get services for both hosts
        let destination_services = self
            .service_service
            .get_all(EntityFilter::unfiltered().host_id(&destination_host.id))
            .await?;

        let other_services = self
            .service_service
            .get_all(EntityFilter::unfiltered().host_id(&other_host.id))
            .await?;

        // Transfer services, updating binding IDs using the maps
        for mut service in other_services {
            // Check for duplicate by name + service_definition
            let is_duplicate = destination_services.iter().any(|dest_svc| {
                dest_svc.base.name == service.base.name
                    && dest_svc.base.service_definition.id() == service.base.service_definition.id()
            });

            if is_duplicate {
                tracing::debug!(
                    service_name = %service.base.name,
                    service_def = %service.base.service_definition.id(),
                    "Skipping duplicate service during consolidation"
                );
                continue;
            }

            // Update host_id
            service.base.host_id = updated_host.id;
            service.base.network_id = updated_host.base.network_id;

            // Remap binding IDs using our maps
            for binding in &mut service.base.bindings {
                match &mut binding.base.binding_type {
                    BindingType::Interface { interface_id } => {
                        if let Some(&new_id) = interface_id_map.get(interface_id) {
                            *interface_id = new_id;
                        } else {
                            tracing::warn!(
                                service = %service.base.name,
                                interface_id = %interface_id,
                                "Interface not found in mapping during consolidation"
                            );
                        }
                    }
                    BindingType::Port {
                        port_id,
                        interface_id,
                    } => {
                        if let Some(&new_port_id) = port_id_map.get(port_id) {
                            *port_id = new_port_id;
                        } else {
                            tracing::warn!(
                                service = %service.base.name,
                                port_id = %port_id,
                                "Port not found in mapping during consolidation"
                            );
                        }
                        if let Some(iface_id) = interface_id {
                            if let Some(&new_iface_id) = interface_id_map.get(iface_id) {
                                *interface_id = Some(new_iface_id);
                            } else {
                                tracing::warn!(
                                    service = %service.base.name,
                                    interface_id = %iface_id,
                                    "Interface not found in mapping, falling back to all-interfaces"
                                );
                                *interface_id = None;
                            }
                        }
                    }
                }
            }

            self.service_service
                .update(&mut service, authentication.clone())
                .await
                .map_err(|e| {
                    tracing::error!(
                        service_id = %service.id,
                        service_name = %service.base.name,
                        "Failed to update service during consolidation: {}",
                        e
                    );
                    anyhow!(
                        "Failed to update service '{}' during consolidation: {}",
                        service.base.name,
                        e
                    )
                })?;
        }

        // Delete other host (remaining children that weren't transferred will cascade)
        self.delete_host(&other_host.id, authentication).await?;

        tracing::info!(
            source_host_id = %other_host.id,
            source_host_name = %other_host.base.name,
            dest_host_id = %updated_host.id,
            dest_host_name = %updated_host.base.name,
            interfaces_mapped = %interface_id_map.len(),
            ports_mapped = %port_id_map.len(),
            "Hosts consolidated"
        );

        // Return response with hydrated children
        let (interfaces, ports, services) = self.load_children_for_host(&updated_host.id).await?;
        Ok(HostResponse::from_host_with_children(
            updated_host,
            interfaces,
            ports,
            services,
        ))
    }

    /// Delete a host (children cascade via FK)
    pub async fn delete_host(&self, id: &Uuid, authentication: AuthenticatedEntity) -> Result<()> {
        // Can't delete host with daemon
        if self
            .daemon_service
            .get_one(EntityFilter::unfiltered().host_id(id))
            .await?
            .is_some()
        {
            return Err(ValidationError::new(
                "Can't delete a host with an associated daemon. Delete the daemon first.",
            )
            .into());
        }

        let host = self
            .get_by_id(id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Host {} not found", id))?;

        let lock = self.get_host_lock(id).await;
        let _guard = lock.lock().await;

        // Delete host - children cascade via ON DELETE CASCADE
        self.storage().delete(id).await?;

        let trigger_stale = host.triggers_staleness(None);

        self.event_bus()
            .publish_entity(EntityEvent {
                id: Uuid::new_v4(),
                entity_id: host.id(),
                network_id: self.get_network_id(&host),
                organization_id: self.get_organization_id(&host),
                entity_type: host.into(),
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
