use std::fmt::Display;

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize, Serializer};
use uuid::Uuid;

use crate::server::shared::entities::ChangeTriggersTopologyStaleness;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct ApiKeyBase {
    #[serde(serialize_with = "serialize_api_key_status")]
    pub key: String,
    pub name: String,
    pub last_used: Option<DateTime<Utc>>,
    pub expires_at: Option<DateTime<Utc>>,
    pub network_id: Uuid,
    pub is_enabled: bool,
}

fn serialize_api_key_status<S>(_key: &String, serializer: S) -> Result<S::Ok, S::Error>
where
    S: Serializer,
{
    serializer.serialize_str("***REDACTED***")
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct ApiKey {
    pub id: Uuid,
    pub updated_at: DateTime<Utc>,
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
