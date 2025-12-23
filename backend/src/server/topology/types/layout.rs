use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::server::{
    bindings::r#impl::base::Binding, services::r#impl::base::Service,
    topology::service::planner::utils::NODE_PADDING,
};

const SUBNET_CHILD_HEADER_HEIGHT: usize = 25;
const SUBNET_CHILD_FOOTER_HEIGHT: usize = 25;
const HEIGHT_PER_SERVICE_IN_SUBNET_CHILD: usize = 50;
const SUBNET_CHILD_WIDTH: usize = 250;

#[derive(Serialize, Deserialize, Debug, Clone, Copy, Default, PartialEq, Eq, Hash)]
pub struct Uxy {
    pub x: usize,
    pub y: usize,
}

impl Uxy {
    pub fn default_subnet_child_size() -> Self {
        Self {
            x: SUBNET_CHILD_WIDTH,
            y: HEIGHT_PER_SERVICE_IN_SUBNET_CHILD + SUBNET_CHILD_FOOTER_HEIGHT,
        }
    }

    pub fn subnet_child_size_from_service_count(
        services: &[&Service],
        interface_id: Uuid,
        has_header: bool,
        hide_ports: bool,
    ) -> Self {
        let service_area_height: usize = services
            .iter()
            .map(|s| {
                let bindings_with_ports = s
                    .base
                    .bindings
                    .iter()
                    .filter(|b| {
                        b.interface_id().map(|i| i == interface_id).unwrap_or(true)
                            && b.port_id().is_some()
                    })
                    .collect::<Vec<&Binding>>()
                    .len();
                HEIGHT_PER_SERVICE_IN_SUBNET_CHILD
                    + if hide_ports && bindings_with_ports > 0 {
                        0
                    } else {
                        25
                    }
            })
            .sum();

        Self {
            x: SUBNET_CHILD_WIDTH,
            y: service_area_height
                + SUBNET_CHILD_FOOTER_HEIGHT
                + if has_header {
                    SUBNET_CHILD_HEADER_HEIGHT
                } else {
                    0
                },
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, Copy, Default, PartialEq, Eq, Hash)]
pub struct Ixy {
    pub x: isize,
    pub y: isize,
}

// CHANGED: NodeLayout now stores actual position instead of grid position
#[derive(Debug, Copy, Clone)]
pub struct NodeLayout {
    pub size: Uxy,
    pub position: Ixy, // Changed from grid_position: Uxy
}

#[derive(Debug, Copy, Clone)]
pub struct SubnetLayout {
    pub size: Uxy,
    pub infra_width: usize,
}

// Helper struct for tracking node bounds
#[derive(Debug, Copy, Clone)]
pub struct NodeBounds {
    pub x: isize,
    pub y: isize,
    pub width: usize,
    pub height: usize,
}

impl NodeBounds {
    pub fn new(position: Ixy, size: Uxy) -> Self {
        Self {
            x: position.x,
            y: position.y,
            width: size.x,
            height: size.y,
        }
    }

    pub fn right(&self) -> isize {
        self.x + self.width as isize
    }

    pub fn bottom(&self) -> isize {
        self.y + self.height as isize
    }

    /// Check if this node overlaps with another node
    pub fn overlaps(&self, other: &NodeBounds) -> bool {
        // Consider nodes overlapping if they're within padding distance
        !(self.right() + NODE_PADDING.x as isize <= other.x
            || self.x >= other.right() + NODE_PADDING.x as isize
            || self.bottom() + NODE_PADDING.y as isize <= other.y
            || self.y >= other.bottom() + NODE_PADDING.y as isize)
    }

    /// Calculate the minimum shift needed to resolve overlap with another node
    /// Returns (dx, dy) to move this node to avoid overlap
    pub fn resolve_overlap(&self, other: &NodeBounds) -> (isize, isize) {
        if !self.overlaps(other) {
            return (0, 0);
        }

        // Calculate raw overlap amounts (without padding)
        let overlap_left = other.right() - self.x;
        let overlap_right = self.right() - other.x;
        let overlap_top = other.bottom() - self.y;
        let overlap_bottom = self.bottom() - other.y;

        // Find the minimum overlap direction
        let min_horizontal = overlap_left.min(overlap_right);
        let min_vertical = overlap_top.min(overlap_bottom);

        if min_horizontal < min_vertical {
            // Move horizontally
            if overlap_left < overlap_right {
                // Move left: add padding to separation
                (-(overlap_left + NODE_PADDING.x as isize), 0)
            } else {
                // Move right: add padding to separation
                (overlap_right + NODE_PADDING.x as isize, 0)
            }
        } else {
            // Move vertically
            if overlap_top < overlap_bottom {
                // Move up: add padding to separation
                (0, -(overlap_top + NODE_PADDING.y as isize))
            } else {
                // Move down: add padding to separation
                (0, overlap_bottom + NODE_PADDING.y as isize)
            }
        }
    }
}
