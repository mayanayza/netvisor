use chrono::{DateTime, Utc};
use serde::Deserialize;
use serde::Serialize;
use strum::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};
use uuid::Uuid;

use crate::server::{
    daemons::r#impl::api::DiscoveryUpdatePayload,
    shared::{
        entities::Entity,
        types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider},
    },
};

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
