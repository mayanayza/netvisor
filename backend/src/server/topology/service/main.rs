use std::{collections::HashMap, sync::Arc};

use anyhow::Error;
use async_trait::async_trait;
use petgraph::{Graph, graph::NodeIndex};
use tokio::sync::broadcast;
use uuid::Uuid;

use crate::server::{
    groups::{r#impl::base::Group, service::GroupService},
    hosts::{r#impl::base::Host, service::HostService},
    services::{r#impl::base::Service, service::ServiceService},
    shared::{
        entities::Entity,
        events::bus::EventBus,
        services::traits::CrudService,
        storage::{filter::EntityFilter, generic::GenericPostgresStorage},
    },
    subnets::{r#impl::base::Subnet, service::SubnetService},
    topology::{
        service::{
            context::TopologyContext, edge_builder::EdgeBuilder,
            optimizer::main::TopologyOptimizer,
            planner::subnet_layout_planner::SubnetLayoutPlanner,
        },
        types::{
            api::TopologyStalenessUpdate,
            base::{Topology, TopologyOptions},
            edges::Edge,
            nodes::Node,
        },
    },
};

pub struct TopologyService {
    storage: Arc<GenericPostgresStorage<Topology>>,
    host_service: Arc<HostService>,
    subnet_service: Arc<SubnetService>,
    group_service: Arc<GroupService>,
    service_service: Arc<ServiceService>,
    event_bus: Arc<EventBus>,
    pub staleness_tx: broadcast::Sender<TopologyStalenessUpdate>,
}

#[async_trait]
impl CrudService<Topology> for TopologyService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Topology>> {
        &self.storage
    }

    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn entity_type() -> Entity {
        Entity::Topology
    }
    fn get_network_id(&self, entity: &Topology) -> Option<Uuid> {
        Some(entity.base.network_id)
    }
    fn get_organization_id(&self, _entity: &Topology) -> Option<Uuid> {
        None
    }
}

impl TopologyService {
    pub fn new(
        host_service: Arc<HostService>,
        subnet_service: Arc<SubnetService>,
        group_service: Arc<GroupService>,
        service_service: Arc<ServiceService>,
        storage: Arc<GenericPostgresStorage<Topology>>,
        event_bus: Arc<EventBus>,
    ) -> Self {
        let (staleness_tx, _) = broadcast::channel(100);
        Self {
            host_service,
            subnet_service,
            group_service,
            service_service,
            storage,
            event_bus,
            staleness_tx,
        }
    }

    pub fn subscribe_staleness_changes(&self) -> broadcast::Receiver<TopologyStalenessUpdate> {
        self.staleness_tx.subscribe()
    }

    pub async fn get_entity_data(
        &self,
        network_id: Uuid,
        options: TopologyOptions,
    ) -> Result<(Vec<Host>, Vec<Service>, Vec<Subnet>, Vec<Group>), Error> {
        let network_filter = EntityFilter::unfiltered().network_ids(&[network_id]);
        // Fetch all data
        let hosts = self.host_service.get_all(network_filter.clone()).await?;
        let subnets = self.subnet_service.get_all(network_filter.clone()).await?;
        let groups = self.group_service.get_all(network_filter.clone()).await?;
        let services: Vec<Service> = self
            .service_service
            .get_all(network_filter.clone())
            .await?
            .into_iter()
            .filter(|s| {
                !options
                    .request
                    .hide_service_categories
                    .contains(&s.base.service_definition.category())
            })
            .collect();

        Ok((hosts, services, subnets, groups))
    }

    pub fn build_graph(
        &self,
        options: &TopologyOptions,
        hosts: &[Host],
        subnets: &[Subnet],
        services: &[Service],
        groups: &[Group],
    ) -> (Vec<Node>, Vec<Edge>) {
        // Create context to avoid parameter passing
        let ctx = TopologyContext::new(hosts, subnets, services, groups, options);

        // Create all edges (needed for anchor analysis)
        let mut all_edges = Vec::new();

        all_edges.extend(EdgeBuilder::create_interface_edges(&ctx));

        all_edges.extend(EdgeBuilder::create_group_edges(&ctx));
        all_edges.extend(EdgeBuilder::create_vm_host_edges(&ctx));
        let (container_edges, docker_bridge_host_subnet_id_to_group_on) =
            EdgeBuilder::create_containerized_service_edges(
                &ctx,
                options.request.group_docker_bridges_by_host,
            );

        all_edges.extend(container_edges);

        // Create nodes with layout
        let mut layout_planner = SubnetLayoutPlanner::new();
        let (subnet_layouts, child_nodes) = layout_planner.create_subnet_child_nodes(
            &ctx,
            &mut all_edges,
            options.request.group_docker_bridges_by_host,
            docker_bridge_host_subnet_id_to_group_on,
        );

        let subnet_nodes = layout_planner.create_subnet_nodes(&ctx, &subnet_layouts);

        // Optimize node positions and handle edge adjustments
        let optimizer = TopologyOptimizer::new(&ctx);
        let mut all_nodes: Vec<Node> = subnet_nodes.into_iter().chain(child_nodes).collect();

        let optimized_edges = optimizer.optimize_graph(&mut all_nodes, &all_edges);

        // Build graph
        let mut graph: Graph<Node, Edge> = Graph::new();
        let node_indices: HashMap<Uuid, NodeIndex> = all_nodes
            .into_iter()
            .map(|node| {
                let node_id = node.id;
                let node_idx = graph.add_node(node);
                (node_id, node_idx)
            })
            .collect();

        // Add edges to graph
        EdgeBuilder::add_edges_to_graph(&mut graph, &node_indices, optimized_edges);

        (
            graph.node_weights().cloned().collect(),
            graph.edge_weights().cloned().collect(),
        )
    }
}
