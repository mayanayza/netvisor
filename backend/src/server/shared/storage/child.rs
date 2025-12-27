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

    /// Save children for a parent (syncs children, preserving IDs where possible)
    ///
    /// This uses a sync pattern instead of delete-all + insert-all to preserve
    /// existing entity IDs. This is important for entities with foreign key
    /// references (like bindings referenced by group_bindings with ON DELETE CASCADE).
    ///
    /// Also preserves `created_at` timestamps for existing children and generates
    /// new UUIDs for children with nil IDs.
    ///
    /// Returns the saved entities with their actual IDs (including generated ones).
    pub async fn save_for_parent(&self, parent_id: &Uuid, children: &[T]) -> Result<Vec<T>> {
        // Fetch full existing children to get their created_at timestamps
        let existing_children = self.get_for_parent(parent_id).await?;
        let existing_by_id: std::collections::HashMap<Uuid, T> =
            existing_children.into_iter().map(|c| (c.id(), c)).collect();

        let current_ids: std::collections::HashSet<Uuid> = existing_by_id.keys().cloned().collect();

        // Compute which IDs are in the new set (excluding nil UUIDs which will get new IDs)
        let new_ids: std::collections::HashSet<Uuid> = children
            .iter()
            .filter(|c| !c.id().is_nil())
            .map(|c| c.id())
            .collect();

        // Delete only children that are no longer present
        let ids_to_delete: Vec<Uuid> = current_ids.difference(&new_ids).cloned().collect();
        if !ids_to_delete.is_empty() {
            Storage::delete_many(&self.inner, &ids_to_delete).await?;
        }

        // Upsert children (insert or update), collecting the saved entities
        let mut saved: Vec<T> = Vec::with_capacity(children.len());
        for child in children {
            let mut child_clone = child.clone();

            let saved_child = if child.id().is_nil() {
                // New child with nil UUID - generate a proper ID
                child_clone.set_id(Uuid::new_v4());
                Storage::create(&self.inner, &child_clone).await?
            } else if let Some(existing) = existing_by_id.get(&child.id()) {
                // Existing child - preserve created_at from database
                child_clone.set_created_at(existing.created_at());
                Storage::update(&self.inner, &mut child_clone).await?
            } else {
                // New child with explicit ID
                Storage::create(&self.inner, &child_clone).await?
            };
            saved.push(saved_child);
        }

        Ok(saved)
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
    /// Save children for a parent, returning the saved entities with actual IDs
    async fn save_for_parent(&self, parent_id: &Uuid, children: &[T]) -> Result<Vec<T>>;
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

    async fn save_for_parent(&self, parent_id: &Uuid, children: &[T]) -> Result<Vec<T>> {
        self.save_for_parent(parent_id, children).await
    }

    async fn delete_for_parent(&self, parent_id: &Uuid) -> Result<()> {
        self.delete_for_parent(parent_id).await
    }
}
