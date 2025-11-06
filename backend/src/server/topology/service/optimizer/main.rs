// In optimizer/main.rs

use crate::server::topology::{
    service::{
        context::TopologyContext,
        optimizer::{
            child_positioner::ChildPositioner, subnet_positioner::SubnetPositioner,
            utils::OptimizerUtils,
        },
    },
    types::{edges::Edge, nodes::Node},
};

pub struct TopologyOptimizer<'a> {
    subnet_positioner: SubnetPositioner<'a>,
    child_positioner: ChildPositioner<'a>,
    // anchor_optimizer: AnchorOptimizer<'a>,
    context: &'a TopologyContext<'a>,
    utils: OptimizerUtils,
}

impl<'a> TopologyOptimizer<'a> {
    pub fn new(ctx: &'a TopologyContext<'a>) -> Self {
        Self {
            subnet_positioner: SubnetPositioner::new(ctx),
            child_positioner: ChildPositioner::new(ctx),
            // anchor_optimizer: AnchorOptimizer::new(ctx),
            context: ctx,
            utils: OptimizerUtils::new(),
        }
    }

    pub fn optimize_graph(&self, nodes: &mut [Node], edges: &[Edge]) -> Vec<Edge> {
        const MAX_GLOBAL_ITERATIONS: usize = 20;
        const CONVERGENCE_THRESHOLD: f64 = 0.1;

        let mut optimized_edges = edges.to_vec();
        let mut prev_quality =
            self.utils
                .calculate_layout_quality(nodes, &optimized_edges, self.context);
        let mut iterations = 0;

        loop {
            iterations += 1;

            // Step 1: Optimize subnet positions
            self.subnet_positioner
                .optimize_positions(nodes, &optimized_edges);

            // Calculate quality after this complete pass
            let current_quality =
                self.utils
                    .calculate_layout_quality(nodes, &optimized_edges, self.context);

            let improvement_pct = current_quality.improvement_percentage(&prev_quality);

            // Check convergence conditions
            if !current_quality.is_better_than(&prev_quality) {
                break;
            }

            // Check 2: Quality improved, but improvement is tiny? Converged
            if improvement_pct > 0.0 && improvement_pct < CONVERGENCE_THRESHOLD {
                break;
            }

            if iterations >= MAX_GLOBAL_ITERATIONS {
                break;
            }

            prev_quality = current_quality;
        }

        self.child_positioner.compress_vertical_spacing(nodes);

        optimized_edges = self
            .child_positioner
            .fix_intra_subnet_handles(&optimized_edges, nodes);

        optimized_edges
    }
}
