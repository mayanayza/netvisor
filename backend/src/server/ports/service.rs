use anyhow::Result;
use std::{collections::HashMap, sync::Arc};
use uuid::Uuid;

use crate::server::{
    ports::r#impl::base::Port,
    shared::{
        events::bus::EventBus,
        services::traits::{ChildCrudService, CrudService, EventBusService},
        storage::{generic::GenericPostgresStorage, traits::Storage},
    },
};

pub struct PortService {
    storage: Arc<GenericPostgresStorage<Port>>,
    event_bus: Arc<EventBus>,
}

impl EventBusService<Port> for PortService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, entity: &Port) -> Option<Uuid> {
        Some(entity.base.network_id)
    }

    fn get_organization_id(&self, _entity: &Port) -> Option<Uuid> {
        None
    }
}

impl CrudService<Port> for PortService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Port>> {
        &self.storage
    }
}

impl ChildCrudService<Port> for PortService {}

impl PortService {
    pub fn new(storage: Arc<GenericPostgresStorage<Port>>, event_bus: Arc<EventBus>) -> Self {
        Self { storage, event_bus }
    }

    /// Get all ports for a specific host (alias for get_for_parent)
    pub async fn get_for_host(&self, host_id: &Uuid) -> Result<Vec<Port>> {
        self.get_for_parent(host_id).await
    }

    /// Get ports for multiple hosts (alias for get_for_parents)
    pub async fn get_for_hosts(&self, host_ids: &[Uuid]) -> Result<HashMap<Uuid, Vec<Port>>> {
        self.get_for_parents(host_ids).await
    }

    /// Create a port directly (bypasses event publishing for batch operations)
    pub async fn create_direct(&self, port: &Port) -> Result<Port> {
        self.storage.create(port).await
    }

    /// Delete all ports for a host (alias for delete_for_parent)
    pub async fn delete_for_host(&self, host_id: &Uuid) -> Result<usize> {
        self.delete_for_parent(host_id).await
    }
}
