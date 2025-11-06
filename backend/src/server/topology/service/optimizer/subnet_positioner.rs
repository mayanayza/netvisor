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

/// Subnet positioner using barycenter/median heuristic
///
/// ALGORITHM: Weighted Barycenter Heuristic (from Sugiyama Framework) with Grid-Aware Optimization
///
/// This positions subnets by aligning them with their external connection targets.
///
/// Key principles:
/// - Uses weighted median (not mean) for robustness against outliers
/// - Edge weighting: vertical edges (weight=5), mixed edges (weight=1), horizontal edges (weight=0)
/// - Positions based on external node centers, not subnet centers
/// - Optimizes all subnets simultaneously in each iteration
/// - Applies non-overlap constraints to prevent subnet collisions
/// - When optimal position is rejected, tries nearby grid-aligned alternatives
/// - Iterates until convergence or max iterations reached
/// - Grid snapping happens AFTER optimization to avoid local minima at grid boundaries
pub struct SubnetPositioner<'a> {
    max_iterations: usize,
    context: &'a TopologyContext<'a>,
    utils: OptimizerUtils,
}

impl<'a> SubnetPositioner<'a> {
    pub fn new(ctx: &'a TopologyContext<'a>) -> Self {
        Self {
            max_iterations: 20,
            context: ctx,
            utils: OptimizerUtils::new(),
        }
    }

    /// Snap a position to the nearest grid point for visual alignment
    fn snap_to_grid(value: f64) -> isize {
        ((value / GRID_SIZE as f64).round() as isize) * GRID_SIZE
    }

    /// Main optimization: optimize all subnets simultaneously based on their connections
    ///
    /// This implements an iterative refinement approach with intelligent grid-aware fallback:
    /// 1. For each subnet, calculate optimal X position using weighted median heuristic
    /// 2. Snap to grid and apply non-overlap constraints
    /// 3. Evaluate if total edge length improved
    /// 4. If no improvement, try alternative grid-aligned positions near optimal
    /// 5. Accept the best improvement found, or stop if none exist
    ///
    /// Stops when: no improvement across all candidates OR max iterations reached
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

        let mut iteration = 0;

        while iteration < self.max_iterations {
            iteration += 1;

            // Save current positions (not original - current after previous iterations)
            let current_positions: HashMap<Uuid, isize> = nodes
                .iter()
                .filter_map(|n| match n.node_type {
                    NodeType::SubnetNode { .. } => Some((n.id, n.position.x)),
                    _ => None,
                })
                .collect();

            // Calculate current edge length
            let current_length = self
                .utils
                .calculate_total_edge_length(nodes, &inter_subnet_edges);

            // Calculate optimal positions
            let mut optimal_positions: HashMap<Uuid, isize> = HashMap::new();
            for &subnet_id in &subnet_ids {
                let optimal_x = self.calculate_optimal_x(nodes, &inter_subnet_edges, subnet_id);
                optimal_positions.insert(subnet_id, optimal_x);
            }

            // Apply non-overlap constraints
            let mut new_positions: HashMap<Uuid, isize> = HashMap::new();
            for &subnet_id in &subnet_ids {
                let optimal_x = optimal_positions.get(&subnet_id).copied().unwrap_or(0);
                let snapped_optimal = Self::snap_to_grid(optimal_x as f64);
                let constrained_x = self.apply_non_overlap_constraint(
                    nodes,
                    subnet_id,
                    snapped_optimal,
                    &new_positions,
                );
                new_positions.insert(subnet_id, constrained_x);
            }

            // Apply new positions
            self.apply_positions(nodes, &new_positions);

            // Calculate new edge length
            let new_length = self
                .utils
                .calculate_total_edge_length(nodes, &inter_subnet_edges);

            // Revert if this worsened things
            if new_length >= current_length {
                self.apply_positions(nodes, &current_positions);
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

    /// Helper to apply a set of positions to nodes
    fn apply_positions(&self, nodes: &mut [Node], positions: &HashMap<Uuid, isize>) {
        for (subnet_id, new_x) in positions {
            if let Some(subnet) = nodes.iter_mut().find(|n| n.id == *subnet_id) {
                subnet.position.x = *new_x;
            }
        }
    }

    /// Calculate optimal X position for a subnet by testing positions to minimize edge length
    ///
    /// Instead of complex geometric calculations, we simply test different X positions
    /// and pick the one that minimizes total weighted edge length.
    fn calculate_optimal_x(&self, nodes: &mut [Node], edges: &[Edge], subnet_id: Uuid) -> isize {
        let current_subnet = match nodes.iter().find(|n| n.id == subnet_id) {
            Some(s) => s,
            None => return 0,
        };

        let current_x = current_subnet.position.x;

        // Get all edges involving this subnet
        let subnet_edges: Vec<Edge> = edges
            .iter()
            .filter(|e| {
                let source_subnet = self.context.get_node_subnet(e.source, nodes);
                let target_subnet = self.context.get_node_subnet(e.target, nodes);
                source_subnet == Some(subnet_id) || target_subnet == Some(subnet_id)
            })
            .cloned()
            .collect();

        if subnet_edges.is_empty() {
            return current_x;
        }

        // Test a range of positions around the current position
        let search_range = 800; // pixels to search on each side
        let step_size = GRID_SIZE; // test every grid position

        let mut best_x = current_x;
        let mut best_length = self.utils.calculate_total_edge_length(nodes, &subnet_edges);

        // Test positions in the search range
        for test_x in
            ((current_x - search_range)..=(current_x + search_range)).step_by(step_size as usize)
        {
            // Temporarily move subnet to test position
            if let Some(subnet) = nodes.iter_mut().find(|n| n.id == subnet_id) {
                subnet.position.x = test_x;
            }

            let test_length = self.utils.calculate_total_edge_length(nodes, &subnet_edges);

            if test_length < best_length {
                best_length = test_length;
                best_x = test_x;
            }
        }

        // Restore current position (will be set to optimal by caller)
        if let Some(subnet) = nodes.iter_mut().find(|n| n.id == subnet_id) {
            subnet.position.x = current_x;
        }

        best_x
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

        let current_x = current_subnet.position.x;
        let y = current_subnet.position.y;
        let width = current_subnet.size.x as isize;
        let padding = 50;

        // Limit maximum movement per iteration
        // With weighted median, we may need larger moves to align with high-priority vertical edges
        let max_move = 400;
        let bounded_proposed_x = if (proposed_x - current_x).abs() > max_move {
            if proposed_x > current_x {
                current_x + max_move
            } else {
                current_x - max_move
            }
        } else {
            proposed_x
        };

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

            let proposed_right = bounded_proposed_x + width;
            let other_right = other_x + other_width;

            if bounded_proposed_x < other_right + padding && proposed_right + padding > other_x {
                let constrained_x = if current_x < other_x {
                    (other_x - width - padding).min(bounded_proposed_x)
                } else {
                    (other_right + padding).max(bounded_proposed_x)
                };

                return constrained_x;
            }
        }

        bounded_proposed_x
    }
}
