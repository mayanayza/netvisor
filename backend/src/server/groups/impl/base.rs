use std::fmt::Display;

use crate::server::shared::entities::ChangeTriggersTopologyStaleness;
use crate::server::shared::types::entities::EntitySource;
use crate::server::topology::types::edges::EdgeStyle;
use crate::server::{
    groups::r#impl::types::GroupType, shared::types::api::deserialize_empty_string_as_none,
};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

#[derive(Debug, Clone, Serialize, Validate, Deserialize, PartialEq, Eq, Hash, Default, ToSchema)]
pub struct GroupBase {
    #[validate(length(min = 0, max = 100))]
    pub name: String,
    pub network_id: Uuid,
    #[serde(deserialize_with = "deserialize_empty_string_as_none")]
    #[validate(length(min = 0, max = 500))]
    pub description: Option<String>,
    pub group_type: GroupType,
    /// Ordered list of binding IDs for this group
    #[serde(default)]
    pub binding_ids: Vec<Uuid>,
    pub source: EntitySource,
    pub color: String,
    #[serde(default)]
    pub edge_style: EdgeStyle,
    #[serde(default)]
    pub tags: Vec<Uuid>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema)]
#[schema(example = crate::server::shared::types::examples::group)]
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

impl Group {
    pub fn bindings(&self) -> Vec<Uuid> {
        self.base.binding_ids.clone()
    }
}

impl ChangeTriggersTopologyStaleness<Group> for Group {
    fn triggers_staleness(&self, other: Option<Group>) -> bool {
        if let Some(other_group) = other {
            self.bindings() != other_group.bindings()
        } else {
            true
        }
    }
}
