use crate::server::topology::types::api::TopologyOptions;
use crate::server::topology::types::edges::Edge;
use crate::server::topology::types::nodes::Node;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::{fmt::Display, hash::Hash};
use uuid::Uuid;
use validator::Validate;

#[derive(Debug, Clone, Validate, Serialize, Deserialize, Eq, PartialEq, Hash)]
pub struct TopologyBase {
    #[validate(length(min = 0, max = 100))]
    pub name: String, // "Home LAN", "VPN Network", etc.
    pub options: TopologyOptions,
    pub network_id: Uuid,
    pub nodes: Vec<Node>,
    pub edges: Vec<Edge>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Topology {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    pub base: TopologyBase,
}

impl Display for Topology {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "Topology {{ id: {}, name: {} }}",
            self.id, self.base.name
        )
    }
}
