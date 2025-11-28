use async_trait::async_trait;
use chrono::Utc;
use std::sync::Arc;
use uuid::Uuid;

use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    groups::r#impl::base::Group,
    shared::{
        entities::ChangeTriggersTopologyStaleness,
        events::{
            bus::EventBus,
            types::{EntityEvent, EntityOperation},
        },
        services::traits::{CrudService, EventBusService},
        storage::{
            generic::GenericPostgresStorage,
            traits::{StorableEntity, Storage},
        },
    },
};

pub struct GroupService {
    group_storage: Arc<GenericPostgresStorage<Group>>,
    event_bus: Arc<EventBus>,
}

impl EventBusService<Group> for GroupService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, entity: &Group) -> Option<Uuid> {
        Some(entity.base.network_id)
    }
    fn get_organization_id(&self, _entity: &Group) -> Option<Uuid> {
        None
    }
}

#[async_trait]
impl CrudService<Group> for GroupService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Group>> {
        &self.group_storage
    }

    async fn update(
        &self,
        updates: &mut Group,
        authentication: AuthenticatedEntity,
    ) -> Result<Group, anyhow::Error> {
        let current = self
            .get_by_id(&updates.id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Could not find group to update"))?;

        let updated = self.storage().update(updates).await?;
        let trigger_stale = updated.triggers_staleness(Some(current));

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
