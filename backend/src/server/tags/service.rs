use uuid::Uuid;

use crate::server::{
    shared::{
        events::bus::EventBus,
        services::traits::{CrudService, EventBusService},
        storage::generic::GenericPostgresStorage,
    },
    tags::r#impl::base::Tag,
};
use std::sync::Arc;

pub struct TagService {
    storage: Arc<GenericPostgresStorage<Tag>>,
    event_bus: Arc<EventBus>,
}

impl EventBusService<Tag> for TagService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, _entity: &Tag) -> Option<Uuid> {
        None
    }
    fn get_organization_id(&self, _entity: &Tag) -> Option<Uuid> {
        None
    }
}

impl CrudService<Tag> for TagService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Tag>> {
        &self.storage
    }
}

impl TagService {
    pub fn new(storage: Arc<GenericPostgresStorage<Tag>>, event_bus: Arc<EventBus>) -> Self {
        Self { storage, event_bus }
    }
}
