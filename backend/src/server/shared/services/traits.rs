use async_trait::async_trait;
use std::{fmt::Display, sync::Arc};
use uuid::Uuid;

use crate::server::shared::storage::{
    filter::EntityFilter,
    generic::GenericPostgresStorage,
    traits::{StorableEntity, Storage},
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
    async fn delete(&self, id: &Uuid) -> Result<(), anyhow::Error> {
        // ADD logging before deletion
        if let Some(entity) = self.get_by_id(id).await? {
            tracing::info!(
                entity_type = T::table_name(),
                entity_id = %id,
                entity_name = %entity,
                "Deleting entity"
            );
            self.storage().delete(id).await?;
            tracing::debug!(
                entity_type = T::table_name(),
                entity_id = %id,
                "Entity deleted successfully"
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
    async fn create(&self, entity: T) -> Result<T, anyhow::Error> {
        let entity = if entity.id() == Uuid::nil() {
            T::new(entity.get_base())
        } else {
            entity
        };

        // ADD logging before creation
        tracing::debug!(
            entity_type = T::table_name(),
            entity_id = %entity.id(),
            entity_name = %entity,
            "Creating entity"
        );

        let created = self.storage().create(&entity).await?;

        tracing::info!(
            entity_type = T::table_name(),
            entity_id = %created.id(),
            entity_name = %created,
            "Entity created"
        );

        Ok(created)
    }

    /// Update entity
    async fn update(&self, entity: &mut T) -> Result<T, anyhow::Error> {
        tracing::debug!(
            entity_type = T::table_name(),
            entity_id = %entity.id(),
            entity_name = %entity,
            "Updating entity"
        );

        let updated = self.storage().update(entity).await?;

        tracing::info!(
            entity_type = T::table_name(),
            entity_id = %updated.id(),
            entity_name = %updated,
            "Entity updated"
        );

        Ok(updated)
    }
}
