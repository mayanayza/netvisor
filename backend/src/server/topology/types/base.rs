use crate::server::bindings::r#impl::base::Binding;
use crate::server::groups::r#impl::base::Group;
use crate::server::hosts::r#impl::base::Host;
use crate::server::interfaces::r#impl::base::Interface;
use crate::server::ports::r#impl::base::Port;
use crate::server::services::r#impl::base::Service;
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::shared::entities::ChangeTriggersTopologyStaleness;
use crate::server::subnets::r#impl::base::Subnet;
use crate::server::topology::types::edges::Edge;
use crate::server::topology::types::edges::EdgeTypeDiscriminants;
use crate::server::topology::types::nodes::Node;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::{fmt::Display, hash::Hash};
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

pub struct SetEntitiesParams {
    pub hosts: Vec<Host>,
    pub services: Vec<Service>,
    pub subnets: Vec<Subnet>,
    pub groups: Vec<Group>,
    pub ports: Vec<Port>,
    pub bindings: Vec<Binding>,
    pub interfaces: Vec<Interface>,
}

#[derive(
    Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema, Validate,
)]
pub struct Topology {
    #[serde(default)]
    #[schema(read_only, required)]
    pub id: Uuid,
    #[serde(default)]
    #[schema(read_only, required)]
    pub created_at: DateTime<Utc>,
    #[serde(default)]
    #[schema(read_only, required)]
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    #[validate(nested)]
    pub base: TopologyBase,
}

impl Topology {
    pub fn set_entities(&mut self, params: SetEntitiesParams) {
        self.base.hosts = params.hosts;
        self.base.services = params.services;
        self.base.subnets = params.subnets;
        self.base.groups = params.groups;
        self.base.ports = params.ports;
        self.base.bindings = params.bindings;
        self.base.interfaces = params.interfaces;
    }

    pub fn set_graph(&mut self, nodes: Vec<Node>, edges: Vec<Edge>) {
        self.base.nodes = nodes;
        self.base.edges = edges;
    }
}

#[derive(
    Debug, Clone, Validate, Serialize, Deserialize, Eq, PartialEq, Hash, Default, ToSchema,
)]
pub struct TopologyBase {
    #[validate(length(min = 0, max = 100))]
    pub name: String,
    pub options: TopologyOptions,
    pub network_id: Uuid,
    #[serde(default)]
    #[schema(required)]
    pub tags: Vec<Uuid>,
    pub parent_id: Option<Uuid>,

    // Graph
    pub nodes: Vec<Node>,
    pub edges: Vec<Edge>,

    // Entities
    pub hosts: Vec<Host>,
    pub interfaces: Vec<Interface>,
    pub ports: Vec<Port>,
    pub bindings: Vec<Binding>,
    pub subnets: Vec<Subnet>,
    pub services: Vec<Service>,
    pub groups: Vec<Group>,

    // Build state
    pub is_stale: bool,
    pub last_refreshed: DateTime<Utc>,
    pub is_locked: bool,
    pub locked_at: Option<DateTime<Utc>>,
    pub locked_by: Option<Uuid>,

    pub removed_hosts: Vec<Uuid>,
    pub removed_interfaces: Vec<Uuid>,
    pub removed_subnets: Vec<Uuid>,
    pub removed_services: Vec<Uuid>,
    pub removed_groups: Vec<Uuid>,
    pub removed_ports: Vec<Uuid>,
    pub removed_bindings: Vec<Uuid>,
}

impl TopologyBase {
    pub fn new(name: String, network_id: Uuid) -> Self {
        Self {
            name,
            network_id,
            options: TopologyOptions::default(),
            nodes: vec![],
            edges: vec![],
            hosts: vec![],
            ports: vec![],
            interfaces: vec![],
            subnets: vec![],
            bindings: vec![],
            services: vec![],
            groups: vec![],
            is_stale: true,
            last_refreshed: Utc::now(),
            is_locked: false,
            locked_at: None,
            locked_by: None,
            removed_hosts: vec![],
            removed_interfaces: vec![],
            removed_subnets: vec![],
            removed_services: vec![],
            removed_groups: vec![],
            removed_bindings: vec![],
            removed_ports: vec![],
            parent_id: None,
            tags: vec![],
        }
    }
}

impl ChangeTriggersTopologyStaleness<Topology> for Topology {
    fn triggers_staleness(&self, other: Option<Topology>) -> bool {
        if let Some(other_topology) = other {
            self.base.options.request != other_topology.base.options.request
        } else {
            false
        }
    }
}

impl Topology {
    pub fn lock(&mut self, locked_by: Uuid) {
        self.base.is_locked = true;
        self.base.locked_at = Some(Utc::now());
        self.base.locked_by = Some(locked_by)
    }

    pub fn unlock(&mut self) {
        self.base.is_locked = false;
        self.base.locked_at = None;
        self.base.locked_by = None;
    }

    pub fn clear_stale(&mut self) {
        self.base.removed_groups = vec![];
        self.base.removed_hosts = vec![];
        self.base.removed_interfaces = vec![];
        self.base.removed_services = vec![];
        self.base.removed_subnets = vec![];
        self.base.is_stale = false;
        self.base.last_refreshed = Utc::now()
    }
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

#[derive(Serialize, Deserialize, Debug, Clone, Default, PartialEq, Eq, Hash, ToSchema)]
pub struct TopologyOptions {
    pub local: TopologyLocalOptions,
    pub request: TopologyRequestOptions,
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash, ToSchema)]
pub struct TopologyLocalOptions {
    pub left_zone_title: String,
    pub no_fade_edges: bool,
    pub hide_resize_handles: bool,
    pub hide_edge_types: Vec<EdgeTypeDiscriminants>,
}

impl Default for TopologyLocalOptions {
    fn default() -> Self {
        Self {
            left_zone_title: "Infrastructure".to_string(),
            no_fade_edges: false,
            hide_resize_handles: false,
            hide_edge_types: Vec::new(),
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash, ToSchema)]
pub struct TopologyRequestOptions {
    pub group_docker_bridges_by_host: bool,
    pub hide_vm_title_on_docker_container: bool,
    pub hide_ports: bool,
    pub left_zone_service_categories: Vec<ServiceCategory>,
    pub hide_service_categories: Vec<ServiceCategory>,
    pub show_gateway_in_left_zone: bool,
}

impl Default for TopologyRequestOptions {
    fn default() -> Self {
        Self {
            group_docker_bridges_by_host: true,
            hide_vm_title_on_docker_container: false,
            hide_ports: false,
            left_zone_service_categories: vec![ServiceCategory::DNS, ServiceCategory::ReverseProxy],
            hide_service_categories: Vec::new(),
            show_gateway_in_left_zone: true,
        }
    }
}
