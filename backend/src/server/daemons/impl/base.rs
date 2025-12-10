use std::fmt::Display;

use chrono::{DateTime, Utc};
use clap::ValueEnum;
use serde::{Deserialize, Serialize};
use strum::Display;
use uuid::Uuid;

use crate::server::{
    daemons::r#impl::api::DaemonCapabilities, shared::entities::ChangeTriggersTopologyStaleness,
};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct DaemonBase {
    pub host_id: Uuid,
    pub network_id: Uuid,
    pub url: String,
    pub last_seen: DateTime<Utc>,
    #[serde(default)]
    pub capabilities: DaemonCapabilities,
    pub mode: DaemonMode,
    pub name: String,
    #[serde(default)]
    pub tags: Vec<Uuid>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct Daemon {
    pub id: Uuid,
    pub updated_at: DateTime<Utc>,
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
    Debug, Display, Copy, Clone, Serialize, Deserialize, Default, PartialEq, Eq, ValueEnum, Hash,
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
