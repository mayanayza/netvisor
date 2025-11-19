use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::server::services::r#impl::categories::ServiceCategory;

#[derive(Serialize, Deserialize, Debug, Clone, Default, PartialEq, Eq, Hash)]
pub struct TopologyOptions {
    pub network_ids: Vec<Uuid>,
    pub group_docker_bridges_by_host: bool,
    pub hide_vm_title_on_docker_container: bool,
    pub hide_ports: bool,
    pub left_zone_service_categories: Vec<ServiceCategory>,
    pub hide_service_categories: Vec<ServiceCategory>,
    pub show_gateway_in_left_zone: bool,
}
