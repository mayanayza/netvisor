use std::fmt::Display;

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::server::discovery::r#impl::types::{DiscoveryType, RunType};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DiscoveryBase {
    pub discovery_type: DiscoveryType,
    pub run_type: RunType,
    pub name: String,
    pub daemon_id: Uuid,
    pub network_id: Uuid,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Discovery {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    pub base: DiscoveryBase,
}

impl Discovery {
    pub fn disable(&mut self) {
        if let RunType::Scheduled {
            enabled: mut _enabled,
            ..
        } = self.base.run_type
        {
            _enabled = false;
        }
    }
}

impl Display for Discovery {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Discovery {}: {}", self.base.name, self.id)
    }
}
