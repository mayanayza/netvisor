use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use strum_macros::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};
use uuid::Uuid;

use crate::server::{
    daemons::types::api::DiscoveryUpdatePayload,
    shared::{
        constants::Entity,
        types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider},
    },
};

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
    pub fn new(base: DiscoveryBase) -> Self {
        let now = chrono::Utc::now();
        Self {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base,
        }
    }

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

#[derive(
    Debug,
    Clone,
    Serialize,
    Deserialize,
    Eq,
    PartialEq,
    Hash,
    Display,
    IntoStaticStr,
    EnumDiscriminants,
    EnumIter,
)]
#[serde(tag = "type")]
pub enum DiscoveryType {
    SelfReport { host_id: Uuid },
    // None = all interfaced subnets
    Network { subnet_ids: Option<Vec<Uuid>> },
    Docker { host_id: Uuid },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
pub enum RunType {
    Scheduled {
        cron_schedule: String,
        last_run: Option<DateTime<Utc>>,
        enabled: bool,
    },
    Historical {
        results: DiscoveryUpdatePayload,
    },
    AdHoc {
        last_run: Option<DateTime<Utc>>,
    },
}

impl HasId for DiscoveryType {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for DiscoveryType {
    fn color(&self) -> &'static str {
        Entity::Discovery.color()
    }

    fn icon(&self) -> &'static str {
        Entity::Discovery.icon()
    }
}

impl TypeMetadataProvider for DiscoveryType {
    fn name(&self) -> &'static str {
        self.id()
    }
    fn description(&self) -> &'static str {
        match self {
            DiscoveryType::Docker { .. } => {
                "Discover Docker containers and their configurations on the daemon's host"
            }
            DiscoveryType::Network { .. } => {
                "Scan network subnets to discover hosts, open ports, and running services"
            }
            DiscoveryType::SelfReport { .. } => {
                "The daemon reports its own host configuration and network details"
            }
        }
    }
}
