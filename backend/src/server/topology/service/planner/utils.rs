use std::collections::HashMap;
use uuid::Uuid;

use crate::server::topology::types::layout::{Ixy, NodeLayout, Uxy};

pub const SUBNET_PADDING: Uxy = Uxy { x: 125, y: 125 };
pub const NODE_PADDING: Uxy = Uxy { x: 50, y: 50 };
pub struct PlannerUtils;

impl PlannerUtils {
    /// Calculate container size from positioned nodes
    pub fn calculate_container_size_from_layouts(
        layouts: &HashMap<Uuid, NodeLayout>,
        padding: &Uxy,
    ) -> Uxy {
        if layouts.is_empty() {
            return Uxy {
                x: padding.x * 2,
                y: padding.y * 2,
            };
        }

        let mut max_x = 0;
        let mut max_y = 0;

        for layout in layouts.values() {
            let right_edge =
                (layout.position.x + layout.size.x as isize + padding.x as isize) as usize;
            let bottom_edge =
                (layout.position.y + layout.size.y as isize + padding.y as isize) as usize;

            max_x = max_x.max(right_edge);
            max_y = max_y.max(bottom_edge);
        }

        Uxy { x: max_x, y: max_y }
    }

    /// Row based container size calculator for subnet positioning
    /// Calculate the size of a container and positions of arbitrarily-sized children in that container
    pub fn calculate_container_size(
        rows: Vec<Vec<(Uuid, NodeLayout)>>,
        padding: &Uxy,
    ) -> (HashMap<Uuid, Ixy>, Uxy) {
        let mut child_positions = HashMap::new();

        let mut current_y = padding.y;
        let mut max_x = 0;
        let mut max_y = 0;

        for row in rows {
            if row.is_empty() {
                continue;
            }

            let mut current_x = padding.x;
            let mut max_height_in_row = 0;

            for (id, layout) in row {
                // For backward compatibility with subnet positioning,
                // use the position from layout if it's already set, otherwise calculate
                let position = Ixy {
                    x: current_x as isize,
                    y: current_y as isize,
                };

                child_positions.insert(id, position);
                current_x += layout.size.x + padding.x;
                max_height_in_row = max_height_in_row.max(layout.size.y);
            }

            current_y += max_height_in_row + padding.y;
            max_x = max_x.max(current_x);
            max_y = max_y.max(current_y);
        }

        let container_size = Uxy { x: max_x, y: max_y };

        (child_positions, container_size)
    }
}
