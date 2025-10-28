use std::collections::{HashMap, HashSet};
use uuid::Uuid;

use crate::server::topology::{
    service::{context::TopologyContext, optimizer::utils::OptimizerUtils, planner::utils::NODE_PADDING},
    types::{
        base::Ixy,
        edges::{Edge, EdgeHandle, EdgeType},
        nodes::{Node, NodeType},
    },
};

enum HorizontalDirection {
    Left,
    Right,
    Neutral,
}

enum VerticalDirection {
    Up,
    Down,
    Neutral,
}

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

impl NodeConstraints {
    fn can_swap_with(&self, other: &NodeConstraints, is_horizontal: bool) -> bool {
        // Cannot swap across infra/non-infra boundary
        if self.is_infra != other.is_infra {
            return false;
        }

        if is_horizontal {
            // Can swap horizontally if neither has left/right constraints
            !self.pin_left && !self.pin_right && !other.pin_left && !other.pin_right
        } else {
            // Can swap vertically if neither has top/bottom constraints
            !self.pin_top && !self.pin_bottom && !other.pin_top && !other.pin_bottom
        }
    }
}

/// Parameters for zone optimization to reduce function argument count
struct OptimizeZoneParams<'a> {
    edges: &'a [&'a Edge],
    constraints: &'a HashMap<Uuid, NodeConstraints>,
    vm_providers: &'a HashMap<Uuid, HashSet<Uuid>>,
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

        // Find VM provider relationships
        let vm_providers = self.find_vm_provider_hubs(edges);

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
                vm_providers: &vm_providers,
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
            // Only consider inter-subnet edges (not intra-subnet, not VM edges)
            if self.context.edge_is_intra_subnet(edge) || self.is_vm_edge(edge) {
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

    /// Check if an edge is a VM edge
    fn is_vm_edge(&self, edge: &Edge) -> bool {
        matches!(edge.edge_type, EdgeType::HostVirtualization)
    }

    /// Find VM provider hubs (nodes with multiple VM connections)
    fn find_vm_provider_hubs(&self, edges: &[Edge]) -> HashMap<Uuid, HashSet<Uuid>> {
        let mut providers: HashMap<Uuid, HashSet<Uuid>> = HashMap::new();

        for edge in edges {
            if self.is_vm_edge(edge) {
                providers
                    .entry(edge.source)
                    .or_default()
                    .insert(edge.target);
            }
        }

        // Only keep providers with 3+ VMs
        providers.retain(|_, vms| vms.len() >= 3);
        providers
    }

    /// Optimize a zone using force-directed scoring and grid swaps
    fn optimize_zone_with_swaps(
        &self,
        nodes: &mut [Node],
        node_ids: &[Uuid],
        params: &OptimizeZoneParams,
    ) {
        const MAX_ITERATIONS: usize = 50;

        // Try swapping ALL pairs of nodes in the zone (both horizontal and vertical swaps)
        for _iteration in 0..MAX_ITERATIONS {
            let mut improved = false;

            // Try all possible pairs of nodes
            for i in 0..node_ids.len() {
                for j in (i + 1)..node_ids.len() {
                    let node_a = node_ids[i];
                    let node_b = node_ids[j];

                    let node_a_info = nodes.iter().find(|n| n.id == node_a);
                    let node_b_info = nodes.iter().find(|n| n.id == node_b);

                    if let (Some(a), Some(b)) = (node_a_info, node_b_info) {
                        // Determine if this would be a horizontal or vertical swap
                        let is_horizontal = a.position.y == b.position.y;
                        let is_vertical = a.position.x == b.position.x;

                        // Try horizontal swap if they're in the same row
                        if is_horizontal {
                            improved |= self.try_swap_pair(nodes, node_a, node_b, params, true);
                        }

                        // Try vertical swap if they're in the same column
                        if is_vertical {
                            improved |= self.try_swap_pair(nodes, node_a, node_b, params, false);
                        }
                    }
                }
            }

            if !improved {
                break;
            }
        }
    }

    /// Try swapping a specific pair of nodes
    fn try_swap_pair(
        &self,
        nodes: &mut [Node],
        node_a: Uuid,
        node_b: Uuid,
        params: &OptimizeZoneParams,
        is_horizontal: bool,
    ) -> bool {
        // Check if swap is allowed by constraints
        let constraint_a = params.constraints.get(&node_a).cloned().unwrap_or_default();
        let constraint_b = params.constraints.get(&node_b).cloned().unwrap_or_default();

        if !constraint_a.can_swap_with(&constraint_b, is_horizontal) {
            return false;
        }

        // Calculate current score
        let current_score = self.calculate_layout_score(
            nodes,
            params.edges,
            params.vm_providers,
            params.subnet_positions,
        );

        // Try swap
        self.swap_positions(nodes, node_a, node_b, is_horizontal);

        // Calculate new score
        let new_score = self.calculate_layout_score(
            nodes,
            params.edges,
            params.vm_providers,
            params.subnet_positions,
        );

        if new_score < current_score {
            // Keep the swap
            true
        } else {
            // Revert swap
            self.swap_positions(nodes, node_a, node_b, is_horizontal);
            false
        }
    }

    /// Calculate a score for the current layout (lower is better)
    /// Uses force-directed principles to score edge lengths and VM clustering
    fn calculate_layout_score(
        &self,
        nodes: &[Node],
        edges: &[&Edge],
        vm_providers: &HashMap<Uuid, HashSet<Uuid>>,
        subnet_positions: &HashMap<Uuid, Ixy>,
    ) -> f64 {
        let mut score = 0.0;

        // 1. Edge length cost (spring energy)
        for edge in edges {
            let source = nodes.iter().find(|n| n.id == edge.source);
            let target = nodes.iter().find(|n| n.id == edge.target);

            if let (Some(src), Some(tgt)) = (source, target) {
                let src_pos = self.utils.get_absolute_node_center(src, subnet_positions);
                let tgt_pos = self.utils.get_absolute_node_center(tgt, subnet_positions);

                let dx = (tgt_pos.x - src_pos.x) as f64;
                let dy = (tgt_pos.y - src_pos.y) as f64;
                let distance = (dx * dx + dy * dy).sqrt();

                // Weight inter-subnet edges more heavily
                let weight = if self.context.edge_is_intra_subnet(edge) {
                    1.0
                } else {
                    2.0
                };

                score += distance * weight;
            }
        }

        // 2. VM clustering cost (deviation from ideal circular arrangement)
        const IDEAL_VM_RADIUS: f64 = 200.0;

        for (provider_id, vm_ids) in vm_providers {
            let provider = nodes.iter().find(|n| n.id == *provider_id);
            if provider.is_none() {
                continue;
            }
            let provider_node = provider.unwrap();
            let provider_pos = provider_node.position;
            let provider_is_infra = match provider_node.node_type {
                NodeType::InterfaceNode { is_infra, .. } => is_infra,
                _ => false,
            };

            for vm_id in vm_ids {
                let vm = nodes.iter().find(|n| n.id == *vm_id);
                if vm.is_none() {
                    continue;
                }
                let vm_node = vm.unwrap();
                let vm_pos = vm_node.position;
                let vm_is_infra = match vm_node.node_type {
                    NodeType::InterfaceNode { is_infra, .. } => is_infra,
                    _ => false,
                };

                let dx = (vm_pos.x - provider_pos.x) as f64;
                let dy = (vm_pos.y - provider_pos.y) as f64;
                let distance = (dx * dx + dy * dy).sqrt();

                // Check if VM and provider are on opposite sides of infra boundary
                let crosses_infra_boundary = vm_is_infra != provider_is_infra;

                if crosses_infra_boundary {
                    // Heavily penalize horizontal distance when crossing boundary
                    let horizontal_distance = dx.abs();
                    let h_cost = horizontal_distance * 3.0;
                    score += h_cost;

                    // Also penalize vertical distance but less
                    let vertical_distance = dy.abs();
                    let v_cost = vertical_distance * 0.5;
                    score += v_cost;
                } else {
                    // Same infra status - use normal circular clustering
                    let deviation = (distance - IDEAL_VM_RADIUS).abs();
                    let dev_cost = deviation * 3.0; // Heavily weight VM clustering
                    score += dev_cost;
                }
            }

            // Also add direct distance penalty for VMs that are too close in Euclidean space
            let vm_ids_vec: Vec<_> = vm_ids.iter().collect();
            for i in 0..vm_ids_vec.len() {
                for j in (i + 1)..vm_ids_vec.len() {
                    let vm1 = nodes.iter().find(|n| n.id == *vm_ids_vec[i]);
                    let vm2 = nodes.iter().find(|n| n.id == *vm_ids_vec[j]);

                    if let (Some(v1), Some(v2)) = (vm1, vm2) {
                        let dx = (v2.position.x - v1.position.x) as f64;
                        let dy = (v2.position.y - v1.position.y) as f64;
                        let distance = (dx * dx + dy * dy).sqrt().max(1.0);

                        // Penalize VMs that are too close
                        if distance < 150.0 {
                            score += (150.0 - distance) * 0.3;
                        }
                    }
                }
            }

            // Penalize non-VM nodes that are too close to this VM provider
            // This helps keep the "cluster" around the provider clear
            for node in nodes.iter() {
                // Skip if this is a VM of this provider
                if vm_ids.contains(&node.id) {
                    continue;
                }

                // Skip if this is the provider itself
                if node.id == *provider_id {
                    continue;
                }

                // Skip subnet nodes
                if matches!(node.node_type, NodeType::SubnetNode { .. }) {
                    continue;
                }

                let dx = (node.position.x - provider_pos.x) as f64;
                let dy = (node.position.y - provider_pos.y) as f64;
                let distance = (dx * dx + dy * dy).sqrt();

                // Penalize non-VM nodes that are within the ideal VM radius
                if distance < IDEAL_VM_RADIUS {
                    let intrusion_cost = (IDEAL_VM_RADIUS - distance) * 0.8;
                    score += intrusion_cost;
                }
            }
        }

        score
    }

    /// Swap two nodes' positions along a single axis
    fn swap_positions(
        &self,
        nodes: &mut [Node],
        node_a_id: Uuid,
        node_b_id: Uuid,
        is_horizontal: bool,
    ) {
        let mut pos_a: Option<isize> = None;
        let mut pos_b: Option<isize> = None;

        for node in nodes.iter() {
            if node.id == node_a_id {
                pos_a = Some(if is_horizontal {
                    node.position.x
                } else {
                    node.position.y
                });
            } else if node.id == node_b_id {
                pos_b = Some(if is_horizontal {
                    node.position.x
                } else {
                    node.position.y
                });
            }
        }

        if let (Some(a_pos), Some(b_pos)) = (pos_a, pos_b) {
            for node in nodes.iter_mut() {
                if node.id == node_a_id {
                    if is_horizontal {
                        node.position.x = b_pos;
                    } else {
                        node.position.y = b_pos;
                    }
                } else if node.id == node_b_id {
                    if is_horizontal {
                        node.position.x = a_pos;
                    } else {
                        node.position.y = a_pos;
                    }
                }
            }
        }
    }

    pub fn compress_vertical_spacing(&self, nodes: &mut [Node]) {
        let mut nodes_by_subnet_and_x: HashMap<(Uuid, isize), Vec<usize>> = HashMap::new();

        // Map node indices by subnet and x position
        nodes.iter().enumerate().for_each(|(idx, n)| {
            match n.node_type {
                NodeType::InterfaceNode { subnet_id, .. } => {
                    nodes_by_subnet_and_x
                        .entry((subnet_id, n.position.x))
                        .or_default()
                        .push(idx);
                },
                _ => ()
            }
        });

        for ((_, _), indices) in nodes_by_subnet_and_x.iter_mut() {
            
            indices.sort_by(|&a, &b| nodes[a].position.y.cmp(&nodes[b].position.y));

            for i in 1..indices.len() {
                let prev_idx = indices[i - 1];
                let curr_idx = indices[i];
                
                let old_y = nodes[curr_idx].position.y;
                
                let above_bottom_padded = nodes[prev_idx].position.y 
                    + nodes[prev_idx].size.y as isize 
                    + NODE_PADDING.y as isize;
                
                nodes[curr_idx].position.y = above_bottom_padded;
                
                tracing::debug!("Node {}: y {} -> {}", curr_idx, old_y, above_bottom_padded);
            }
        }
    }

    /// Fix intra-subnet edge handles based on actual node positions
    pub fn fix_intra_subnet_handles(&self, edges: &[Edge], nodes: &[Node]) -> Vec<Edge> {
        edges
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
            .collect()
    }

    /// Calculate optimal edge handles based on relative node positions
    fn calculate_optimal_handles(&self, source: &Node, target: &Node) -> (EdgeHandle, EdgeHandle) {
        let dx = target.position.x - source.position.x;
        let dy = target.position.y - source.position.y;

        let horizontal_dir = if dx > 50 {
            HorizontalDirection::Right
        } else if dx < -50 {
            HorizontalDirection::Left
        } else {
            HorizontalDirection::Neutral
        };

        let vertical_dir = if dy > 50 {
            VerticalDirection::Down
        } else if dy < -50 {
            VerticalDirection::Up
        } else {
            VerticalDirection::Neutral
        };

        match (horizontal_dir, vertical_dir) {
            (HorizontalDirection::Right, VerticalDirection::Neutral) => {
                (EdgeHandle::Right, EdgeHandle::Left)
            }
            (HorizontalDirection::Left, VerticalDirection::Neutral) => {
                (EdgeHandle::Left, EdgeHandle::Right)
            }
            (HorizontalDirection::Neutral, VerticalDirection::Down) => {
                (EdgeHandle::Bottom, EdgeHandle::Top)
            }
            (HorizontalDirection::Neutral, VerticalDirection::Up) => {
                (EdgeHandle::Top, EdgeHandle::Bottom)
            }
            (HorizontalDirection::Right, VerticalDirection::Down) => {
                (EdgeHandle::Right, EdgeHandle::Top)
            }
            (HorizontalDirection::Right, VerticalDirection::Up) => {
                (EdgeHandle::Right, EdgeHandle::Bottom)
            }
            (HorizontalDirection::Left, VerticalDirection::Down) => {
                (EdgeHandle::Left, EdgeHandle::Top)
            }
            (HorizontalDirection::Left, VerticalDirection::Up) => {
                (EdgeHandle::Left, EdgeHandle::Bottom)
            }
            (HorizontalDirection::Neutral, VerticalDirection::Neutral) => {
                (EdgeHandle::Top, EdgeHandle::Bottom)
            }
        }
    }
}
