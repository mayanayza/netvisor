use std::fmt::Display;

use crate::server::shared::types::entities::EntitySource;
use crate::server::topology::types::edges::EdgeStyle;
use crate::server::{
    groups::r#impl::types::GroupType, shared::types::api::deserialize_empty_string_as_none,
};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use validator::Validate;

#[derive(Debug, Clone, Serialize, Validate, Deserialize)]
pub struct GroupBase {
    #[validate(length(min = 0, max = 100))]
    pub name: String,
    pub network_id: Uuid,
    #[serde(deserialize_with = "deserialize_empty_string_as_none")]
    #[validate(length(min = 0, max = 500))]
    pub description: Option<String>,
    #[serde(flatten)]
    pub group_type: GroupType,
    pub source: EntitySource,
    pub color: String,
    #[serde(default)]
    pub edge_style: EdgeStyle,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Group {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    pub base: GroupBase,
}

impl Display for Group {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Group {}: {}", self.base.name, self.id)
    }
}
