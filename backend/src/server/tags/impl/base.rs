use std::fmt::Display;

use crate::server::shared::{
    entities::ChangeTriggersTopologyStaleness, types::api::deserialize_empty_string_as_none,
};
use chrono::DateTime;
use chrono::Utc;
use serde::Deserialize;
use serde::Serialize;
use ts_rs::TS;
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

#[derive(Debug, Clone, Validate, Serialize, Deserialize, Eq, PartialEq, Hash, ToSchema, TS)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct TagBase {
    #[validate(length(min = 0, max = 100))]
    pub name: String,
    #[serde(deserialize_with = "deserialize_empty_string_as_none")]
    pub description: Option<String>,
    pub color: String,
    pub organization_id: Uuid,
}

impl Default for TagBase {
    fn default() -> Self {
        Self {
            name: "New Tag".to_string(),
            description: None,
            color: "yellow".to_string(),
            organization_id: Uuid::nil(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Eq, PartialEq, Hash, Default, ToSchema, TS)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
#[schema(example = crate::server::shared::types::examples::tag)]
pub struct Tag {
    #[serde(default)]
    #[schema(read_only)]
    pub id: Uuid,
    #[serde(default)]
    #[schema(read_only)]
    pub created_at: DateTime<Utc>,
    #[serde(default)]
    #[schema(read_only)]
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    pub base: TagBase,
}

impl ChangeTriggersTopologyStaleness<Tag> for Tag {
    fn triggers_staleness(&self, _other: Option<Tag>) -> bool {
        false
    }
}

impl Display for Tag {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Tag {}: {}", self.base.name, self.id)
    }
}
