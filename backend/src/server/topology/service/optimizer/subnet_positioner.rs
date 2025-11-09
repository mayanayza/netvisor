use std::collections::HashMap;
use uuid::Uuid;

use crate::server::topology::{
    service::{context::TopologyContext, optimizer::utils::OptimizerUtils},
    types::{
        edges::Edge,
        nodes::{Node, NodeType},
    },
};

const GRID_SIZE: isize = 25;
const CONVERGENCE_THRESHOLD: f64 = 1.0; // Stop when improvement < 1.0 pixels

/// Subnet positioner using layer-by-layer sweep with barycenter heuristic
///
/// ALGORITHM: Layer-by-Layer Sweep (Sugiyama Framework)
///
/// This implements the academically proven approach for hierarchical graph layout:
/// - DOWN sweep: optimize each layer based on connections to the layer above
/// - UP sweep: optimize each layer based on connections to the layer below
/// - Positions are updated incrementally as we sweep through layers
/// - This breaks circular dependencies that cause oscillation
///
/// CRITICAL: Edges connect InterfaceNodes (children), not SubnetNodes!
/// - InterfaceNode absolute position = subnet.x + interface.x
/// - Handle center = subnet.x + interface.x + interface.width/2
/// - For straight vertical edges, handle centers must align
///
/// Key principles:
/// - Each subnet is positioned to align its child interface handles with neighbor handles
/// - Positions are applied immediately during the sweep (not all at once)
/// - Alternating sweeps converge to a stable layout
/// - Edge weighting: vertical=100, mixed=1, horizontal/multi-hop=0
/// - Grid snapping happens AFTER optimization to avoid local minima
/// - Non-overlap constraints prevent subnet collisions in the same row
pub struct SubnetPositioner<'a> {
    max_iterations: usize,
    context: &'a TopologyContext<'a>,
    utils: OptimizerUtils,
}

impl<'a> SubnetPositioner<'a> {
    pub fn new(ctx: &'a TopologyContext<'a>) -> Self {
        Self {
            max_iterations: 10,
            context: ctx,
            utils: OptimizerUtils::new(),
        }
    }

    /// Snap a position to the nearest grid point for visual alignment
    fn snap_to_grid(value: f64) -> isize {
        ((value / GRID_SIZE as f64).round() as isize) * GRID_SIZE
    }

    /// Main optimization: layer-by-layer sweep approach
    ///
    /// This implements the proven Sugiyama approach:
    /// 1. Group subnets by layer (Y position)
    /// 2. DOWN sweep: optimize each layer based on layer above
    /// 3. UP sweep: optimize each layer based on layer below
    /// 4. Repeat until convergence or max iterations
    pub fn optimize_positions(&self, nodes: &mut [Node], edges: &[Edge]) {
        let subnet_ids: Vec<Uuid> = nodes
            .iter()
            .filter_map(|n| match n.node_type {
                NodeType::SubnetNode { .. } => Some(n.id),
                _ => None,
            })
            .collect();

        if subnet_ids.is_empty() {
            return;
        }

        let inter_subnet_edges: Vec<Edge> = edges
            .iter()
            .filter(|e| !self.context.edge_is_intra_subnet(e))
            .cloned()
            .collect();

        // Group subnets by layer (Y position)
        let layers = self.group_subnets_by_layer(nodes, &subnet_ids);

        let mut iteration = 0;

        while iteration < self.max_iterations {
            iteration += 1;

            let prev_length = self
                .utils
                .calculate_total_edge_length(nodes, &inter_subnet_edges);

            // DOWN sweep: optimize each layer based on the layer above
            for layer_idx in 1..layers.len() {
                self.optimize_layer(nodes, &inter_subnet_edges, &layers, layer_idx, true);
            }

            // UP sweep: optimize each layer based on the layer below
            for layer_idx in (0..layers.len() - 1).rev() {
                self.optimize_layer(nodes, &inter_subnet_edges, &layers, layer_idx, false);
            }

            let new_length = self
                .utils
                .calculate_total_edge_length(nodes, &inter_subnet_edges);

            let improvement = prev_length - new_length;

            // Stop if improvement is negligible
            if improvement < CONVERGENCE_THRESHOLD {
                break;
            }
        }

        // NOW snap all positions to grid for visual alignment
        for subnet_id in &subnet_ids {
            if let Some(subnet) = nodes.iter_mut().find(|n| n.id == *subnet_id) {
                let original_x = subnet.position.x;
                let snapped_x = Self::snap_to_grid(original_x as f64);
                subnet.position.x = snapped_x;
            }
        }
    }

    /// Group subnets by their Y position (layer)
    fn group_subnets_by_layer(&self, nodes: &[Node], subnet_ids: &[Uuid]) -> Vec<Vec<Uuid>> {
        let mut layers: HashMap<isize, Vec<Uuid>> = HashMap::new();

        for &subnet_id in subnet_ids {
            if let Some(subnet) = nodes.iter().find(|n| n.id == subnet_id) {
                layers.entry(subnet.position.y).or_default().push(subnet_id);
            }
        }

        // Sort layers by Y position and return as Vec
        let mut sorted_layers: Vec<(isize, Vec<Uuid>)> = layers.into_iter().collect();
        sorted_layers.sort_by_key(|(y, _)| *y);

        sorted_layers.into_iter().map(|(_, layer)| layer).collect()
    }

    /// Optimize a layer based on connections to adjacent layer
    ///
    /// down_sweep: true = optimize based on layer above, false = layer below
    fn optimize_layer(
        &self,
        nodes: &mut [Node],
        edges: &[Edge],
        layers: &[Vec<Uuid>],
        layer_idx: usize,
        down_sweep: bool,
    ) {
        let current_layer = &layers[layer_idx];

        // Track positions as we go for non-overlap constraints
        let mut positioned_in_layer: HashMap<Uuid, isize> = HashMap::new();

        // For each subnet in this layer, calculate optimal position based on neighbors
        for &subnet_id in current_layer {
            let optimal_x = self.calculate_barycenter_position(
                nodes, edges, subnet_id, layers, layer_idx, down_sweep,
            );

            // Apply non-overlap constraint
            let constrained_x = self.apply_non_overlap_constraint(
                nodes,
                subnet_id,
                optimal_x,
                &positioned_in_layer,
            );

            // Apply position immediately
            if let Some(subnet) = nodes.iter_mut().find(|n| n.id == subnet_id) {
                subnet.position.x = constrained_x;
            }

            positioned_in_layer.insert(subnet_id, constrained_x);
        }
    }

    /// Calculate the barycenter (weighted median) position for a subnet
    /// based on its neighbors in other layers
    ///
    /// CRITICAL: Edges connect InterfaceNodes (children), not SubnetNodes!
    /// InterfaceNode absolute position = subnet.x + interface.x
    /// Handle center = subnet.x + interface.x + interface.width/2
    ///
    /// For straight vertical edges, we need to align handle centers:
    /// target_subnet.x + target_interface.x + target_interface.width/2
    ///   = source_subnet.x + source_interface.x + source_interface.width/2
    ///
    /// Therefore:
    /// target_subnet.x = source_handle_absolute_x - target_interface.x - target_interface.width/2
    fn calculate_barycenter_position(
        &self,
        nodes: &[Node],
        edges: &[Edge],
        subnet_id: Uuid,
        layers: &[Vec<Uuid>],
        layer_idx: usize,
        down_sweep: bool,
    ) -> isize {
        let current_subnet = match nodes.iter().find(|n| n.id == subnet_id) {
            Some(s) => s,
            None => return 0,
        };

        // Find all edges connecting this subnet to other layers
        // We consider connections in the sweep direction (above for DOWN, below for UP)
        let mut neighbor_positions: Vec<(f64, f64)> = Vec::new(); // (desired subnet.x, weight)

        for edge in edges {
            // Check if this edge involves our subnet
            let source_subnet = self.context.get_node_subnet(edge.source, nodes);
            let target_subnet = self.context.get_node_subnet(edge.target, nodes);

            // Determine which side of the edge we're on
            let (my_node_id, other_node_id, other_subnet_id, i_am_source) =
                if source_subnet == Some(subnet_id) {
                    (edge.source, edge.target, target_subnet, true)
                } else if target_subnet == Some(subnet_id) {
                    (edge.target, edge.source, source_subnet, false)
                } else {
                    continue;
                };

            if let Some(other_subnet_id) = other_subnet_id {
                // Find which layer the other subnet is in
                let mut other_layer_idx = None;
                for (idx, layer) in layers.iter().enumerate() {
                    if layer.contains(&other_subnet_id) {
                        other_layer_idx = Some(idx);
                        break;
                    }
                }

                if let Some(other_idx) = other_layer_idx {
                    // Check if this connection is in the sweep direction
                    let is_in_sweep_direction = if down_sweep {
                        other_idx < layer_idx // Other layer is above
                    } else {
                        other_idx > layer_idx // Other layer is below
                    };

                    if !is_in_sweep_direction {
                        continue;
                    }

                    // Calculate edge weight based on handles
                    let weight = self.calculate_edge_weight(edge);

                    if weight > 0.0 {
                        // Get the actual nodes that connect (could be InterfaceNode or SubnetNode)
                        let my_node = nodes.iter().find(|n| n.id == my_node_id);
                        let other_node = nodes.iter().find(|n| n.id == other_node_id);
                        let other_subnet_node = nodes.iter().find(|n| n.id == other_subnet_id);

                        if let (Some(my_node), Some(other_node), Some(other_subnet)) =
                            (my_node, other_node, other_subnet_node)
                        {
                            let other_handle = if i_am_source {
                                edge.target_handle
                            } else {
                                edge.source_handle
                            };

                            let my_handle = if i_am_source {
                                edge.source_handle
                            } else {
                                edge.target_handle
                            };

                            // Calculate the absolute X position of the other node's handle
                            // Check if other_node is a SubnetNode or InterfaceNode
                            let other_handle_absolute_x = match &other_node.node_type {
                                NodeType::SubnetNode { .. } => {
                                    // SubnetNode: position is already absolute, no parent offset
                                    match other_handle {
                                        crate::server::topology::types::edges::EdgeHandle::Left => {
                                            other_node.position.x
                                        }
                                        crate::server::topology::types::edges::EdgeHandle::Right => {
                                            other_node.position.x + other_node.size.x as isize
                                        }
                                        crate::server::topology::types::edges::EdgeHandle::Top
                                        | crate::server::topology::types::edges::EdgeHandle::Bottom => {
                                            other_node.position.x + (other_node.size.x as isize / 2)
                                        }
                                    }
                                }
                                NodeType::InterfaceNode { .. } => {
                                    // InterfaceNode: position is relative to parent subnet
                                    match other_handle {
                                        crate::server::topology::types::edges::EdgeHandle::Left => {
                                            other_subnet.position.x + other_node.position.x
                                        }
                                        crate::server::topology::types::edges::EdgeHandle::Right => {
                                            other_subnet.position.x + other_node.position.x + other_node.size.x as isize
                                        }
                                        crate::server::topology::types::edges::EdgeHandle::Top
                                        | crate::server::topology::types::edges::EdgeHandle::Bottom => {
                                            other_subnet.position.x + other_node.position.x + (other_node.size.x as isize / 2)
                                        }
                                    }
                                }
                            };

                            // Calculate what our subnet.x should be to align our node's handle
                            // Check if my_node is a SubnetNode or InterfaceNode
                            let desired_subnet_x = match &my_node.node_type {
                                NodeType::SubnetNode { .. } => {
                                    // SubnetNode: we ARE the subnet, just align our center
                                    match my_handle {
                                        crate::server::topology::types::edges::EdgeHandle::Left => {
                                            other_handle_absolute_x
                                        }
                                        crate::server::topology::types::edges::EdgeHandle::Right => {
                                            other_handle_absolute_x - my_node.size.x as isize
                                        }
                                        crate::server::topology::types::edges::EdgeHandle::Top
                                        | crate::server::topology::types::edges::EdgeHandle::Bottom => {
                                            other_handle_absolute_x - (my_node.size.x as isize / 2)
                                        }
                                    }
                                }
                                NodeType::InterfaceNode { .. } => {
                                    // InterfaceNode: we need to account for position within parent subnet
                                    let my_half_width = my_node.size.x as isize / 2;
                                    match my_handle {
                                        crate::server::topology::types::edges::EdgeHandle::Left => {
                                            other_handle_absolute_x - my_node.position.x
                                        }
                                        crate::server::topology::types::edges::EdgeHandle::Right => {
                                            other_handle_absolute_x - my_node.position.x - my_node.size.x as isize
                                        }
                                        crate::server::topology::types::edges::EdgeHandle::Top
                                        | crate::server::topology::types::edges::EdgeHandle::Bottom => {
                                            other_handle_absolute_x - my_node.position.x - my_half_width
                                        }
                                    }
                                }
                            };

                            neighbor_positions.push((desired_subnet_x as f64, weight));
                        }
                    }
                }
            }
        }

        if neighbor_positions.is_empty() {
            return current_subnet.position.x;
        }

        // Calculate weighted median
        let barycenter = self.calculate_weighted_median(&mut neighbor_positions);

        barycenter as isize
    }

    /// Calculate edge weight based on handle types (matching the edge length calculation)
    fn calculate_edge_weight(&self, edge: &Edge) -> f64 {
        let source_is_horizontal = edge.source_handle.is_horizontal();
        let target_is_horizontal = edge.target_handle.is_horizontal();

        if source_is_horizontal && target_is_horizontal {
            // Fully horizontal edge - don't consider
            0.0
        } else if edge.is_multi_hop {
            // Multi-hop edge - don't consider
            0.0
        } else if source_is_horizontal || target_is_horizontal {
            // Mixed edge - low weight
            1.0
        } else {
            // Both handles are vertical - high weight
            100.0
        }
    }

    /// Calculate weighted median using the linear interpolation method
    fn calculate_weighted_median(&self, values: &mut [(f64, f64)]) -> f64 {
        if values.is_empty() {
            return 0.0;
        }

        if values.len() == 1 {
            return values[0].0;
        }

        // Sort by position
        values.sort_by(|a, b| a.0.partial_cmp(&b.0).unwrap());

        // Calculate total weight
        let total_weight: f64 = values.iter().map(|(_, w)| w).sum();
        let half_weight = total_weight / 2.0;

        // Find the weighted median
        let mut cumulative_weight = 0.0;
        for (pos, weight) in values.iter() {
            cumulative_weight += weight;
            if cumulative_weight >= half_weight {
                return *pos;
            }
        }

        // Fallback to last position (shouldn't happen)
        values.last().unwrap().0
    }

    /// Apply constraint to prevent overlapping with other subnets in the same row
    fn apply_non_overlap_constraint(
        &self,
        nodes: &[Node],
        subnet_id: Uuid,
        proposed_x: isize,
        already_positioned: &HashMap<Uuid, isize>,
    ) -> isize {
        let current_subnet = match nodes.iter().find(|n| n.id == subnet_id) {
            Some(s) => s,
            None => return proposed_x,
        };

        let y = current_subnet.position.y;
        let width = current_subnet.size.x as isize;
        let padding = 50;

        // Check against other subnets in the same row
        for other in nodes.iter() {
            if !matches!(other.node_type, NodeType::SubnetNode { .. })
                || other.id == subnet_id
                || other.position.y != y
            {
                continue;
            }

            let other_x = already_positioned
                .get(&other.id)
                .copied()
                .unwrap_or(other.position.x);
            let other_width = other.size.x as isize;

            let proposed_right = proposed_x + width;
            let other_right = other_x + other_width;

            // Check for overlap
            if proposed_x < other_right + padding && proposed_right + padding > other_x {
                // Overlap detected - push to the nearest non-overlapping position
                let push_left = other_x - width - padding;
                let push_right = other_right + padding;

                // Choose the direction that moves the subnet less
                let constrained_x =
                    if (proposed_x - push_left).abs() < (proposed_x - push_right).abs() {
                        push_left
                    } else {
                        push_right
                    };

                return constrained_x;
            }
        }

        proposed_x
    }
}
