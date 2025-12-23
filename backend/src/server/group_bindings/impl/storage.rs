use std::collections::HashMap;

use anyhow::Result;
use sqlx::PgPool;
use uuid::Uuid;

use crate::server::shared::storage::{
    filter::EntityFilter, generic::GenericPostgresStorage, traits::Storage,
};

use super::base::{GroupBinding, GroupBindingBase};

/// Storage operations for group_bindings junction table.
/// Manages the ordered list of binding IDs for each group.
pub struct GroupBindingStorage {
    storage: GenericPostgresStorage<GroupBinding>,
}

impl GroupBindingStorage {
    pub fn new(pool: PgPool) -> Self {
        Self {
            storage: GenericPostgresStorage::new(pool),
        }
    }

    /// Get all binding IDs for a single group, ordered by position
    pub async fn get_for_group(&self, group_id: &Uuid) -> Result<Vec<Uuid>> {
        let filter = EntityFilter::unfiltered().group_id(group_id);
        let group_bindings = self.storage.get_all_ordered(filter, "position ASC").await?;
        Ok(group_bindings.iter().map(|gb| gb.binding_id()).collect())
    }

    /// Get binding IDs for multiple groups (batch loading)
    pub async fn get_for_groups(&self, group_ids: &[Uuid]) -> Result<HashMap<Uuid, Vec<Uuid>>> {
        if group_ids.is_empty() {
            return Ok(HashMap::new());
        }

        let filter = EntityFilter::unfiltered().group_ids(group_ids);
        let group_bindings = self
            .storage
            .get_all_ordered(filter, "group_id ASC, position ASC")
            .await?;

        let mut result: HashMap<Uuid, Vec<Uuid>> = HashMap::new();
        for gb in group_bindings {
            result
                .entry(gb.group_id())
                .or_default()
                .push(gb.binding_id());
        }

        Ok(result)
    }

    /// Save binding IDs for a group (replaces all existing)
    pub async fn save_for_group(&self, group_id: &Uuid, binding_ids: &[Uuid]) -> Result<()> {
        // Delete existing bindings for this group
        self.delete_for_group(group_id).await?;

        // Insert new bindings with position
        for (position, binding_id) in binding_ids.iter().enumerate() {
            let group_binding = GroupBinding::new(GroupBindingBase::new(
                *group_id,
                *binding_id,
                position as i32,
            ));
            self.storage.create(&group_binding).await?;
        }

        Ok(())
    }

    /// Delete all binding associations for a group
    pub async fn delete_for_group(&self, group_id: &Uuid) -> Result<()> {
        let filter = EntityFilter::unfiltered().group_id(group_id);
        self.storage.delete_by_filter(filter).await?;
        Ok(())
    }

    /// Remove a specific binding from all groups
    pub async fn remove_binding(&self, binding_id: &Uuid) -> Result<()> {
        let filter = EntityFilter::unfiltered().binding_id(binding_id);
        self.storage.delete_by_filter(filter).await?;
        Ok(())
    }
}
