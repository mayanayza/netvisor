use std::fmt::Display;

use crate::server::shared::entities::ChangeTriggersTopologyStaleness;
use crate::server::shared::types::api::serialize_sensitive_info;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

#[derive(
    Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema, Validate,
)]
pub struct ApiKeyBase {
    #[serde(default)]
    #[serde(serialize_with = "serialize_sensitive_info")]
    #[schema(read_only, required)]
    pub key: String,
    pub name: String,
    #[serde(default)]
    #[schema(read_only, required)]
    pub last_used: Option<DateTime<Utc>>,
    pub expires_at: Option<DateTime<Utc>>,
    pub network_id: Uuid,
    #[serde(default)]
    pub is_enabled: bool,
    #[serde(default)]
    #[schema(required)]
    pub tags: Vec<Uuid>,
}

#[derive(
    Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema, Validate,
)]
pub struct ApiKey {
    #[serde(default)]
    #[schema(read_only, required)]
    pub id: Uuid,
    #[serde(default)]
    #[schema(read_only, required)]
    pub updated_at: DateTime<Utc>,
    #[serde(default)]
    #[schema(read_only, required)]
    pub created_at: DateTime<Utc>,
    #[serde(flatten)]
    #[validate(nested)]
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
