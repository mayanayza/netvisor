use crate::server::discovery::r#impl::types::DiscoveryType;
use crate::server::discovery::r#impl::types::HostNamingFallback;
use crate::server::services::r#impl::patterns::MatchDetails;
use chrono::DateTime;
use chrono::Utc;
use serde::{Deserialize, Serialize};
use strum_macros::EnumDiscriminants;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, Eq, PartialEq, Hash, EnumDiscriminants)]
#[strum_discriminants(derive(Hash))]
#[serde(tag = "type")]
pub enum EntitySource {
    Manual,
    System,
    // Used with hosts and subnets
    Discovery {
        metadata: Vec<DiscoveryMetadata>,
    },
    // Only used with services
    DiscoveryWithMatch {
        metadata: Vec<DiscoveryMetadata>,
        details: MatchDetails,
    },
    Unknown,
}

#[derive(Debug, Clone, Serialize, Deserialize, Eq, PartialEq, Hash)]
pub struct DiscoveryMetadata {
    #[serde(flatten)]
    pub discovery_type: DiscoveryType,
    pub daemon_id: Uuid,
    pub date: DateTime<Utc>,
}

impl DiscoveryMetadata {
    pub fn new(discovery_type: DiscoveryType, daemon_id: Uuid) -> Self {
        Self {
            discovery_type,
            daemon_id,
            date: Utc::now(),
        }
    }
}

impl Default for DiscoveryMetadata {
    fn default() -> Self {
        Self {
            discovery_type: DiscoveryType::Network {
                subnet_ids: None,
                host_naming_fallback: HostNamingFallback::BestService,
            },
            daemon_id: Uuid::new_v4(),
            date: Utc::now(),
        }
    }
}
