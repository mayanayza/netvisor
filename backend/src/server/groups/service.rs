use async_trait::async_trait;
use std::sync::Arc;
use uuid::Uuid;

use crate::server::{
    groups::r#impl::base::Group,
    shared::{
        entities::Entity, events::bus::EventBus, services::traits::CrudService,
        storage::generic::GenericPostgresStorage,
    },
};

pub struct GroupService {
    group_storage: Arc<GenericPostgresStorage<Group>>,
    event_bus: Arc<EventBus>,
}

#[async_trait]
impl CrudService<Group> for GroupService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Group>> {
        &self.group_storage
    }

    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn entity_type() -> Entity {
        Entity::Group
    }
    fn get_network_id(&self, entity: &Group) -> Option<Uuid> {
        Some(entity.base.network_id)
    }
    fn get_organization_id(&self, _entity: &Group) -> Option<Uuid> {
        None
    }
}

impl GroupService {
    pub fn new(
        group_storage: Arc<GenericPostgresStorage<Group>>,
        event_bus: Arc<EventBus>,
    ) -> Self {
        Self {
            group_storage,
            event_bus,
        }
    }
}
