use anyhow::Result;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::{Row, postgres::PgRow};
use std::fmt::Display;
use uuid::Uuid;

use crate::server::shared::storage::{
    child::ChildStorableEntity,
    traits::{SqlValue, StorableEntity},
};

/// The base data for a GroupBinding junction record
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GroupBindingBase {
    pub group_id: Uuid,
    pub binding_id: Uuid,
    pub position: i32,
}

impl GroupBindingBase {
    pub fn new(group_id: Uuid, binding_id: Uuid, position: i32) -> Self {
        Self {
            group_id,
            binding_id,
            position,
        }
    }
}

/// A junction record linking a group to a binding with a position
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GroupBinding {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub base: GroupBindingBase,
}

impl GroupBinding {
    pub fn new(base: GroupBindingBase) -> Self {
        Self {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            base,
        }
    }

    pub fn group_id(&self) -> Uuid {
        self.base.group_id
    }

    pub fn binding_id(&self) -> Uuid {
        self.base.binding_id
    }

    pub fn position(&self) -> i32 {
        self.base.position
    }
}

impl Display for GroupBinding {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "GroupBinding(group={}, binding={}, pos={})",
            self.base.group_id, self.base.binding_id, self.base.position
        )
    }
}

impl StorableEntity for GroupBinding {
    type BaseData = GroupBindingBase;

    fn table_name() -> &'static str {
        "group_bindings"
    }

    fn new(base: Self::BaseData) -> Self {
        GroupBinding::new(base)
    }

    fn get_base(&self) -> Self::BaseData {
        self.base.clone()
    }

    fn id(&self) -> Uuid {
        self.id
    }

    fn network_id(&self) -> Option<Uuid> {
        None // Junction table doesn't have network_id
    }

    fn organization_id(&self) -> Option<Uuid> {
        None
    }

    fn created_at(&self) -> DateTime<Utc> {
        self.created_at
    }

    fn updated_at(&self) -> DateTime<Utc> {
        self.created_at // Junction table doesn't have updated_at
    }

    fn set_updated_at(&mut self, _time: DateTime<Utc>) {
        // No-op for junction table
    }

    fn to_params(&self) -> Result<(Vec<&'static str>, Vec<SqlValue>)> {
        Ok((
            vec!["id", "group_id", "binding_id", "position", "created_at"],
            vec![
                SqlValue::Uuid(self.id),
                SqlValue::Uuid(self.base.group_id),
                SqlValue::Uuid(self.base.binding_id),
                SqlValue::I32(self.base.position),
                SqlValue::Timestamp(self.created_at),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self> {
        Ok(GroupBinding {
            id: row.get("id"),
            created_at: row.get("created_at"),
            base: GroupBindingBase {
                group_id: row.get("group_id"),
                binding_id: row.get("binding_id"),
                position: row.get("position"),
            },
        })
    }
}

impl ChildStorableEntity for GroupBinding {
    fn parent_column() -> &'static str {
        "group_id"
    }

    fn parent_id(&self) -> Uuid {
        self.base.group_id
    }
}
