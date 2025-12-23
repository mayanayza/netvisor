use std::{collections::HashMap, sync::Arc};

use anyhow::Error;
use async_trait::async_trait;
use chrono::Utc;
use petgraph::{Graph, graph::NodeIndex, visit::EdgeRef};
use tokio::sync::broadcast;
use uuid::Uuid;

use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    groups::{r#impl::base::Group, service::GroupService},
    hosts::{r#impl::base::Host, service::HostService},
    interfaces::{r#impl::base::Interface, service::InterfaceService},
    services::{r#impl::base::Service, service::ServiceService},
    shared::{
        events::{
            bus::EventBus,
            types::{EntityEvent, EntityOperation},
        },
        services::traits::{CrudService, EventBusService},
        storage::{
            filter::EntityFilter,
            generic::GenericPostgresStorage,
            traits::{StorableEntity, Storage},
        },
    },
    subnets::{r#impl::base::Subnet, service::SubnetService},
    topology::{
        service::{
            context::TopologyContext, edge_builder::EdgeBuilder,
            optimizer::main::TopologyOptimizer,
            planner::subnet_layout_planner::SubnetLayoutPlanner,
        },
        types::{
            base::{Topology, TopologyOptions},
            edges::{Edge, EdgeHandle},
            nodes::Node,
        },
    },
};

pub struct TopologyService {
    storage: Arc<GenericPostgresStorage<Topology>>,
    host_service: Arc<HostService>,
    interface_service: Arc<InterfaceService>,
    subnet_service: Arc<SubnetService>,
    group_service: Arc<GroupService>,
    service_service: Arc<ServiceService>,
    event_bus: Arc<EventBus>,
    pub staleness_tx: broadcast::Sender<Topology>,
}

impl EventBusService<Topology> for TopologyService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, entity: &Topology) -> Option<Uuid> {
        Some(entity.base.network_id)
    }
    fn get_organization_id(&self, _entity: &Topology) -> Option<Uuid> {
        None
    }
}

#[async_trait]
impl CrudService<Topology> for TopologyService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Topology>> {
        &self.storage
    }

    /// Create entity
    async fn create(
        &self,
        entity: Topology,
        authentication: AuthenticatedEntity,
    ) -> Result<Topology, anyhow::Error> {
        let mut topology = if entity.id() == Uuid::nil() {
            Topology::new(entity.get_base())
        } else {
            entity
        };

        let (hosts, interfaces, subnets, groups) =
            self.get_entity_data(topology.base.network_id).await?;

        let services = self
            .get_service_data(topology.base.network_id, &topology.base.options)
            .await?;

        let params = BuildGraphParams {
            hosts: &hosts,
            interfaces: &interfaces,
            services: &services,
            subnets: &subnets,
            groups: &groups,
            old_edges: &[],
            old_nodes: &[],
            options: &topology.base.options,
        };

        let (nodes, edges) = self.build_graph(params);

        topology.base.edges = edges;
        topology.base.nodes = nodes;
        topology.base.hosts = hosts;
        topology.base.interfaces = interfaces;
        topology.base.services = services;
        topology.base.subnets = subnets;
        topology.base.groups = groups;
        topology.clear_stale();

        let created = self.storage().create(&topology).await?;

        self.event_bus()
            .publish_entity(EntityEvent {
                id: Uuid::new_v4(),
                entity_id: created.id(),
                network_id: self.get_network_id(&created),
                organization_id: self.get_organization_id(&created),
                entity_type: created.clone().into(),
                operation: EntityOperation::Created,
                timestamp: Utc::now(),
                metadata: serde_json::json!({
                    "clear_stale": true
                }),
                authentication,
            })
            .await?;

        Ok(created)
    }
}

pub struct BuildGraphParams<'a> {
    pub options: &'a TopologyOptions,
    pub hosts: &'a [Host],
    pub interfaces: &'a [Interface],
    pub subnets: &'a [Subnet],
    pub services: &'a [Service],
    pub groups: &'a [Group],
    pub old_nodes: &'a [Node],
    pub old_edges: &'a [Edge],
}

impl TopologyService {
    pub fn new(
        host_service: Arc<HostService>,
        interface_service: Arc<InterfaceService>,
        subnet_service: Arc<SubnetService>,
        group_service: Arc<GroupService>,
        service_service: Arc<ServiceService>,
        storage: Arc<GenericPostgresStorage<Topology>>,
        event_bus: Arc<EventBus>,
    ) -> Self {
        let (staleness_tx, _) = broadcast::channel(100);
        Self {
            host_service,
            interface_service,
            subnet_service,
            group_service,
            service_service,
            storage,
            event_bus,
            staleness_tx,
        }
    }

    pub fn subscribe_staleness_changes(&self) -> broadcast::Receiver<Topology> {
        self.staleness_tx.subscribe()
    }

    pub async fn get_entity_data(
        &self,
        network_id: Uuid,
    ) -> Result<(Vec<Host>, Vec<Interface>, Vec<Subnet>, Vec<Group>), Error> {
        let network_filter = EntityFilter::unfiltered().network_ids(&[network_id]);
        // Fetch all data
        let hosts = self
            .host_service
            .get_all(network_filter.clone().hidden_is(false))
            .await?;

        // Fetch interfaces for all hosts
        let host_ids: Vec<Uuid> = hosts.iter().map(|h| h.id).collect();
        let interface_filter = EntityFilter::unfiltered().host_ids(&host_ids);
        let interfaces = self.interface_service.get_all(interface_filter).await?;

        let subnets = self.subnet_service.get_all(network_filter.clone()).await?;
        let groups = self.group_service.get_all(network_filter.clone()).await?;

        Ok((hosts, interfaces, subnets, groups))
    }

    pub async fn get_service_data(
        &self,
        network_id: Uuid,
        options: &TopologyOptions,
    ) -> Result<Vec<Service>, Error> {
        let network_filter = EntityFilter::unfiltered().network_ids(&[network_id]);

        Ok(self
            .service_service
            .get_all(network_filter.clone())
            .await?
            .iter()
            .filter(|s| {
                !options
                    .request
                    .hide_service_categories
                    .contains(&s.base.service_definition.category())
            })
            .cloned()
            .collect())
    }

    pub fn build_graph(&self, params: BuildGraphParams) -> (Vec<Node>, Vec<Edge>) {
        let BuildGraphParams {
            hosts,
            interfaces,
            subnets,
            services,
            groups,
            old_edges,
            old_nodes,
            options,
        } = params;

        // Create context to avoid parameter passing
        let ctx = TopologyContext::new(hosts, interfaces, subnets, services, groups, options);

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

        // Build previous graph to compare and deterine if user edits should be persisted
        // If nodes have changed edges, assume they have moved and user edits are no longer applicable
        let mut old_graph: Graph<Node, Edge> = Graph::new();
        let old_node_indices: HashMap<Uuid, NodeIndex> = old_nodes
            .iter()
            .map(|node| {
                let node_id = node.id;
                let node_idx = old_graph.add_node(node.clone());
                (node_id, node_idx)
            })
            .collect();

        EdgeBuilder::add_edges_to_graph(&mut old_graph, &old_node_indices, old_edges.to_vec());

        // Create a map of old edges by their source/target for quick lookup
        let mut old_edges_map: HashMap<(Uuid, Uuid), &Edge> = HashMap::new();
        for edge_ref in old_graph.edge_references() {
            let edge = edge_ref.weight();
            old_edges_map.insert((edge.source, edge.target), edge);
        }

        // Preserve handles for nodes with unchanged edge count
        // First, collect all the edges that need updating
        let mut edges_to_update: Vec<(petgraph::prelude::EdgeIndex, EdgeHandle, EdgeHandle)> =
            Vec::new();

        for node in graph.node_weights() {
            if let Some(old_idx) = old_node_indices.get(&node.id)
                && let Some(new_idx) = node_indices.get(&node.id)
            {
                let old_edge_count = old_graph.edges(*old_idx).count();
                let new_edge_count = graph.edges(*new_idx).count();

                if old_edge_count == new_edge_count {
                    // Collect edges that match
                    for edge_ref in graph.edges(*new_idx) {
                        let new_edge = edge_ref.weight();
                        if let Some(old_edge) =
                            old_edges_map.get(&(new_edge.source, new_edge.target))
                        {
                            edges_to_update.push((
                                edge_ref.id(),
                                old_edge.source_handle,
                                old_edge.target_handle,
                            ));
                        }
                    }
                }
            }
        }

        // Now apply the updates
        for (edge_idx, source_handle, target_handle) in edges_to_update {
            if let Some(edge) = graph.edge_weight_mut(edge_idx) {
                edge.source_handle = source_handle;
                edge.target_handle = target_handle;
            }
        }

        (
            graph.node_weights().cloned().collect(),
            graph.edge_weights().cloned().collect(),
        )
    }
}
