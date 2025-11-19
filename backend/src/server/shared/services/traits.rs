use async_trait::async_trait;
use chrono::Utc;
use std::{fmt::Display, sync::Arc};
use uuid::Uuid;

use crate::server::{
    auth::middleware::AuthenticatedEntity,
    shared::{
        entities::Entity,
        events::{
            bus::EventBus,
            types::{EntityEvent, EntityOperation},
        },
        storage::{
            filter::EntityFilter,
            generic::GenericPostgresStorage,
            traits::{StorableEntity, Storage},
        },
    },
};

/// Helper trait for services that use generic storage
/// Provides default implementations for common CRUD operations
#[async_trait]
pub trait CrudService<T: StorableEntity>
where
    T: Display,
{
    /// Get reference to the storage
    fn storage(&self) -> &Arc<GenericPostgresStorage<T>>;

    /// Event bus and helpers
    fn event_bus(&self) -> &Arc<EventBus>;

    fn entity_type() -> Entity;
    fn get_network_id(&self, entity: &T) -> Option<Uuid>;
    fn get_organization_id(&self, entity: &T) -> Option<Uuid>;

    /// Get entity by ID
    async fn get_by_id(&self, id: &Uuid) -> Result<Option<T>, anyhow::Error> {
        self.storage().get_by_id(id).await
    }

    /// Get all entities with filter
    async fn get_all(&self, filter: EntityFilter) -> Result<Vec<T>, anyhow::Error> {
        self.storage().get_all(filter).await
    }

    /// Get one entities with filter
    async fn get_one(&self, filter: EntityFilter) -> Result<Option<T>, anyhow::Error> {
        self.storage().get_one(filter).await
    }

    /// Delete entity by ID
    async fn delete(
        &self,
        id: &Uuid,
        authentication: AuthenticatedEntity,
    ) -> Result<(), anyhow::Error> {
        if let Some(entity) = self.get_by_id(id).await? {
            self.storage().delete(id).await?;

            self.event_bus()
                .publish(EntityEvent {
                    id: Uuid::new_v4(),
                    entity_type: Self::entity_type(),
                    entity_id: *id,
                    network_id: self.get_network_id(&entity),
                    organization_id: self.get_organization_id(&entity),
                    operation: EntityOperation::Deleted,
                    timestamp: Utc::now(),
                    metadata: serde_json::json!({}),
                    authentication,
                })
                .await?;

            tracing::info!(
                entity_type = T::table_name(),
                entity_id = %id,
                "Entity deleted"
            );

            Ok(())
        } else {
            Err(anyhow::anyhow!(
                "{} with id {} not found",
                T::table_name(),
                id
            ))
        }
    }

    /// Create entity
    async fn create(
        &self,
        entity: T,
        authentication: AuthenticatedEntity,
    ) -> Result<T, anyhow::Error> {
        let entity = if entity.id() == Uuid::nil() {
            T::new(entity.get_base())
        } else {
            entity
        };

        let created = self.storage().create(&entity).await?;

        self.event_bus()
            .publish(EntityEvent {
                id: Uuid::new_v4(),
                entity_type: Self::entity_type(),
                entity_id: created.id(),
                network_id: self.get_network_id(&created),
                organization_id: self.get_organization_id(&created),
                operation: EntityOperation::Created,
                timestamp: Utc::now(),
                metadata: serde_json::json!({}),
                authentication,
            })
            .await?;

        tracing::info!(
            entity_type = T::table_name(),
            entity_id = %created.id(),
            "Entity created"
        );

        Ok(created)
    }

    /// Update entity
    async fn update(
        &self,
        entity: &mut T,
        authentication: AuthenticatedEntity,
    ) -> Result<T, anyhow::Error> {
        let updated = self.storage().update(entity).await?;

        self.event_bus()
            .publish(EntityEvent {
                id: Uuid::new_v4(),
                entity_type: Self::entity_type(),
                entity_id: updated.id(),
                network_id: self.get_network_id(&updated),
                organization_id: self.get_organization_id(&updated),
                operation: EntityOperation::Updated,
                timestamp: Utc::now(),
                metadata: serde_json::json!({}),
                authentication,
            })
            .await?;

        tracing::info!(
            entity_type = T::table_name(),
            entity_id = %updated.id(),
            entity_name = %updated,
            "Entity updated"
        );

        Ok(updated)
    }
}
