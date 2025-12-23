use std::{collections::HashMap, fmt::Display};

use anyhow::Result;
use async_trait::async_trait;
use sqlx::PgPool;
use uuid::Uuid;

use super::{
    generic::GenericPostgresStorage,
    traits::{StorableEntity, Storage},
};

/// Trait for entities that are children of a parent entity and stored in a separate table.
/// Extends StorableEntity to reuse all the standard CRUD infrastructure while adding
/// parent-scoped batch operations.
///
/// The key addition is the "replace all" pattern: when saving via `save_for_parent`,
/// all existing children for that parent are deleted and the new set is inserted.
pub trait ChildStorableEntity: StorableEntity {
    /// The column name for the parent foreign key (e.g., "host_id", "service_id")
    fn parent_column() -> &'static str;

    /// Get the parent ID for this entity
    fn parent_id(&self) -> Uuid;
}

/// Generic storage implementation for child entities.
/// Wraps GenericPostgresStorage and adds parent-scoped batch operations.
pub struct GenericChildStorage<T: ChildStorableEntity + Display> {
    pool: PgPool,
    inner: GenericPostgresStorage<T>,
}

impl<T: ChildStorableEntity + Display> GenericChildStorage<T> {
    pub fn new(pool: PgPool) -> Self {
        Self {
            inner: GenericPostgresStorage::new(pool.clone()),
            pool,
        }
    }

    /// Get the inner storage for standard CRUD operations
    pub fn inner(&self) -> &GenericPostgresStorage<T> {
        &self.inner
    }

    /// Get all children for a single parent
    pub async fn get_for_parent(&self, parent_id: &Uuid) -> Result<Vec<T>> {
        let query_str = format!(
            "SELECT * FROM {} WHERE {} = $1",
            T::table_name(),
            T::parent_column()
        );

        let rows = sqlx::query(&query_str)
            .bind(parent_id)
            .fetch_all(&self.pool)
            .await?;

        rows.into_iter().map(|row| T::from_row(&row)).collect()
    }

    /// Get children for multiple parents (batch loading)
    /// Returns a map of parent_id -> children
    pub async fn get_for_parents(&self, parent_ids: &[Uuid]) -> Result<HashMap<Uuid, Vec<T>>> {
        if parent_ids.is_empty() {
            return Ok(HashMap::new());
        }

        let query_str = format!(
            "SELECT * FROM {} WHERE {} = ANY($1)",
            T::table_name(),
            T::parent_column()
        );

        let rows = sqlx::query(&query_str)
            .bind(parent_ids)
            .fetch_all(&self.pool)
            .await?;

        let mut result: HashMap<Uuid, Vec<T>> = HashMap::new();
        for row in rows {
            let entity = T::from_row(&row)?;
            let parent_id = entity.parent_id();
            result.entry(parent_id).or_default().push(entity);
        }

        Ok(result)
    }

    /// Save children for a parent (replaces all existing children)
    pub async fn save_for_parent(&self, parent_id: &Uuid, children: &[T]) -> Result<()> {
        // Delete existing children for this parent
        let delete_query = format!(
            "DELETE FROM {} WHERE {} = $1",
            T::table_name(),
            T::parent_column()
        );
        sqlx::query(&delete_query)
            .bind(parent_id)
            .execute(&self.pool)
            .await?;

        // Insert new children using the inner storage via Storage trait
        for child in children {
            Storage::create(&self.inner, child).await?;
        }

        Ok(())
    }

    /// Delete all children for a parent
    pub async fn delete_for_parent(&self, parent_id: &Uuid) -> Result<()> {
        let query_str = format!(
            "DELETE FROM {} WHERE {} = $1",
            T::table_name(),
            T::parent_column()
        );

        sqlx::query(&query_str)
            .bind(parent_id)
            .execute(&self.pool)
            .await?;

        Ok(())
    }
}

/// Async trait for child storage operations (for use with dependency injection)
#[async_trait]
pub trait ChildStorage<T: ChildStorableEntity + Display>: Send + Sync {
    async fn get_for_parent(&self, parent_id: &Uuid) -> Result<Vec<T>>;
    async fn get_for_parents(&self, parent_ids: &[Uuid]) -> Result<HashMap<Uuid, Vec<T>>>;
    async fn save_for_parent(&self, parent_id: &Uuid, children: &[T]) -> Result<()>;
    async fn delete_for_parent(&self, parent_id: &Uuid) -> Result<()>;
}

#[async_trait]
impl<T: ChildStorableEntity + Display> ChildStorage<T> for GenericChildStorage<T> {
    async fn get_for_parent(&self, parent_id: &Uuid) -> Result<Vec<T>> {
        self.get_for_parent(parent_id).await
    }

    async fn get_for_parents(&self, parent_ids: &[Uuid]) -> Result<HashMap<Uuid, Vec<T>>> {
        self.get_for_parents(parent_ids).await
    }

    async fn save_for_parent(&self, parent_id: &Uuid, children: &[T]) -> Result<()> {
        self.save_for_parent(parent_id, children).await
    }

    async fn delete_for_parent(&self, parent_id: &Uuid) -> Result<()> {
        self.delete_for_parent(parent_id).await
    }
}
