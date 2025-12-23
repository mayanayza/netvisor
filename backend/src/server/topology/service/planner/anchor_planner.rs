use std::collections::HashMap;
use uuid::Uuid;

use crate::server::topology::{
    service::context::TopologyContext,
    types::edges::{Edge, EdgeHandle},
};

pub struct ChildAnchorPlanner;

impl ChildAnchorPlanner {
    /// Analyze edges to determine figure out if they need to change anchor points to avoid intersecting with other nodes
    /// Mutates handles for inter-subnet edges only, but returns ALL edges for this interface
    pub fn plan_anchors(
        interface_id: Uuid,
        edges: &mut [Edge],
        ctx: &TopologyContext,
    ) -> Vec<Edge> {
        // Find all INTER-SUBNET edges involving this child for anchor planning
        let inter_subnet_edges: Vec<&Edge> = edges
            .iter()
            .filter(|edge| {
                (edge.source == interface_id || edge.target == interface_id)
                    && !ctx.edge_is_intra_subnet(edge)
            })
            .collect();

        // Only do anchor planning if there are inter-subnet edges
        if !inter_subnet_edges.is_empty() {
            // Determine if this interface has infra services
            let is_infra = ctx.is_interface_infra(interface_id);

            // Count anchors by handle direction (only for inter-subnet edges)
            let mut handle_counts: HashMap<EdgeHandle, usize> = HashMap::new();

            for edge in &inter_subnet_edges {
                // Determine which handle applies to this child
                let relevant_handle = if edge.source == interface_id {
                    &edge.source_handle
                } else {
                    &edge.target_handle
                };

                *handle_counts.entry(*relevant_handle).or_insert(0) += 1;
            }

            // If we need to override handles, mutate ONLY inter-subnet edges
            if let Some(override_handle) =
                Self::determine_override_handle(&handle_counts, is_infra, interface_id, edges, ctx)
            {
                edges.iter_mut().for_each(|edge| {
                    // Only mutate inter-subnet edges
                    if (edge.source == interface_id || edge.target == interface_id)
                        && !ctx.edge_is_intra_subnet(edge)
                    {
                        edge.source_handle = override_handle;
                        edge.target_handle = override_handle;
                    }
                });
            }
        }

        // Return ALL edges for this interface (inter-subnet + intra-subnet, including VM edges)
        edges
            .iter()
            .filter(|edge| edge.source == interface_id || edge.target == interface_id)
            .cloned()
            .collect()
    }

    /// Determine whether to override edge handles
    fn determine_override_handle(
        handle_counts: &HashMap<EdgeHandle, usize>,
        is_infra: bool,
        interface_id: Uuid,
        edges: &[Edge],
        ctx: &TopologyContext,
    ) -> Option<EdgeHandle> {
        if handle_counts.is_empty() {
            return None;
        }

        // Get edge counts
        let top_count = *handle_counts.get(&EdgeHandle::Top).unwrap_or(&0);
        let bottom_count = *handle_counts.get(&EdgeHandle::Bottom).unwrap_or(&0);
        let left_count = *handle_counts.get(&EdgeHandle::Left).unwrap_or(&0);
        let right_count = *handle_counts.get(&EdgeHandle::Right).unwrap_or(&0);

        // Check for opposing edges
        let has_opposing_vertical = top_count > 0 && bottom_count > 0;
        let has_opposing_horizontal = left_count > 0 && right_count > 0;

        // Get subnet info
        let subnet = ctx.get_subnet_from_interface_id(interface_id);
        let subnet_node_count = if let Some(subnet) = subnet {
            ctx.interfaces
                .iter()
                .filter(|i| i.base.subnet_id == subnet.id)
                .count()
        } else {
            0
        };

        // Key decision logic:
        // 1. If we have opposing vertical edges AND the subnet has multiple nodes (3+),
        //    we should place the node on the edge (Left for infra, Right for non-infra)
        //    to avoid edges crossing through the middle of the subnet
        // 2. Otherwise, prefer the handle with the most edges

        if has_opposing_vertical && subnet_node_count >= 3 {
            // Check if edges would actually cross nodes
            let would_cross = Self::would_vertical_edges_cross_middle(interface_id, edges, ctx);

            if would_cross {
                // Place on the appropriate edge to avoid crossing
                let override_handle = if is_infra {
                    EdgeHandle::Left
                } else {
                    EdgeHandle::Right
                };

                return Some(override_handle);
            }
        }

        // If we have opposing horizontal edges and they would cross nodes,
        // prefer vertical placement
        if has_opposing_horizontal && subnet_node_count >= 3 {
            let would_cross = Self::would_horizontal_edges_cross_middle(interface_id, edges, ctx);

            if would_cross {
                let override_handle = if bottom_count >= top_count {
                    EdgeHandle::Bottom
                } else {
                    EdgeHandle::Top
                };
                return Some(override_handle);
            }
        }

        None
    }

    /// Check if vertical edges (top/bottom) would cross through the middle of the subnet
    fn would_vertical_edges_cross_middle(
        interface_id: Uuid,
        edges: &[Edge],
        ctx: &TopologyContext,
    ) -> bool {
        // If this node has edges going both up and down to different subnets,
        // and the subnet has other nodes, then vertical edges would cross the middle
        let mut has_upward_edge = false;
        let mut has_downward_edge = false;

        for edge in edges {
            if edge.source != interface_id && edge.target != interface_id {
                continue;
            }

            // Get the other end
            let other_interface = if edge.source == interface_id {
                edge.target
            } else {
                edge.source
            };

            // Check if it's in a different subnet
            let this_subnet = ctx.get_subnet_from_interface_id(interface_id);
            let other_subnet = ctx.get_subnet_from_interface_id(other_interface);

            if this_subnet.map(|s| s.id) == other_subnet.map(|s| s.id) {
                continue; // Same subnet, skip
            }

            // Check the handle direction
            let relevant_handle = if edge.source == interface_id {
                &edge.source_handle
            } else {
                &edge.target_handle
            };

            match relevant_handle {
                EdgeHandle::Top => has_upward_edge = true,
                EdgeHandle::Bottom => has_downward_edge = true,
                _ => {}
            }
        }

        has_upward_edge && has_downward_edge
    }

    /// Check if horizontal edges (left/right) would cross through the middle of the subnet
    fn would_horizontal_edges_cross_middle(
        interface_id: Uuid,
        edges: &[Edge],
        ctx: &TopologyContext,
    ) -> bool {
        let mut has_leftward_edge = false;
        let mut has_rightward_edge = false;

        for edge in edges {
            if edge.source != interface_id && edge.target != interface_id {
                continue;
            }

            let other_interface = if edge.source == interface_id {
                edge.target
            } else {
                edge.source
            };

            let this_subnet = ctx.get_subnet_from_interface_id(interface_id);
            let other_subnet = ctx.get_subnet_from_interface_id(other_interface);

            if this_subnet.map(|s| s.id) == other_subnet.map(|s| s.id) {
                continue;
            }

            let relevant_handle = if edge.source == interface_id {
                &edge.source_handle
            } else {
                &edge.target_handle
            };

            match relevant_handle {
                EdgeHandle::Left => has_leftward_edge = true,
                EdgeHandle::Right => has_rightward_edge = true,
                _ => {}
            }
        }

        has_leftward_edge && has_rightward_edge
    }
}
