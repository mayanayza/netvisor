use crate::server::topology::{
    service::{
        context::TopologyContext,
        optimizer::{child_positioner::ChildPositioner, subnet_positioner::SubnetPositioner},
    },
    types::{edges::Edge, nodes::Node},
};

/// High-level optimizer that coordinates crossing reduction and subnet positioning
/// Implements an iterative optimization approach that continues until convergence
pub struct TopologyOptimizer<'a> {
    subnet_positioner: SubnetPositioner<'a>,
    child_positioner: ChildPositioner<'a>,
    context: &'a TopologyContext<'a>,
}

impl<'a> TopologyOptimizer<'a> {
    pub fn new(ctx: &'a TopologyContext<'a>) -> Self {
        Self {
            subnet_positioner: SubnetPositioner::new(ctx),
            child_positioner: ChildPositioner::new(ctx),
            context: ctx,
        }
    }

    /// Main entry point: optimize node positions and fix edge handles
    ///
    /// ALGORITHM: Multi-pass iterative optimization with global convergence
    ///
    /// This implements a hybrid approach combining:
    /// 1. Sugiyama framework concepts (layered graph drawing)
    /// 2. Force-directed principles (iterative refinement)
    /// 3. Barycenter heuristic (median-based positioning)
    ///
    /// The algorithm runs multiple complete optimization passes, where each pass consists of:
    /// - Topological ordering (Step 1)
    /// - Subnet positioning via barycenter/median (Step 2)
    /// - Child node positioning via layer sweeps (Step 3)
    ///
    /// Convergence is detected when:
    /// - Quality improvement falls below threshold (< 0.1% improvement)
    /// - Maximum iterations reached (20 passes to prevent infinite loops)
    pub fn optimize_graph(&self, nodes: &mut [Node], edges: &[Edge]) -> Vec<Edge> {
        const MAX_GLOBAL_ITERATIONS: usize = 20;
        const CONVERGENCE_THRESHOLD: f64 = 0.1; // 0.1% improvement threshold

        let mut prev_quality = self.context.calculate_layout_quality(nodes, edges);
        let mut iterations = 0;

        // tracing::debug!(
        //     "Starting topology optimization - Initial quality: crossings={}, length={:.2}",
        //     prev_quality.edge_crossings,
        //     prev_quality.total_edge_length
        // );

        loop {
            iterations += 1;

            // Step 1: Optimize subnet positions using barycenter/median heuristic
            // Aligns subnets to minimize inter-subnet edge lengths
            self.subnet_positioner.optimize_positions(nodes, edges);

            // Step 2: Optimize child node positions using layer sweeps
            // Fine-tunes positions within subnets to reduce crossings and edge length
            self.child_positioner.optimize_positions(nodes, edges);

            // Calculate quality after this complete pass
            let current_quality = self.context.calculate_layout_quality(nodes, edges);

            let improvement_pct = current_quality.improvement_percentage(&prev_quality);

            // tracing::debug!(
            //     "Iteration {} complete - crossings={}, length={:.2}, improvement={:.2}%",
            //     iterations,
            //     current_quality.edge_crossings,
            //     current_quality.total_edge_length,
            //     improvement_pct
            // );

            // Check convergence conditions
            if improvement_pct.abs() < CONVERGENCE_THRESHOLD {
                // tracing::debug!(
                //     "Converged after {} iterations (improvement < {}%)",
                //     iterations,
                //     CONVERGENCE_THRESHOLD
                // );
                break;
            }

            if iterations >= MAX_GLOBAL_ITERATIONS {
                // tracing::debug!(
                //     "Stopped after {} iterations (max limit reached)",
                //     MAX_GLOBAL_ITERATIONS
                // );
                break;
            }

            // No improvement means we're stuck in local minimum
            if !current_quality.is_better_than(&prev_quality) {
                // tracing::debug!(
                //     "Stopped after {} iterations (no improvement)",
                //     iterations
                // );
                break;
            }

            prev_quality = current_quality;
        }

        // let final_quality = self.context.calculate_layout_quality(nodes, edges);
        // tracing::debug!(
        //     "Optimization complete - Final quality: crossings={}, length={:.2}",
        //     final_quality.edge_crossings,
        //     final_quality.total_edge_length
        // );

        // Step 4: Minimize vertical spacing between ndoes
        self.child_positioner.compress_vertical_spacing(nodes);

        // Step 5: Fix intra-subnet edge handles based on final positions
        self.child_positioner.fix_intra_subnet_handles(edges, nodes)

        //     // Step 5: NEW - Optimize anchor positions to minimize crossings
        //     // This is a post-processing step that runs AFTER node layout is finalized
        //     tracing::info!("Starting anchor position optimization");
        //     self.anchor_optimizer
        //         .analyze_anchor_quality(&optimized_edges, nodes);
        //     self.anchor_optimizer
        //         .optimize_anchors(&mut optimized_edges, nodes);
    }
}
