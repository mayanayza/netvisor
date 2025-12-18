use crate::server::shared::events::bus::EventBus;
use crate::server::shared::services::traits::EventBusService;
use crate::server::{
    organizations::r#impl::base::Organization,
    shared::{services::traits::CrudService, storage::generic::GenericPostgresStorage},
};
use async_trait::async_trait;
use std::sync::Arc;
use uuid::Uuid;

pub struct OrganizationService {
    storage: Arc<GenericPostgresStorage<Organization>>,
    event_bus: Arc<EventBus>,
}

impl EventBusService<Organization> for OrganizationService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, _entity: &Organization) -> Option<Uuid> {
        None
    }
    fn get_organization_id(&self, entity: &Organization) -> Option<Uuid> {
        Some(entity.id)
    }
}

#[async_trait]
impl CrudService<Organization> for OrganizationService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Organization>> {
        &self.storage
    }
}

impl OrganizationService {
    pub fn new(
        storage: Arc<GenericPostgresStorage<Organization>>,
        event_bus: Arc<EventBus>,
    ) -> Self {
        Self { storage, event_bus }
    }
}
