use itertools::Itertools;
use petgraph::{Graph, graph::NodeIndex};
use std::collections::HashMap;
use strum::IntoDiscriminant;
use uuid::Uuid;

use crate::server::{
    groups::r#impl::{base::Group, types::GroupType},
    hosts::r#impl::virtualization::HostVirtualization,
    services::r#impl::virtualization::ServiceVirtualization,
    subnets::r#impl::types::{SubnetType, SubnetTypeDiscriminants},
    topology::{
        service::context::TopologyContext,
        types::{
            edges::{Edge, EdgeHandle, EdgeType},
            nodes::Node,
        },
    },
};

pub struct EdgeBuilder;

impl EdgeBuilder {
    /// Create group edges (connecting services in a group's service chain)
    pub fn create_group_edges(ctx: &TopologyContext) -> Vec<Edge> {
        ctx.groups
            .iter()
            .flat_map(|group| {
                let binding_ids = &group.base.binding_ids;
                match &group.base.group_type {
                    GroupType::RequestPath => binding_ids
                        .windows(2)
                        .filter_map(|window| {
                            EdgeBuilder::edge_from_service_bindings(
                                ctx, window[0], window[1], group,
                            )
                        })
                        .collect::<Vec<Edge>>(),
                    GroupType::HubAndSpoke => {
                        let mut binding_ids = binding_ids.clone();
                        binding_ids.reverse();
                        if let Some(hub_binding_id) = binding_ids.pop() {
                            return binding_ids
                                .iter()
                                .filter_map(|spoke_binding| {
                                    EdgeBuilder::edge_from_service_bindings(
                                        ctx,
                                        hub_binding_id,
                                        *spoke_binding,
                                        group,
                                    )
                                })
                                .collect::<Vec<Edge>>();
                        }
                        Vec::new()
                    }
                }
            })
            .collect()
    }

    // Create edges to connect a host that virtualizes containers via docker to the docker bridge subnets
    pub fn create_containerized_service_edges(
        ctx: &TopologyContext,
        group_docker_bridges_by_host: bool,
    ) -> (Vec<Edge>, HashMap<Uuid, Uuid>) {
        // Host id to subnet id that will be used for grouping, if enabled
        let mut docker_bridge_host_subnet_id_to_group_on: HashMap<Uuid, Uuid> = HashMap::new();

        let mut docker_service_to_containerized_service_ids: HashMap<Uuid, Vec<Uuid>> =
            HashMap::new();

        ctx.services.iter().for_each(|s| {
            if let Some(ServiceVirtualization::Docker(docker_virtualization)) =
                &s.base.virtualization
            {
                let entry = docker_service_to_containerized_service_ids
                    .entry(docker_virtualization.service_id)
                    .or_default();
                if !entry.contains(&s.id) {
                    entry.push(s.id);
                }
            }
        });

        let edges = ctx
            .services
            .iter()
            .filter(|s| {
                docker_service_to_containerized_service_ids
                    .keys()
                    .contains(&s.id)
            })
            .filter_map(|s| {
                let host = ctx.get_host_by_id(s.base.host_id)?;
                let origin_interface =
                    ctx.get_first_non_docker_bridge_interface_for_host(host.id)?;
                Some((s, host, origin_interface))
            })
            .flat_map(|(s, host, origin_interface)| {
                let host_interfaces = ctx.get_interfaces_for_host(host.id);
                let container_subnets: Vec<Uuid> = host_interfaces
                    .iter()
                    .filter_map(|i| ctx.get_subnet_by_id(i.base.subnet_id))
                    .filter_map(|s| {
                        if s.base.subnet_type == SubnetType::DockerBridge {
                            return Some(s.id);
                        }
                        None
                    })
                    .collect();

                let container_subnet_interface_ids: Vec<Uuid> = host_interfaces
                    .iter()
                    .filter_map(|i| {
                        if container_subnets.contains(&i.base.subnet_id) {
                            return Some(i.id);
                        }
                        None
                    })
                    .collect();

                if group_docker_bridges_by_host {
                    // If subnets are grouped, pick an arbitrary subnet ID to use for grouping
                    if let (Some(first_interface_id), Some(first_subnet_id)) = (
                        container_subnet_interface_ids.first(),
                        container_subnets.first(),
                    ) {
                        let is_multi_hop =
                            ctx.edge_is_multi_hop(&origin_interface.id, first_interface_id);

                        if let Some((source_handle, target_handle)) =
                            EdgeBuilder::determine_interface_handles(
                                ctx,
                                &origin_interface.id,
                                first_interface_id,
                                is_multi_hop,
                            )
                        {
                            docker_bridge_host_subnet_id_to_group_on
                                .entry(host.id)
                                .or_insert(*first_subnet_id);

                            if ctx.interface_will_have_node(&origin_interface.id) {
                                return vec![Edge {
                                    id: Uuid::new_v4(),
                                    source: origin_interface.id,
                                    target: *first_subnet_id,
                                    edge_type: EdgeType::ServiceVirtualization {
                                        containerizing_service_id: s.id,
                                        host_id: host.id,
                                    },
                                    label: Some(format!("{} @ {}", s.base.name, host.base.name)),
                                    source_handle,
                                    target_handle,
                                    is_multi_hop,
                                }];
                            }
                        }
                    }
                } else {
                    return docker_service_to_containerized_service_ids
                        .get(&s.id)
                        .unwrap_or(&Vec::new())
                        .iter()
                        .filter_map(move |cs| {
                            let containerized = ctx.get_service_by_id(*cs)?;

                            let container_binding_interface_id = containerized
                                .base
                                .bindings
                                .iter()
                                .filter_map(|b| b.interface_id())
                                .find(|i| container_subnet_interface_ids.contains(i))?;

                            let is_multi_hop = ctx.edge_is_multi_hop(
                                &origin_interface.id,
                                &container_binding_interface_id,
                            );

                            let (source_handle, target_handle) =
                                EdgeBuilder::determine_interface_handles(
                                    ctx,
                                    &origin_interface.id,
                                    &container_binding_interface_id,
                                    is_multi_hop,
                                )?;

                            if ctx.interface_will_have_node(&origin_interface.id)
                                && ctx.interface_will_have_node(&container_binding_interface_id)
                            {
                                return Some(Edge {
                                    id: Uuid::new_v4(),
                                    source: origin_interface.id,
                                    target: container_binding_interface_id,
                                    edge_type: EdgeType::ServiceVirtualization {
                                        containerizing_service_id: s.id,
                                        host_id: host.id,
                                    },
                                    label: Some(format!("{} on {}", s.base.name, host.base.name)),
                                    source_handle,
                                    target_handle,
                                    is_multi_hop,
                                });
                            }
                            None
                        })
                        .collect();
                }

                Vec::new()
            })
            .collect();

        (edges, docker_bridge_host_subnet_id_to_group_on)
    }

    // Create edges to connect a host that virtualizes other hosts as VMs
    pub fn create_vm_host_edges(ctx: &TopologyContext) -> Vec<Edge> {
        // Proxmox service interface binding that is present for a given subnet.
        // There could be multiple host interfaces with a given subnet, we arbitrarily choose the first one so there's
        // one clustering hub rather than multiple hubs
        // (subnet_id, proxmox_service_id) : (interface_id)
        let mut subnet_to_promxox_host_interface_id: HashMap<(Uuid, Uuid), Uuid> = HashMap::new();

        // Hosts VMs managed by a given proxmox service
        let mut vm_host_id_to_proxmox_service: HashMap<Uuid, Uuid> = HashMap::new();

        ctx.hosts.iter().for_each(|h| {
            if let Some(HostVirtualization::Proxmox(proxmox_virtualization)) =
                &h.base.virtualization
            {
                // Create mapping between subnet and proxmox interface(s) on that subnet
                if let Some(promxox_service) =
                    ctx.get_service_by_id(proxmox_virtualization.service_id)
                {
                    promxox_service
                        .base
                        .bindings
                        .iter()
                        .filter_map(|b| b.interface_id())
                        .for_each(|i| {
                            if let Some(subnet) = ctx.get_subnet_from_interface_id(i)
                                && !subnet_to_promxox_host_interface_id
                                    .contains_key(&(subnet.id, promxox_service.id))
                            {
                                subnet_to_promxox_host_interface_id
                                    .entry((subnet.id, promxox_service.id))
                                    .insert_entry(i);
                            }
                        });
                }

                vm_host_id_to_proxmox_service.insert(h.id, proxmox_virtualization.service_id);
            }
        });

        // Creates edges between interface that proxmox service has on a given subnet with interfaces that the virtualized host has on the subnet
        ctx.hosts
            .iter()
            .flat_map(|h| {
                if let Some(proxmox_service_id) = vm_host_id_to_proxmox_service.get(&h.id) {
                    let host_interfaces = ctx.get_interfaces_for_host(h.id);
                    return host_interfaces
                        .into_iter()
                        .filter_map(|i| {
                            if let Some(proxmox_service_interface_id) =
                                subnet_to_promxox_host_interface_id
                                    .get(&(i.base.subnet_id, *proxmox_service_id))
                                && ctx.interface_will_have_node(proxmox_service_interface_id)
                            {
                                let is_multi_hop =
                                    ctx.edge_is_multi_hop(proxmox_service_interface_id, &i.id);

                                let (source_handle, target_handle) =
                                    EdgeBuilder::determine_interface_handles(
                                        ctx,
                                        proxmox_service_interface_id,
                                        &i.id,
                                        is_multi_hop,
                                    )?;

                                return Some(Edge {
                                    id: Uuid::new_v4(),
                                    source: *proxmox_service_interface_id,
                                    target: i.id,
                                    edge_type: EdgeType::HostVirtualization {
                                        vm_service_id: *proxmox_service_id,
                                    },
                                    label: None,
                                    source_handle,
                                    target_handle,
                                    is_multi_hop,
                                });
                            }
                            None
                        })
                        .collect();
                }
                Vec::new()
            })
            .collect()
    }

    /// Create interface edges (connecting multiple interfaces on the same host)
    pub fn create_interface_edges(ctx: &TopologyContext) -> Vec<Edge> {
        ctx.hosts
            .iter()
            .flat_map(|host| {
                let host_interfaces = ctx.get_interfaces_for_host(host.id);
                if let Some(origin_interface) = host_interfaces.first() {
                    host_interfaces
                        .iter()
                        .filter(|interface| {
                            interface.id != origin_interface.id
                                && ctx.interface_will_have_node(&interface.id)
                                && ctx.interface_will_have_node(&origin_interface.id)
                        })
                        .filter_map(|interface| {
                            let source_subnet =
                                ctx.get_subnet_by_id(origin_interface.base.subnet_id);
                            let target_subnet = ctx.get_subnet_by_id(interface.base.subnet_id);

                            if let Some(source_subnet) = source_subnet
                                && source_subnet.base.subnet_type.discriminant()
                                    == SubnetTypeDiscriminants::DockerBridge
                            {
                                return None;
                            }

                            if let Some(target_subnet) = target_subnet
                                && target_subnet.base.subnet_type.discriminant()
                                    == SubnetTypeDiscriminants::DockerBridge
                            {
                                return None;
                            }

                            let is_multi_hop =
                                ctx.edge_is_multi_hop(&origin_interface.id, &interface.id);

                            let (source_handle, target_handle) =
                                EdgeBuilder::determine_interface_handles(
                                    ctx,
                                    &origin_interface.id,
                                    &interface.id,
                                    is_multi_hop,
                                )?;

                            // Hide label if both interfaces are on the same subnet
                            let label =
                                if origin_interface.base.subnet_id == interface.base.subnet_id {
                                    None
                                } else {
                                    Some(host.base.name.to_string())
                                };

                            Some(Edge {
                                id: Uuid::new_v4(),
                                source: origin_interface.id,
                                target: interface.id,
                                edge_type: EdgeType::Interface { host_id: host.id },
                                label,
                                source_handle,
                                target_handle,
                                is_multi_hop,
                            })
                        })
                        .collect::<Vec<_>>()
                } else {
                    Vec::new()
                }
            })
            .collect()
    }

    /// Figure out handles for two interfaces
    pub fn determine_interface_handles(
        ctx: &TopologyContext,
        source_interface_id: &Uuid,
        target_interface_id: &Uuid,
        is_multi_hop: bool,
    ) -> Option<(EdgeHandle, EdgeHandle)> {
        let source_subnet = ctx.get_subnet_from_interface_id(*source_interface_id)?;
        let target_subnet = ctx.get_subnet_from_interface_id(*target_interface_id)?;

        let source_is_infra = ctx
            .get_interfaces_with_infra_service(source_subnet)
            .contains(&Some(*source_interface_id));
        let target_is_infra = ctx
            .get_interfaces_with_infra_service(target_subnet)
            .contains(&Some(*target_interface_id));

        // Check if infra constraints are actually necessary
        let source_needs_infra_constraint = ctx.subnet_has_mixed_infra(source_subnet);
        let target_needs_infra_constraint = ctx.subnet_has_mixed_infra(target_subnet);

        Some(EdgeHandle::from_subnet_layers(
            source_subnet,
            target_subnet,
            source_is_infra && source_needs_infra_constraint,
            target_is_infra && target_needs_infra_constraint,
            is_multi_hop,
        ))
    }

    /// Add edges to a petgraph Graph
    pub fn add_edges_to_graph(
        graph: &mut Graph<Node, Edge>,
        node_indices: &HashMap<Uuid, NodeIndex>,
        edges: Vec<Edge>,
    ) {
        for edge in edges {
            if let (Some(&src_idx), Some(&tgt_idx)) = (
                node_indices.get(&edge.source),
                node_indices.get(&edge.target),
            ) {
                graph.add_edge(src_idx, tgt_idx, edge);
            }
        }
    }

    pub fn edge_from_service_bindings(
        ctx: &TopologyContext,
        source_binding_id: Uuid,
        target_binding_id: Uuid,
        group: &Group,
    ) -> Option<Edge> {
        let source_interface = ctx.services.iter().find_map(|s| {
            if let Some(source_binding) = s.get_binding(source_binding_id) {
                return Some(source_binding.interface_id());
            }
            None
        });

        let target_interface = ctx.services.iter().find_map(|s| {
            if let Some(target_binding) = s.get_binding(target_binding_id) {
                return Some(target_binding.interface_id());
            }
            None
        });

        if let (Some(Some(source_interface)), Some(Some(target_interface))) =
            (source_interface, target_interface)
            && ctx.interface_will_have_node(&source_interface)
            && ctx.interface_will_have_node(&target_interface)
        {
            let is_multi_hop = ctx.edge_is_multi_hop(&source_interface, &target_interface);

            let (source_handle, target_handle) = EdgeBuilder::determine_interface_handles(
                ctx,
                &source_interface,
                &target_interface,
                is_multi_hop,
            )?;

            // If edge is intra-subnet, don't label - gets too messy
            let label = if ctx
                .get_subnet_from_interface_id(source_interface)
                .map(|s| s.id)
                == ctx
                    .get_subnet_from_interface_id(target_interface)
                    .map(|s| s.id)
            {
                None
            } else {
                Some(group.base.name.to_string())
            };

            return Some(Edge {
                id: Uuid::new_v4(),
                source: source_interface,
                target: target_interface,
                edge_type: match group.base.group_type {
                    GroupType::HubAndSpoke => EdgeType::HubAndSpoke {
                        source_binding_id,
                        target_binding_id,
                        group_id: group.id,
                    },
                    GroupType::RequestPath => EdgeType::RequestPath {
                        source_binding_id,
                        target_binding_id,
                        group_id: group.id,
                    },
                },
                label,
                source_handle,
                target_handle,
                is_multi_hop,
            });
        }
        None
    }
}
