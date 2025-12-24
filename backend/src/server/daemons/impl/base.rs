use std::fmt::Display;

use chrono::{DateTime, Utc};
use clap::ValueEnum;
use serde::{Deserialize, Serialize};
use strum::Display;
use ts_rs::TS;
use utoipa::ToSchema;
use uuid::Uuid;

use crate::server::{
    daemons::r#impl::api::DaemonCapabilities, shared::entities::ChangeTriggersTopologyStaleness,
};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema, TS)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct DaemonBase {
    pub host_id: Uuid,
    pub network_id: Uuid,
    #[schema(read_only)]
    pub url: String,
    #[serde(default)]
    #[schema(read_only)]
    pub last_seen: DateTime<Utc>,
    #[serde(default)]
    #[schema(read_only)]
    pub capabilities: DaemonCapabilities,
    pub mode: DaemonMode,
    pub name: String,
    #[serde(default)]
    pub tags: Vec<Uuid>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema, TS)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct Daemon {
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
    Debug, Display, Copy, Clone, Serialize, Deserialize, Default, PartialEq, Eq, ValueEnum, Hash, ToSchema, TS,
)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
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
