use anyhow::Result;
use async_trait::async_trait;
use chrono::Utc;
use std::sync::Arc;
use uuid::Uuid;

use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    group_bindings::GroupBindingStorage,
    groups::r#impl::base::Group,
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
    },
};

pub struct GroupService {
    group_storage: Arc<GenericPostgresStorage<Group>>,
    binding_storage: Arc<GroupBindingStorage>,
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

    async fn get_by_id(&self, id: &Uuid) -> Result<Option<Group>, anyhow::Error> {
        let group = self.storage().get_by_id(id).await?;
        match group {
            Some(mut g) => {
                g.base.binding_ids = self.binding_storage.get_for_group(&g.id).await?;
                Ok(Some(g))
            }
            None => Ok(None),
        }
    }

    async fn get_all(&self, filter: EntityFilter) -> Result<Vec<Group>, anyhow::Error> {
        let mut groups = self.storage().get_all(filter).await?;
        if groups.is_empty() {
            return Ok(groups);
        }

        let group_ids: Vec<Uuid> = groups.iter().map(|g| g.id).collect();
        let bindings_map = self.binding_storage.get_for_groups(&group_ids).await?;

        for group in &mut groups {
            if let Some(binding_ids) = bindings_map.get(&group.id) {
                group.base.binding_ids = binding_ids.clone();
            }
        }

        Ok(groups)
    }

    async fn get_one(&self, filter: EntityFilter) -> Result<Option<Group>, anyhow::Error> {
        let group = self.storage().get_one(filter).await?;
        match group {
            Some(mut g) => {
                g.base.binding_ids = self.binding_storage.get_for_group(&g.id).await?;
                Ok(Some(g))
            }
            None => Ok(None),
        }
    }

    async fn create(
        &self,
        group: Group,
        authentication: AuthenticatedEntity,
    ) -> Result<Group, anyhow::Error> {
        let group = if group.id == Uuid::nil() {
            Group::new(group.base)
        } else {
            group
        };

        let created = self.storage().create(&group).await?;

        // Save binding IDs to junction table
        self.binding_storage
            .save_for_group(&created.id, &group.base.binding_ids)
            .await?;

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

        // Return with binding_ids populated
        let mut result = created;
        result.base.binding_ids = group.base.binding_ids;
        Ok(result)
    }

    async fn update(
        &self,
        group: &mut Group,
        authentication: AuthenticatedEntity,
    ) -> Result<Group, anyhow::Error> {
        let current_group = self
            .get_by_id(&group.id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Could not find group"))?;

        let updated = self.storage().update(group).await?;

        // Save binding IDs to junction table
        self.binding_storage
            .save_for_group(&updated.id, &group.base.binding_ids)
            .await?;

        let trigger_stale = updated.triggers_staleness(Some(current_group));

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

        // Return with binding_ids populated
        let mut result = updated;
        result.base.binding_ids = group.base.binding_ids.clone();
        Ok(result)
    }
}

impl GroupService {
    pub fn new(
        group_storage: Arc<GenericPostgresStorage<Group>>,
        binding_storage: Arc<GroupBindingStorage>,
        event_bus: Arc<EventBus>,
    ) -> Self {
        Self {
            group_storage,
            binding_storage,
            event_bus,
        }
    }
}
