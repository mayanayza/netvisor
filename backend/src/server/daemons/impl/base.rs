use std::{fmt::Display, net::IpAddr};

use chrono::{DateTime, Utc};
use clap::ValueEnum;
use serde::{Deserialize, Serialize};
use strum::Display;
use uuid::Uuid;

use crate::server::daemons::r#impl::api::DaemonCapabilities;

#[derive(Debug, Clone, Serialize, Deserialize)]
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

#[derive(Debug, Clone, Serialize, Deserialize)]
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
    Debug, Display, Copy, Clone, Serialize, Deserialize, Default, PartialEq, Eq, ValueEnum,
)]
pub enum DaemonMode {
    #[default]
    Push,
    Pull,
}
