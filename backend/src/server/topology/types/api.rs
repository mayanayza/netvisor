use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::server::topology::types::base::Topology;

#[derive(Serialize, Deserialize, Debug, Clone, Default, PartialEq, Eq, Hash)]
pub struct TopologyUpdate {
    topology_id: Uuid,
    is_stale: bool,
    removed_hosts: Vec<Uuid>,
    removed_services: Vec<Uuid>,
    removed_subnets: Vec<Uuid>,
    removed_groups: Vec<Uuid>,
}

impl From<Topology> for TopologyUpdate {
    fn from(value: Topology) -> Self {
        Self {
            removed_groups: value.base.removed_groups,
            removed_hosts: value.base.removed_hosts,
            removed_services: value.base.removed_services,
            removed_subnets: value.base.removed_subnets,
            is_stale: value.base.is_stale,
            topology_id: value.id,
        }
    }
}
