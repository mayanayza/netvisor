use std::{collections::HashMap, sync::Arc};

use anyhow::Error;
use petgraph::{Graph, graph::NodeIndex};
use uuid::Uuid;

use crate::server::{
    groups::service::GroupService,
    hosts::service::HostService,
    services::{service::ServiceService, types::base::Service},
    subnets::service::SubnetService,
    topology::{
        service::{
            context::TopologyContext, edge_builder::EdgeBuilder,
            optimizer::main::TopologyOptimizer,
            planner::subnet_layout_planner::SubnetLayoutPlanner,
        },
        types::{api::TopologyRequestOptions, edges::Edge, nodes::Node},
    },
};

pub struct TopologyService {
    host_service: Arc<HostService>,
    subnet_service: Arc<SubnetService>,
    group_service: Arc<GroupService>,
    service_service: Arc<ServiceService>,
}

impl TopologyService {
    pub fn new(
        host_service: Arc<HostService>,
        subnet_service: Arc<SubnetService>,
        group_service: Arc<GroupService>,
        service_service: Arc<ServiceService>,
    ) -> Self {
        Self {
            host_service,
            subnet_service,
            group_service,
            service_service,
        }
    }

    pub async fn build_graph(
        &self,
        options: TopologyRequestOptions,
    ) -> Result<Graph<Node, Edge>, Error> {
        // Fetch all data
        let hosts = self.host_service.get_all_hosts(&options.network_ids).await?;
        let subnets = self.subnet_service.get_all_subnets(&options.network_ids).await?;
        let groups = self.group_service.get_all_groups(&options.network_ids).await?;
        let services: Vec<Service> = self
            .service_service
            .get_all_services(&options.network_ids)
            .await?
            .into_iter()
            .filter(|s| {
                !options
                    .hide_service_categories
                    .contains(&s.base.service_definition.category())
            })
            .collect();

        // Create context to avoid parameter passing
        let ctx = TopologyContext::new(&hosts, &subnets, &services, &groups, &options);

        // Create all edges (needed for anchor analysis)
        let mut all_edges = Vec::new();

        all_edges.extend(EdgeBuilder::create_interface_edges(&ctx));

        all_edges.extend(EdgeBuilder::create_group_edges(&ctx));
        all_edges.extend(EdgeBuilder::create_vm_host_edges(&ctx));
        let (container_edges, docker_bridge_host_subnet_id_to_group_on) =
            EdgeBuilder::create_containerized_service_edges(
                &ctx,
                options.group_docker_bridges_by_host,
            );

        all_edges.extend(container_edges);

        // Create nodes with layout
        let mut layout_planner = SubnetLayoutPlanner::new();
        let (subnet_layouts, child_nodes) = layout_planner.create_subnet_child_nodes(
            &ctx,
            &mut all_edges,
            options.group_docker_bridges_by_host,
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

        Ok(graph)
    }
}
