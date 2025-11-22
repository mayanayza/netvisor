use std::{fmt::Display, net::IpAddr};

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
    pub ip: IpAddr,
    pub last_seen: DateTime<Utc>,
    pub port: u16,
    #[serde(default)]
    pub capabilities: DaemonCapabilities,
    pub mode: DaemonMode,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct Daemon {
    pub id: Uuid,
    pub updated_at: DateTime<Utc>,
    pub created_at: DateTime<Utc>,
    #[serde(flatten)]
    pub base: DaemonBase,
}

impl Display for Daemon {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}: {}", self.base.ip, self.id)
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
