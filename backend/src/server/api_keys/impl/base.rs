use std::fmt::Display;

use crate::server::shared::entities::ChangeTriggersTopologyStaleness;
use crate::server::shared::types::api::serialize_sensitive_info;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use ts_rs::TS;
use utoipa::ToSchema;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema, TS)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct ApiKeyBase {
    #[serde(serialize_with = "serialize_sensitive_info")]
    #[schema(read_only)]
    pub key: String,
    pub name: String,
    #[schema(read_only)]
    pub last_used: Option<DateTime<Utc>>,
    pub expires_at: Option<DateTime<Utc>>,
    pub network_id: Uuid,
    #[serde(default)]
    pub is_enabled: bool,
    #[serde(default)]
    pub tags: Vec<Uuid>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema, TS)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct ApiKey {
    #[serde(default)]
    #[schema(read_only)]
    pub id: Uuid,
    #[serde(default)]
    #[schema(read_only)]
    pub updated_at: DateTime<Utc>,
    #[serde(default)]
    #[schema(read_only)]
    pub created_at: DateTime<Utc>,
    #[serde(flatten)]
    pub base: ApiKeyBase,
}

impl ApiKey {
    pub fn suppress_logs(&self, other: &Self) -> bool {
        self.base.key == other.base.key
            && self.base.name == other.base.name
            && self.base.expires_at == other.base.expires_at
            && self.base.network_id == other.base.network_id
            && self.base.is_enabled == other.base.is_enabled
    }
}

impl Display for ApiKey {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}: {}", self.base.name, self.id)
    }
}

impl ChangeTriggersTopologyStaleness<ApiKey> for ApiKey {
    fn triggers_staleness(&self, _other: Option<ApiKey>) -> bool {
        false
    }
}
