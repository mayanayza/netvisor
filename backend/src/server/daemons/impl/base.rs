use std::fmt::Display;

use chrono::{DateTime, Utc};
use clap::ValueEnum;
use serde::{Deserialize, Serialize};
use strum::Display;
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

use crate::server::{
    daemons::r#impl::api::DaemonCapabilities, shared::entities::ChangeTriggersTopologyStaleness,
};

#[derive(
    Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema, Validate,
)]
pub struct DaemonBase {
    pub host_id: Uuid,
    pub network_id: Uuid,
    #[serde(default)]
    #[schema(read_only, required)]
    pub url: String,
    #[serde(default)]
    #[schema(read_only, required)]
    pub last_seen: DateTime<Utc>,
    #[serde(default)]
    #[schema(read_only, required)]
    pub capabilities: DaemonCapabilities,
    pub mode: DaemonMode,
    pub name: String,
    #[serde(default)]
    #[schema(required)]
    pub tags: Vec<Uuid>,
}

#[derive(
    Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema, Validate,
)]
pub struct Daemon {
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
    pub base: DaemonBase,
}

impl Daemon {
    pub fn suppress_logs(&self, other: &Self) -> bool {
        self.base.capabilities == other.base.capabilities
            && self.base.mode == other.base.mode
            && self.base.url == other.base.url
            && self.base.network_id == other.base.network_id
            && self.base.host_id == other.base.host_id
    }
}

impl Display for Daemon {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}: {}", self.base.url, self.id)
    }
}

#[derive(
    Debug,
    Display,
    Copy,
    Clone,
    Serialize,
    Deserialize,
    Default,
    PartialEq,
    Eq,
    ValueEnum,
    Hash,
    ToSchema,
)]
pub enum DaemonMode {
    #[default]
    Push,
    Pull,
}

impl ChangeTriggersTopologyStaleness<Daemon> for Daemon {
    fn triggers_staleness(&self, _other: Option<Daemon>) -> bool {
        false
    }
}
