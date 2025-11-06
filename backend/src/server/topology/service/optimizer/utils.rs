use std::collections::HashMap;
use uuid::Uuid;

use crate::server::topology::{
    service::context::TopologyContext,
    types::{
        base::{Ixy, Uxy},
        edges::Edge,
        nodes::{Node, NodeType},
    },
};

/// Composite quality score for graph layout
///
/// QUALITY METRIC DESIGN (Academic Foundation):
/// This implements a multi-objective optimization function following principles from:
/// - Sugiyama et al. (1981): Hierarchical graph drawing with crossing minimization
/// - Eades & Wormald (1994): Edge crossing reduction in graph layout
/// - Purchase (1997): Empirical studies showing crossing minimization improves readability
///
/// Lower scores indicate better quality (minimization problem)
#[derive(Debug, Clone, Copy)]
pub struct LayoutQuality {
    pub total_edge_length: f64,
    pub edge_crossings: usize,

    /// Weighted combination prioritizing quality factors by severity:
    /// Formula: (crossings * 10000) + edge_length
    ///
    /// Hierarchy rationale (based on Purchase 1997 & Ware 2012):
    /// 1. Edge crossings (10000x): Severe - significantly impacts readability (Purchase 1997)
    ///    Each crossing adds cognitive load when tracing paths
    /// 2. Edge length (1x): Aesthetic - shorter edges preferred (Neumann's study)
    ///    Weighted by edge type: vertical edges 5x (bad when kinked), mixed 1x, horizontal 0x
    ///
    /// This weighting ensures the optimizer prioritizes correctness over aesthetics:
    /// eliminating crossings before optimizing edge lengths
    pub weighted_score: f64,
}

impl LayoutQuality {
    pub fn new(total_edge_length: f64, edge_crossings: usize) -> Self {
        // Weight hierarchy: crossings >> length
        // Based on empirical studies of graph readability (Purchase et al.)
        let weighted_score = (edge_crossings as f64 * 10000.0) + total_edge_length;

        Self {
            total_edge_length,
            edge_crossings,
            weighted_score,
        }
    }

    /// Returns true if this quality is better (lower score) than other
    pub fn is_better_than(&self, other: &LayoutQuality) -> bool {
        self.weighted_score < other.weighted_score
    }

    /// Returns the relative improvement as a percentage
    pub fn improvement_percentage(&self, previous: &LayoutQuality) -> f64 {
        if previous.weighted_score == 0.0 {
            return 0.0;
        }
        ((previous.weighted_score - self.weighted_score) / previous.weighted_score) * 100.0
    }
}

/// Utility functions for graph optimization
pub struct OptimizerUtils {}

impl Default for OptimizerUtils {
    fn default() -> Self {
        Self::new()
    }
}

impl OptimizerUtils {
    pub fn new() -> Self {
        Self {}
    }

    // ============================================================================
    // Quality Assessment Methods
    // ============================================================================

    /// Calculate overall quality score for the current graph layout
    ///
    /// ALGORITHM: Multi-Objective Quality Assessment
    ///
    /// This implements a composite quality metric combining two key factors
    /// identified as critical for graph readability in academic literature:
    ///
    /// 1. **Edge Crossings** (Highly Important)  
    ///    - From Sugiyama et al. (1981): "Methods for Visual Understanding of Hierarchical System Structures"
    ///    - Empirically proven to be the dominant factor in graph readability (Purchase et al., 2002)
    ///    - Weight: 10000x (significant impact on cognitive load)
    ///
    /// 2. **Weighted Edge Length** (Aesthetic)
    ///    - Shorter edges generally preferred (Neumann & Pick, 2004)
    ///    - Edge type weighting based on visual clarity:
    ///      * Vertical edges: 5x (look terrible when kinked)
    ///      * Mixed edges: 1x (smoothstep handles longer runs well)
    ///      * Horizontal edges: 0x (naturally clean in layered layout)
    ///    - Weight: 1x base (aesthetic preference, not critical)
    ///
    /// The weighted scoring ensures the optimizer addresses issues in order of
    /// their impact on graph comprehension, following the hierarchy established
    /// by decades of graph visualization research.
    pub fn calculate_layout_quality(
        &self,
        nodes: &[Node],
        edges: &[Edge],
        _ctx: &TopologyContext,
    ) -> LayoutQuality {
        let total_edge_length = self.calculate_total_edge_length(nodes, edges);
        let edge_crossings = self.count_edge_crossings(nodes, edges);

        LayoutQuality::new(total_edge_length, edge_crossings)
    }

    // ============================================================================
    // Edge Length Calculation
    // ============================================================================

    /// Calculate weighted total edge length based on edge handle types
    ///
    /// Weights edges by their visual importance:
    /// - Vertical edges (both handles vertical): weight = 5
    /// - Mixed edges (one horizontal handle): weight = 1  
    /// - Horizontal edges (both horizontal): weight = 0 (excluded)
    /// - Multi-hop edges: weight = 0 (excluded - frontend optimized)
    pub fn calculate_total_edge_length(&self, nodes: &[Node], edges: &[Edge]) -> f64 {
        let subnet_positions = self.build_subnet_positions_map(nodes);
        let node_map: HashMap<Uuid, &Node> = nodes.iter().map(|n| (n.id, n)).collect();

        let mut total_weighted_length = 0.0;

        for edge in edges {
            if let (Some(src_node), Some(tgt_node)) =
                (node_map.get(&edge.source), node_map.get(&edge.target))
            {
                let source_is_horizontal = edge.source_handle.is_horizontal();
                let target_is_horizontal = edge.target_handle.is_horizontal();

                let weight = if source_is_horizontal && target_is_horizontal {
                    // Fully horizontal edge - don't penalize at all
                    continue;
                } else if edge.is_multi_hop {
                    // Edge optimization happens on frontend - don't penalize
                    continue;
                } else if source_is_horizontal || target_is_horizontal {
                    // Mixed edge - low weight
                    1.0
                } else {
                    // Both handles are vertical - high weight (kinked vertical edges look bad)
                    100.0
                };

                let pos1 = self.get_absolute_node_center(src_node, &subnet_positions);
                let pos2 = self.get_absolute_node_center(tgt_node, &subnet_positions);

                let dx = pos2.x as f64 - pos1.x as f64;
                let dy = pos2.y as f64 - pos1.y as f64;
                let length = (dx * dx + dy * dy).sqrt();

                total_weighted_length += length * weight;
            }
        }

        total_weighted_length
    }

    // ============================================================================
    // Edge Crossing Detection
    // ============================================================================

    /// Count the number of edge crossings in the graph
    ///
    /// ALGORITHM: Geometric Intersection Detection
    ///
    /// Uses line segment intersection testing (O'Rourke, 1998) on inter-subnet edges.
    /// Each pair of intersecting edges counts as one crossing.
    ///
    /// Based on: Sugiyama et al.'s crossing minimization heuristics for layered graphs
    pub fn count_edge_crossings(&self, nodes: &[Node], edges: &[Edge]) -> usize {
        let subnet_positions = self.build_subnet_positions_map(nodes);
        let node_map: HashMap<Uuid, Node> = nodes.iter().map(|n| (n.id, n.clone())).collect();

        let mut crossings = 0;

        for i in 0..edges.len() {
            for j in (i + 1)..edges.len() {
                if self.edges_cross(&edges[i], &edges[j], &node_map, &subnet_positions) {
                    crossings += 1;
                }
            }
        }

        crossings
    }

    /// Check if two edges cross each other
    pub fn edges_cross(
        &self,
        edge1: &Edge,
        edge2: &Edge,
        node_map: &HashMap<Uuid, Node>,
        subnet_positions: &HashMap<Uuid, Ixy>,
    ) -> bool {
        // Edges sharing endpoints cannot cross
        if edge1.source == edge2.source
            || edge1.source == edge2.target
            || edge1.target == edge2.source
            || edge1.target == edge2.target
            || edge1.is_multi_hop
            || edge2.is_multi_hop
        {
            return false;
        }

        let node1_src = node_map.get(&edge1.source);
        let node1_tgt = node_map.get(&edge1.target);
        let node2_src = node_map.get(&edge2.source);
        let node2_tgt = node_map.get(&edge2.target);

        if node1_src.is_none() || node1_tgt.is_none() || node2_src.is_none() || node2_tgt.is_none()
        {
            return false;
        }

        match (node1_src, node1_tgt, node2_src, node2_tgt) {
            (Some(node1_src), Some(node1_tgt), Some(node2_src), Some(node2_tgt)) => {
                let pos1 = self.get_absolute_node_center(node1_src, subnet_positions);
                let pos2 = self.get_absolute_node_center(node1_tgt, subnet_positions);
                let pos3 = self.get_absolute_node_center(node2_src, subnet_positions);
                let pos4 = self.get_absolute_node_center(node2_tgt, subnet_positions);

                self.segments_intersect(pos1, pos2, pos3, pos4)
            }
            _ => false,
        }
    }

    // ============================================================================
    // Geometric Utilities
    // ============================================================================

    pub fn rectangles_overlap(&self, p1: Ixy, d1: Uxy, p2: Ixy, d2: Uxy) -> bool {
        let w1 = d1.x as isize;
        let h1 = d1.y as isize;
        let w2 = d2.x as isize;
        let h2 = d2.y as isize;

        // Rectangles don't overlap if one is completely to the left/right/above/below the other
        !(p1.x + w1 <= p2.x || p2.x + w2 <= p1.x || p1.y + h1 <= p2.y || p2.y + h2 <= p1.y)
    }
    /// Test if two line segments intersect
    fn segments_intersect(&self, p1: Ixy, p2: Ixy, p3: Ixy, p4: Ixy) -> bool {
        let x1 = p1.x as f64;
        let y1 = p1.y as f64;
        let x2 = p2.x as f64;
        let y2 = p2.y as f64;
        let x3 = p3.x as f64;
        let y3 = p3.y as f64;
        let x4 = p4.x as f64;
        let y4 = p4.y as f64;

        let d1 = self.direction(x3, y3, x4, y4, x1, y1);
        let d2 = self.direction(x3, y3, x4, y4, x2, y2);
        let d3 = self.direction(x1, y1, x2, y2, x3, y3);
        let d4 = self.direction(x1, y1, x2, y2, x4, y4);

        if ((d1 > 0.0 && d2 < 0.0) || (d1 < 0.0 && d2 > 0.0))
            && ((d3 > 0.0 && d4 < 0.0) || (d3 < 0.0 && d4 > 0.0))
        {
            return true;
        }

        if d1.abs() < f64::EPSILON && self.on_segment(x3, y3, x4, y4, x1, y1) {
            return true;
        }
        if d2.abs() < f64::EPSILON && self.on_segment(x3, y3, x4, y4, x2, y2) {
            return true;
        }
        if d3.abs() < f64::EPSILON && self.on_segment(x1, y1, x2, y2, x3, y3) {
            return true;
        }
        if d4.abs() < f64::EPSILON && self.on_segment(x1, y1, x2, y2, x4, y4) {
            return true;
        }

        false
    }

    fn direction(&self, x1: f64, y1: f64, x2: f64, y2: f64, x3: f64, y3: f64) -> f64 {
        (x3 - x1) * (y2 - y1) - (y3 - y1) * (x2 - x1)
    }

    fn on_segment(&self, x1: f64, y1: f64, x2: f64, y2: f64, x: f64, y: f64) -> bool {
        x <= x1.max(x2) && x >= x1.min(x2) && y <= y1.max(y2) && y >= y1.min(y2)
    }

    // ============================================================================
    // Position and Coordinate Utilities
    // ============================================================================

    /// Build a map of subnet positions for quick lookups
    fn build_subnet_positions_map(&self, nodes: &[Node]) -> HashMap<Uuid, Ixy> {
        nodes
            .iter()
            .filter_map(|n| match n.node_type {
                NodeType::SubnetNode { .. } => Some((n.id, n.position)),
                _ => None,
            })
            .collect()
    }

    /// Get absolute center point of a node (including subnet offset for InterfaceNodes)
    pub fn get_absolute_node_center(
        &self,
        node: &Node,
        subnet_positions: &HashMap<Uuid, Ixy>,
    ) -> Ixy {
        let mut abs_pos = Ixy {
            x: node.position.x + (node.size.x as isize / 2),
            y: node.position.y + (node.size.y as isize / 2),
        };

        if let NodeType::InterfaceNode { subnet_id, .. } = node.node_type
            && let Some(subnet_pos) = subnet_positions.get(&subnet_id)
        {
            abs_pos.x += subnet_pos.x;
            abs_pos.y += subnet_pos.y;
        }

        abs_pos
    }

    // ============================================================================
    // Statistical Utilities
    // ============================================================================

    pub fn calculate_median(&self, values: &mut [f64]) -> f64 {
        values.sort_by(|a, b| a.total_cmp(b));
        if values.len().is_multiple_of(2) {
            let mid = values.len() / 2;
            (values[mid - 1] + values[mid]) / 2.0
        } else {
            values[values.len() / 2]
        }
    }

    /// Calculate weighted median using the linear interpolation method
    ///
    /// This is the standard weighted median algorithm:
    /// 1. Sort (value, weight) pairs by value
    /// 2. Calculate cumulative weights
    /// 3. Find the value where cumulative weight reaches 50% of total weight
    pub fn calculate_weighted_median(&self, weighted_values: &mut [(f64, f64)]) -> f64 {
        if weighted_values.is_empty() {
            return 0.0;
        }

        // Sort by position (value)
        weighted_values.sort_by(|a, b| a.0.total_cmp(&b.0));

        // Calculate total weight
        let total_weight: f64 = weighted_values.iter().map(|(_, w)| w).sum();

        if total_weight == 0.0 {
            // If all weights are zero, fall back to unweighted median
            let values: Vec<f64> = weighted_values.iter().map(|(v, _)| *v).collect();
            return if values.len().is_multiple_of(2) {
                (values[values.len() / 2 - 1] + values[values.len() / 2]) / 2.0
            } else {
                values[values.len() / 2]
            };
        }

        let half_weight = total_weight / 2.0;

        // Find the value where cumulative weight reaches 50%
        let mut cumulative_weight = 0.0;
        for (value, weight) in weighted_values.iter() {
            cumulative_weight += weight;
            if cumulative_weight >= half_weight {
                return *value;
            }
        }

        // Should never reach here, but return last value as fallback
        weighted_values.last().map(|(v, _)| *v).unwrap_or(0.0)
    }

    // ============================================================================
    // Node Manipulation Utilities
    // ============================================================================

    pub fn swap_node_positions(&self, nodes: &mut [Node], node_id_1: Uuid, node_id_2: Uuid) {
        let mut pos1: Option<Ixy> = None;
        let mut pos2: Option<Ixy> = None;

        for node in nodes.iter() {
            if node.id == node_id_1 {
                pos1 = Some(node.position);
            } else if node.id == node_id_2 {
                pos2 = Some(node.position);
            }
        }

        if let (Some(p1), Some(p2)) = (pos1, pos2) {
            for node in nodes.iter_mut() {
                if node.id == node_id_1 {
                    node.position = p2;
                } else if node.id == node_id_2 {
                    node.position = p1;
                }
            }
        }
    }
}
