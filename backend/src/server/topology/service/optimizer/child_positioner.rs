use std::collections::HashMap;
use uuid::Uuid;

use crate::server::topology::{
    service::{
        context::TopologyContext, optimizer::utils::OptimizerUtils, planner::utils::NODE_PADDING,
    },
    types::{
        edges::{Edge, EdgeHandle},
        layout::{Ixy, Uxy},
        nodes::{Node, NodeType},
    },
};

/// Position constraints for a node based on its inter-subnet edge handles
#[derive(Debug, Clone, Default)]
struct NodeConstraints {
    /// Must stay in top row
    pin_top: bool,
    /// Must stay in bottom row
    pin_bottom: bool,
    /// Must stay in left column
    pin_left: bool,
    /// Must stay in right column
    pin_right: bool,
    /// Is this node in the infra zone (cannot swap with non-infra)
    is_infra: bool,
}

/// Parameters for zone optimization to reduce function argument count
struct OptimizeZoneParams<'a> {
    edges: &'a [&'a Edge],
    constraints: &'a HashMap<Uuid, NodeConstraints>,
    subnet_positions: &'a HashMap<Uuid, Ixy>,
}

/// Optimizer for positioning child nodes (interface nodes) within subnets
/// Uses force-directed scoring with grid-based swaps
pub struct ChildPositioner<'a> {
    context: &'a TopologyContext<'a>,
    utils: OptimizerUtils,
}

impl<'a> ChildPositioner<'a> {
    pub fn new(ctx: &'a TopologyContext<'a>) -> Self {
        Self {
            context: ctx,
            utils: OptimizerUtils::new(),
        }
    }

    /// Optimize node positions using force-directed scoring with grid swaps
    pub fn optimize_positions(&self, nodes: &mut [Node], edges: &[Edge]) {
        // Build constraint map for all nodes
        let constraints = self.build_constraint_map(nodes, edges);

        let subnet_positions: HashMap<Uuid, Ixy> = nodes
            .iter()
            .filter_map(|n| match n.node_type {
                NodeType::SubnetNode { .. } => Some((n.id, n.position)),
                _ => None,
            })
            .collect();

        let inter_edges: Vec<Edge> = edges
            .iter()
            .filter(|edge| !self.context.edge_is_intra_subnet(edge))
            .cloned()
            .collect();

        // Group nodes by (subnet, infra)
        let mut nodes_by_subnet_infra: HashMap<(Uuid, bool), Vec<Uuid>> = HashMap::new();
        for node in nodes.iter() {
            if let NodeType::InterfaceNode {
                subnet_id,
                is_infra,
                ..
            } = node.node_type
            {
                nodes_by_subnet_infra
                    .entry((subnet_id, is_infra))
                    .or_default()
                    .push(node.id);
            }
        }

        // For each subnet+infra zone, optimize
        for ((_, _), node_ids) in nodes_by_subnet_infra.iter() {
            if node_ids.len() < 2 {
                continue;
            }

            // Get edges for this zone
            let zone_edges: Vec<Edge> = edges
                .iter()
                .filter(|e| node_ids.contains(&e.source) || node_ids.contains(&e.target))
                .cloned()
                .collect();

            // Combine zone edges and inter-subnet edges for scoring
            let all_edges: Vec<&Edge> = zone_edges.iter().chain(inter_edges.iter()).collect();

            let params = OptimizeZoneParams {
                edges: &all_edges,
                constraints: &constraints,
                subnet_positions: &subnet_positions,
            };

            // Optimize using force-directed swapping
            self.optimize_zone_with_swaps(nodes, node_ids, &params);
        }
    }

    /// Build constraint map from inter-subnet edge handles
    fn build_constraint_map(
        &self,
        nodes: &[Node],
        edges: &[Edge],
    ) -> HashMap<Uuid, NodeConstraints> {
        let mut constraints: HashMap<Uuid, NodeConstraints> = HashMap::new();

        // First, set infra status for all interface nodes
        for node in nodes {
            if let NodeType::InterfaceNode { is_infra, .. } = node.node_type {
                let constraint = constraints.entry(node.id).or_default();
                constraint.is_infra = is_infra;
            }
        }

        // Then add edge handle constraints
        for edge in edges {
            // Only consider inter-subnet edges (not intra-subnet)
            if self.context.edge_is_intra_subnet(edge) {
                continue;
            }

            // Check source node's handle
            if nodes.iter().any(|n| {
                n.id == edge.source && matches!(n.node_type, NodeType::InterfaceNode { .. })
            }) {
                let constraint = constraints.entry(edge.source).or_default();
                match edge.source_handle {
                    EdgeHandle::Top => constraint.pin_top = true,
                    EdgeHandle::Bottom => constraint.pin_bottom = true,
                    EdgeHandle::Left => constraint.pin_left = true,
                    EdgeHandle::Right => constraint.pin_right = true,
                }
            }

            // Check target node's handle
            if nodes.iter().any(|n| {
                n.id == edge.target && matches!(n.node_type, NodeType::InterfaceNode { .. })
            }) {
                let constraint = constraints.entry(edge.target).or_default();
                match edge.target_handle {
                    EdgeHandle::Top => constraint.pin_top = true,
                    EdgeHandle::Bottom => constraint.pin_bottom = true,
                    EdgeHandle::Left => constraint.pin_left = true,
                    EdgeHandle::Right => constraint.pin_right = true,
                }
            }
        }

        constraints
    }

    /// Optimize a zone using force-directed scoring and grid swaps
    fn optimize_zone_with_swaps(
        &self,
        nodes: &mut [Node],
        node_ids: &[Uuid],
        params: &OptimizeZoneParams,
    ) {
        const MAX_ITERATIONS: usize = 100;

        tracing::debug!("Starting zone optimization with {} nodes", node_ids.len());

        let initial_score =
            self.calculate_layout_score(nodes, params.edges, params.subnet_positions);
        let mut best_score = initial_score;
        let mut no_improvement_count = 0;

        // Optimize with gradually decreasing tolerance (simulated annealing)
        for iteration in 0..MAX_ITERATIONS {
            let tolerance_pct = 0.05 * (1.0 - (iteration as f64 / MAX_ITERATIONS as f64));
            let tolerance = best_score * tolerance_pct;

            let swaps_made = self.try_all_swaps(nodes, node_ids, params, tolerance);

            let new_score =
                self.calculate_layout_score(nodes, params.edges, params.subnet_positions);

            if new_score < best_score {
                best_score = new_score;
                no_improvement_count = 0;
                tracing::debug!(
                    "  Iteration {}: {} swaps, new best score: {:.2}",
                    iteration,
                    swaps_made,
                    new_score
                );
            } else {
                no_improvement_count += 1;
            }

            if no_improvement_count >= 5 {
                tracing::debug!("  Converged after {} iterations", iteration + 1);
                break;
            }
        }

        tracing::debug!(
            "  Optimization complete: {:.2} -> {:.2} ({:.1}% improvement)",
            initial_score,
            best_score,
            ((initial_score - best_score) / initial_score * 100.0)
        );
    }

    /// Try swapping every pair of nodes
    fn try_all_swaps(
        &self,
        nodes: &mut [Node],
        node_ids: &[Uuid],
        params: &OptimizeZoneParams,
        tolerance: f64,
    ) -> usize {
        let mut swaps_made = 0;

        // Try swapping every pair of nodes
        for i in 0..node_ids.len() {
            for j in (i + 1)..node_ids.len() {
                let node_a = node_ids[i];
                let node_b = node_ids[j];

                if self.try_swap(nodes, node_a, node_b, params, tolerance) {
                    swaps_made += 1;
                }
            }
        }

        swaps_made
    }

    /// Try swapping two nodes' positions completely
    fn try_swap(
        &self,
        nodes: &mut [Node],
        node_a: Uuid,
        node_b: Uuid,
        params: &OptimizeZoneParams,
        tolerance: f64,
    ) -> bool {
        // Get constraints and info for both nodes
        let constraint_a = params.constraints.get(&node_a).cloned().unwrap_or_default();
        let constraint_b = params.constraints.get(&node_b).cloned().unwrap_or_default();

        // Cannot swap across infra/non-infra boundary
        if constraint_a.is_infra != constraint_b.is_infra {
            return false;
        }

        // Get current positions and sizes
        let mut node_a_info: Option<(Ixy, Uxy)> = None;
        let mut node_b_info: Option<(Ixy, Uxy)> = None;

        for node in nodes.iter() {
            if node.id == node_a {
                node_a_info = Some((node.position, node.size));
            } else if node.id == node_b {
                node_b_info = Some((node.position, node.size));
            }
        }

        let ((a_pos, a_size), (b_pos, b_size)) = match (node_a_info, node_b_info) {
            (Some(a), Some(b)) => (a, b),
            _ => return false,
        };

        // Check if swap violates positional constraints
        let dx = b_pos.x - a_pos.x;
        let dy = b_pos.y - a_pos.y;

        if dx != 0 {
            // Would change x position
            if constraint_a.pin_left
                || constraint_a.pin_right
                || constraint_b.pin_left
                || constraint_b.pin_right
            {
                return false;
            }
        }

        if dy != 0 {
            // Would change y position
            if constraint_a.pin_top
                || constraint_a.pin_bottom
                || constraint_b.pin_top
                || constraint_b.pin_bottom
            {
                return false;
            }
        }

        // Check if swap would cause overlaps
        for node in nodes.iter() {
            if node.id == node_a || node.id == node_b {
                continue;
            }

            // Check if node_a at node_b's position would overlap with this node
            if self.utils.rectangles_overlap(
                Ixy {
                    x: b_pos.x,
                    y: b_pos.y,
                },
                Uxy {
                    x: a_size.x,
                    y: a_size.y,
                },
                Ixy {
                    x: node.position.x,
                    y: node.position.y,
                },
                Uxy {
                    x: node.size.x,
                    y: node.size.y,
                },
            ) {
                return false;
            }

            // Check if node_b at node_a's position would overlap with this node
            if self.utils.rectangles_overlap(
                Ixy {
                    x: a_pos.x,
                    y: a_pos.y,
                },
                Uxy {
                    x: b_size.x,
                    y: b_size.y,
                },
                Ixy {
                    x: node.position.x,
                    y: node.position.y,
                },
                Uxy {
                    x: node.size.x,
                    y: node.size.y,
                },
            ) {
                return false;
            }
        }

        // Calculate current score
        let current_score =
            self.calculate_layout_score(nodes, params.edges, params.subnet_positions);

        // Perform swap
        for node in nodes.iter_mut() {
            if node.id == node_a {
                node.position = b_pos;
            } else if node.id == node_b {
                node.position = a_pos;
            }
        }

        // Calculate new score
        let new_score = self.calculate_layout_score(nodes, params.edges, params.subnet_positions);

        let score_delta = new_score - current_score;

        // Accept if better OR within tolerance
        if new_score < current_score + tolerance {
            // Log successful swaps that aren't strict improvements
            if score_delta > 0.0 && score_delta <= tolerance {
                tracing::debug!(
                    "    Accepted swap with tolerance: delta={:.2}, tolerance={:.2}",
                    score_delta,
                    tolerance
                );
            }
            true
        } else {
            // Revert swap
            for node in nodes.iter_mut() {
                if node.id == node_a {
                    node.position = a_pos;
                } else if node.id == node_b {
                    node.position = b_pos;
                }
            }

            // Log rejected swaps that were close
            if score_delta > 0.0 && score_delta < tolerance * 2.0 {
                tracing::debug!(
                    "    Rejected swap: delta={:.2}, tolerance={:.2}",
                    score_delta,
                    tolerance
                );
            }

            false
        }
    }

    /// Calculate a score for the current layout (lower is better)
    /// Uses force-directed principles to score edge lengths
    fn calculate_layout_score(
        &self,
        nodes: &[Node],
        edges: &[&Edge],
        subnet_positions: &HashMap<Uuid, Ixy>,
    ) -> f64 {
        let mut score = 0.0;

        // Edge length cost (spring energy)
        for edge in edges {
            let source = nodes.iter().find(|n| n.id == edge.source);
            let target = nodes.iter().find(|n| n.id == edge.target);

            if let (Some(src), Some(tgt)) = (source, target) {
                let src_pos = self.utils.get_absolute_node_center(src, subnet_positions);
                let tgt_pos = self.utils.get_absolute_node_center(tgt, subnet_positions);

                let dx = (tgt_pos.x - src_pos.x) as f64;
                let dy = (tgt_pos.y - src_pos.y) as f64;
                let distance = (dx * dx + dy * dy).sqrt();

                // Weight inter-subnet edges more heavily (they're the important ones)
                let weight = if self.context.edge_is_intra_subnet(edge) {
                    0.5 // Intra-subnet edges are less important
                } else {
                    10.0 // Inter-subnet edges are critical
                };

                score += distance * weight;
            }
        }

        score
    }

    // compress_vertical_spacing with logging
    pub fn compress_vertical_spacing(&self, nodes: &mut [Node]) {
        let mut nodes_by_subnet_and_x: HashMap<(Uuid, isize), Vec<usize>> = HashMap::new();

        // Map node indices by subnet and x position
        nodes.iter().enumerate().for_each(|(idx, n)| {
            if let NodeType::InterfaceNode { subnet_id, .. } = n.node_type {
                nodes_by_subnet_and_x
                    .entry((subnet_id, n.position.x))
                    .or_default()
                    .push(idx);
            }
        });

        // For each subnet, find the minimum Y position across all columns
        let mut min_y_by_subnet: HashMap<Uuid, isize> = HashMap::new();

        for ((subnet_id, _), indices) in nodes_by_subnet_and_x.iter() {
            for &idx in indices {
                let y = nodes[idx].position.y;
                min_y_by_subnet
                    .entry(*subnet_id)
                    .and_modify(|min_y| *min_y = (*min_y).min(y))
                    .or_insert(y);
            }
        }

        // Compress each column
        for ((subnet_id, _), indices) in nodes_by_subnet_and_x.iter_mut() {
            // Sort by Y position
            indices.sort_by(|&a, &b| nodes[a].position.y.cmp(&nodes[b].position.y));

            // Start from the subnet's minimum Y
            let start_y = min_y_by_subnet.get(subnet_id).copied().unwrap_or(0);

            if indices.len() == 1 {
                let idx = indices[0];
                nodes[idx].position.y = start_y;
            } else {
                // Multiple nodes - compress them starting from start_y
                let first_idx = indices[0];
                nodes[first_idx].position.y = start_y;

                for i in 1..indices.len() {
                    let prev_idx = indices[i - 1];
                    let curr_idx = indices[i];

                    let above_bottom_padded = nodes[prev_idx].position.y
                        + nodes[prev_idx].size.y as isize
                        + NODE_PADDING.y as isize;

                    nodes[curr_idx].position.y = above_bottom_padded;
                }
            }
        }
    }

    /// Fix intra-subnet edge handles based on actual node positions
    pub fn fix_intra_subnet_handles(&self, edges: &[Edge], nodes: &[Node]) -> Vec<Edge> {
        let result: Vec<Edge> = edges
            .iter()
            .map(|edge| {
                if !self.context.edge_is_intra_subnet(edge) {
                    return edge.clone();
                }

                let source_node = nodes.iter().find(|n| n.id == edge.source);
                let target_node = nodes.iter().find(|n| n.id == edge.target);

                if let (Some(src), Some(tgt)) = (source_node, target_node) {
                    let (src_handle, tgt_handle) = self.calculate_optimal_handles(src, tgt);

                    Edge {
                        source_handle: src_handle,
                        target_handle: tgt_handle,
                        ..edge.clone()
                    }
                } else {
                    edge.clone()
                }
            })
            .collect();

        result
    }

    /// Calculate optimal edge handles by trying all combinations and selecting shortest path
    fn calculate_optimal_handles(&self, source: &Node, target: &Node) -> (EdgeHandle, EdgeHandle) {
        // Define relative position vector from source to target (using centers)
        let src_center_x = source.position.x + (source.size.x as isize / 2);
        let src_center_y = source.position.y + (source.size.y as isize / 2);
        let tgt_center_x = target.position.x + (target.size.x as isize / 2);
        let tgt_center_y = target.position.y + (target.size.y as isize / 2);

        let relative_x = (tgt_center_x - src_center_x) as f64;
        let relative_y = (tgt_center_y - src_center_y) as f64;

        let avg_dimension =
            ((source.size.x + source.size.y + target.size.x + target.size.y) / 4) as f64;
        let scale = avg_dimension * 0.1;

        // Define all handle combinations with their direction vectors
        let all_handles = [
            (EdgeHandle::Top, 0.0, -scale),
            (EdgeHandle::Bottom, 0.0, scale),
            (EdgeHandle::Left, -scale, 0.0),
            (EdgeHandle::Right, scale, 0.0),
        ];

        let mut best_combination = (EdgeHandle::Top, EdgeHandle::Bottom);
        let mut best_distance = f64::MAX;
        let mut all_scores = Vec::new();

        // Try all 16 combinations
        for &(src_handle, src_dx, src_dy) in &all_handles {
            for &(tgt_handle, tgt_dx, tgt_dy) in &all_handles {
                let start_x = 0.0 + src_dx;
                let start_y = 0.0 + src_dy;

                let end_x = relative_x + tgt_dx;
                let end_y = relative_y + tgt_dy;

                let path_x = end_x - start_x;
                let path_y = end_y - start_y;

                // Calculate Manhattan distance
                let distance = path_x.abs() + path_y.abs();

                // Calculate routing complexity penalty
                // Prefer handles that align with the primary direction of travel
                let is_aligned = if relative_x.abs() > relative_y.abs() {
                    // Primarily horizontal movement
                    src_handle.is_horizontal() && tgt_handle.is_horizontal()
                } else {
                    // Primarily vertical movement
                    src_handle.is_vertical() && tgt_handle.is_vertical()
                };

                // Add small penalty for non-aligned routing (breaks ties)
                let complexity_penalty = if is_aligned { 0.0 } else { 0.1 };
                let total_score = distance + complexity_penalty;

                all_scores.push((src_handle, tgt_handle, distance, total_score));

                if total_score < best_distance {
                    best_distance = total_score;
                    best_combination = (src_handle, tgt_handle);
                }
            }
        }

        best_combination
    }
}
