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

    /// Create entity
    async fn create(&self, entity: T) -> Result<T, anyhow::Error> {
        // User-created have uuid nil
        let entity = if entity.id() == Uuid::nil() {
            T::new(entity.get_base())
        } else {
            entity
        };

        self.storage().create(&entity).await
    }

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

    /// Update entity
    async fn update(&self, entity: &mut T) -> Result<T, anyhow::Error> {
        self.storage().update(entity).await
    }

    /// Delete entity by ID
    async fn delete(&self, id: &Uuid) -> Result<(), anyhow::Error> {
        self.storage().delete(id).await
    }
}
