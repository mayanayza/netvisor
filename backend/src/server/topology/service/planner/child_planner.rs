use std::{cmp::Ordering, collections::HashMap};
use uuid::Uuid;

use crate::server::topology::{
    service::context::TopologyContext,
    types::{
        edges::EdgeType,
        layout::{Ixy, NodeLayout, Uxy},
        nodes::SubnetChild,
    },
};

pub struct ChildNodePlanner;

impl ChildNodePlanner {
    /// Calculate child positions using grid-based layout with continuous coordinates
    /// Places nodes in a grid pattern but uses actual pixel positions for overlap resolution
    pub fn calculate_anchor_based_positions(
        children: &[SubnetChild],
        padding: &Uxy,
        ctx: &TopologyContext,
    ) -> HashMap<Uuid, NodeLayout> {
        if children.is_empty() {
            return HashMap::new();
        }

        // Calculate grid dimensions
        let grid_w = ((children.len() as f64).sqrt().ceil() as usize).max(1);
        let grid_h = ((children.len() as f64 / grid_w as f64).ceil() as usize).max(1);

        // Get the current subnet's topology position
        let current_subnet_id = children.first().and_then(|c| {
            c.interface_id
                .and_then(|iid| ctx.get_interface_by_id(Some(iid)).map(|i| i.base.subnet_id))
        });

        let current_subnet = current_subnet_id.and_then(|id| ctx.get_subnet_by_id(id));

        let (current_vertical, current_horizontal) = current_subnet
            .map(|s| {
                (
                    s.base.subnet_type.vertical_order(),
                    s.base.subnet_type.horizontal_order(),
                )
            })
            .unwrap_or((999, 999));

        // Build VM provider -> VMs mapping by looking at ALL edges
        let mut vm_clusters: HashMap<Uuid, Vec<Uuid>> = HashMap::new();
        let mut vm_to_provider: HashMap<Uuid, Uuid> = HashMap::new();

        // Collect all VM edges from all children
        for child in children {
            for edge in &child.edges {
                if matches!(edge.edge_type, EdgeType::HostVirtualization { .. }) {
                    let provider_iid = edge.source;
                    let vm_iid = edge.target;

                    // Map VMs to their provider
                    vm_to_provider.insert(vm_iid, provider_iid);

                    // Add to cluster if not already present
                    let cluster = vm_clusters.entry(provider_iid).or_default();
                    if !cluster.contains(&vm_iid) {
                        cluster.push(vm_iid);
                    }
                }
            }
        }

        // Analyze each VM cluster for cross-infra splitting
        let mut cluster_crosses_infra: HashMap<Uuid, bool> = HashMap::new();
        for (provider_iid, vm_iids) in vm_clusters.iter() {
            let provider_is_infra = ctx.is_interface_infra(*provider_iid);

            // Check if any VM is on opposite side of infra boundary
            let mut has_cross_infra = false;
            for vm_iid in vm_iids.iter() {
                let vm_is_infra = ctx.is_interface_infra(*vm_iid);
                if vm_is_infra != provider_is_infra {
                    has_cross_infra = true;
                }
            }

            if has_cross_infra {
                cluster_crosses_infra.insert(*provider_iid, true);
            }
        }

        // Calculate "ideal position" for each VM cluster based on ALL cluster members' inter-subnet edges
        // This includes both the provider AND all VMs - whichever has external connections
        let mut cluster_target_positions: HashMap<Uuid, Ixy> = HashMap::new();
        for (provider_iid, vm_iids) in vm_clusters.iter() {
            // Collect all interface IDs in this cluster (provider + VMs)
            let mut cluster_interface_ids = vec![*provider_iid];
            cluster_interface_ids.extend(vm_iids.iter());

            // Calculate combined force from ALL cluster members' inter-subnet edges
            let mut total_force = Ixy::default();
            let mut edge_count = 0;

            for interface_id in cluster_interface_ids.iter() {
                if let Some(child) = children
                    .iter()
                    .find(|c| c.interface_id == Some(*interface_id))
                {
                    for e in &child.edges {
                        if !ctx.edge_is_intra_subnet(e)
                            && !matches!(e.edge_type, EdgeType::HostVirtualization { .. })
                        {
                            // Get the other interface this edge connects to
                            let other_interface_id = if child.interface_id == Some(e.source) {
                                e.target
                            } else if child.interface_id == Some(e.target) {
                                e.source
                            } else {
                                continue;
                            };

                            // Calculate force based on relative subnet positions
                            let other_subnet = ctx
                                .get_interface_by_id(Some(other_interface_id))
                                .and_then(|i| ctx.get_subnet_by_id(i.base.subnet_id));

                            if let Some(other_subnet) = other_subnet {
                                let other_vertical = other_subnet.base.subnet_type.vertical_order();
                                let other_horizontal =
                                    other_subnet.base.subnet_type.horizontal_order();

                                // Force is based on relative subnet topology
                                let vertical_force =
                                    (current_vertical as isize) - (other_vertical as isize);
                                let horizontal_force =
                                    (other_horizontal as isize) - (current_horizontal as isize);

                                total_force.x += horizontal_force;
                                total_force.y += vertical_force;
                                edge_count += 1;
                            }
                        }
                    }
                }
            }

            // Average the forces if we have multiple edges
            if edge_count > 0 {
                total_force.x = (total_force.x as f32 / edge_count as f32) as isize;
                total_force.y = (total_force.y as f32 / edge_count as f32) as isize;
            }

            // CRITICAL: If cluster crosses infra boundary, adjust horizontal force
            // We don't want to pull the cluster apart - instead pull both sides toward boundary
            let cluster_crosses_boundary = cluster_crosses_infra
                .get(provider_iid)
                .copied()
                .unwrap_or(false);
            if cluster_crosses_boundary {
                // Neutralize any horizontal force that would split the cluster
                // Instead, we'll apply boundary-specific forces to each side separately
                total_force.x = 0;
            }

            cluster_target_positions.insert(*provider_iid, total_force);
        }

        // Create force directed map based on subnet topology, VM clustering, AND infra boundaries
        let force_directed_children: Vec<(&SubnetChild, Ixy)> = children
            .iter()
            .map(|c| {
                let mut force_direction = Ixy::default();

                // Check if this child is part of a VM cluster
                let vm_provider_id = c
                    .interface_id
                    .and_then(|id| vm_to_provider.get(&id).copied());

                // FIRST: Calculate inter-subnet edge forces and track which axes they control
                let mut inter_subnet_force = Ixy::default();
                let mut has_horizontal_inter_edge = false;
                let mut has_vertical_inter_edge = false;

                for e in &c.edges {
                    let is_intra_subnet = ctx.edge_is_intra_subnet(e);
                    let is_vm_edge = matches!(e.edge_type, EdgeType::HostVirtualization { .. });

                    // Skip VM edges and intra-subnet edges
                    if is_vm_edge || is_intra_subnet {
                        continue;
                    }

                    // Get the other interface this edge connects to
                    let other_interface_id = if c.interface_id == Some(e.source) {
                        e.target
                    } else if c.interface_id == Some(e.target) {
                        e.source
                    } else {
                        continue;
                    };

                    // Determine the handle direction for this node
                    let handle = if c.interface_id == Some(e.source) {
                        &e.source_handle
                    } else {
                        &e.target_handle
                    };

                    // Inter-subnet edge - STRONG force based on subnet topology
                    let other_subnet = ctx
                        .get_interface_by_id(Some(other_interface_id))
                        .and_then(|i| ctx.get_subnet_by_id(i.base.subnet_id));

                    if let Some(other_subnet) = other_subnet {
                        let other_vertical = other_subnet.base.subnet_type.vertical_order();
                        let other_horizontal = other_subnet.base.subnet_type.horizontal_order();

                        // Calculate force based on relative subnet positions
                        let vertical_force =
                            (current_vertical as isize) - (other_vertical as isize);
                        let horizontal_force =
                            (other_horizontal as isize) - (current_horizontal as isize);

                        // Inter-subnet edges get DOMINANT weight
                        let weight = 1000.0;

                        // Only apply force in the direction of the handle
                        if handle.is_horizontal() {
                            // Left/Right handles control horizontal positioning
                            inter_subnet_force.x += (horizontal_force as f32 * weight) as isize;
                            has_horizontal_inter_edge = true;
                        } else {
                            // Top/Bottom handles control vertical positioning
                            inter_subnet_force.y += (vertical_force as f32 * weight) as isize;
                            has_vertical_inter_edge = true;
                        }
                    }
                }

                // Start with inter-subnet forces for axes they control
                if has_horizontal_inter_edge || has_vertical_inter_edge {
                    force_direction = inter_subnet_force;
                }

                // For axes NOT controlled by inter-subnet edges, apply VM clustering
                if let Some(provider_id) = vm_provider_id {
                    // This is a VM - use cluster positioning for axes not controlled by inter-subnet edges
                    if let Some(cluster_pos) = cluster_target_positions.get(&provider_id) {
                        // Base cluster force
                        let cluster_weight = 500.0; // Medium-strong weight

                        let cluster_x = if !has_horizontal_inter_edge {
                            cluster_pos.x * cluster_weight as isize
                        } else {
                            0
                        };
                        let cluster_y = if !has_vertical_inter_edge {
                            cluster_pos.y * cluster_weight as isize
                        } else {
                            0
                        };

                        force_direction.x += cluster_x;
                        force_direction.y += cluster_y;

                        // ADDITIONAL: If cluster crosses infra boundary, pull toward boundary (horizontal only)
                        if !has_horizontal_inter_edge
                            && cluster_crosses_infra
                                .get(&provider_id)
                                .copied()
                                .unwrap_or(false)
                        {
                            let vm_is_infra = c
                                .interface_id
                                .map(|iid| ctx.is_interface_infra(iid))
                                .unwrap_or(false);

                            // STRONG boundary force to keep split clusters together
                            let boundary_weight = 800.0; // Very strong - almost as strong as inter-subnet edges
                            let boundary_force = if vm_is_infra {
                                1.0 // Infra VMs get pulled right (toward boundary)
                            } else {
                                -1.0 // Non-infra VMs get pulled left (toward boundary)
                            };

                            let boundary_x = (boundary_force * boundary_weight) as isize;
                            force_direction.x += boundary_x;
                        }
                    }
                } else if !has_horizontal_inter_edge || !has_vertical_inter_edge {
                    // Check if this is a VM provider (has outgoing VM edges)
                    let is_vm_provider = c.edges.iter().any(|e| {
                        matches!(e.edge_type, EdgeType::HostVirtualization { .. })
                            && c.interface_id == Some(e.source)
                    });

                    if is_vm_provider {
                        // VM provider - position based on cluster
                        if let Some(cluster_pos) =
                            cluster_target_positions.get(&c.interface_id.unwrap())
                        {
                            let cluster_weight = 500.0;

                            if !has_horizontal_inter_edge {
                                force_direction.x += cluster_pos.x * cluster_weight as isize;
                            }
                            if !has_vertical_inter_edge {
                                force_direction.y += cluster_pos.y * cluster_weight as isize;
                            }

                            // If cluster crosses infra boundary, provider should stay near boundary center
                            if !has_horizontal_inter_edge
                                && cluster_crosses_infra
                                    .get(&c.interface_id.unwrap())
                                    .copied()
                                    .unwrap_or(false)
                            {
                                // Neutralize horizontal cluster force and apply boundary positioning force
                                // Position provider at/near the infra boundary (between infra and non-infra sides)
                                force_direction.x = 0; // Reset cluster force

                                let provider_is_infra = c
                                    .interface_id
                                    .map(|iid| ctx.is_interface_infra(iid))
                                    .unwrap_or(false);

                                // Medium-strong force to position at boundary
                                // This should be strong enough to position near the VMs but weaker than VM boundary forces
                                let provider_boundary_weight = 500.0;
                                let boundary_force = if provider_is_infra { 1.0 } else { -1.0 };

                                force_direction.x +=
                                    (boundary_force * provider_boundary_weight) as isize;
                            }
                        }
                    } else {
                        // Regular node - calculate remaining forces for uncontrolled axes
                        let remaining_force = c.edges.iter().fold(Ixy::default(), |mut acc, e| {
                            let is_intra_subnet = ctx.edge_is_intra_subnet(e);
                            let is_vm_edge =
                                matches!(e.edge_type, EdgeType::HostVirtualization { .. });

                            // Skip VM edges
                            if is_vm_edge {
                                return acc;
                            }

                            // Get the other interface this edge connects to
                            let other_interface_id = if c.interface_id == Some(e.source) {
                                e.target
                            } else if c.interface_id == Some(e.target) {
                                e.source
                            } else {
                                return acc;
                            };

                            // Check if this edge crosses the infra/non-infra boundary
                            let crosses_infra_boundary = if is_intra_subnet {
                                let this_is_infra = c
                                    .interface_id
                                    .map(|iid| ctx.is_interface_infra(iid))
                                    .unwrap_or(false);
                                let other_is_infra = ctx.is_interface_infra(other_interface_id);
                                this_is_infra != other_is_infra
                            } else {
                                false
                            };

                            if crosses_infra_boundary && !has_horizontal_inter_edge {
                                // Edges crossing infra boundary get medium-high weight
                                // and pull toward the boundary (horizontal force only)
                                let this_is_infra = c
                                    .interface_id
                                    .map(|iid| ctx.is_interface_infra(iid))
                                    .unwrap_or(false);
                                let weight = 50.0;

                                // Infra nodes get pulled right (toward boundary)
                                // Non-infra nodes get pulled left (toward boundary)
                                let boundary_force = if this_is_infra { 1.0 } else { -1.0 };
                                acc.x += (boundary_force * weight) as isize;
                            } else if !is_intra_subnet {
                                // Inter-subnet edge forces for axes not already controlled
                                let other_subnet = ctx
                                    .get_interface_by_id(Some(other_interface_id))
                                    .and_then(|i| ctx.get_subnet_by_id(i.base.subnet_id));

                                if let Some(other_subnet) = other_subnet {
                                    let other_vertical =
                                        other_subnet.base.subnet_type.vertical_order();
                                    let other_horizontal =
                                        other_subnet.base.subnet_type.horizontal_order();

                                    let vertical_force =
                                        (current_vertical as isize) - (other_vertical as isize);
                                    let horizontal_force =
                                        (other_horizontal as isize) - (current_horizontal as isize);

                                    let weight = 1000.0;

                                    if !has_horizontal_inter_edge {
                                        acc.x += (horizontal_force as f32 * weight) as isize;
                                    }
                                    if !has_vertical_inter_edge {
                                        acc.y += (vertical_force as f32 * weight) as isize;
                                    }
                                }
                            }

                            acc
                        });

                        // Add remaining forces to what we already have from inter-subnet edges
                        force_direction.x += remaining_force.x;
                        force_direction.y += remaining_force.y;
                    }
                }

                (c, force_direction)
            })
            .collect();

        // Find force extremes
        let (min_x, max_x) = force_directed_children
            .iter()
            .map(|(_, f)| f.x)
            .fold((f32::INFINITY, f32::NEG_INFINITY), |(min, max), x| {
                (min.min(x as f32), max.max(x as f32))
            });
        let (min_y, max_y) = force_directed_children
            .iter()
            .map(|(_, f)| f.y)
            .fold((f32::INFINITY, f32::NEG_INFINITY), |(min, max), y| {
                (min.min(y as f32), max.max(y as f32))
            });

        // Normalize to [0,1] space
        let normalize = |v: isize, min: f32, max: f32| {
            if (max - min).abs() < f32::EPSILON {
                0.5
            } else {
                (v as f32 - min) / (max - min)
            }
        };

        // Sort children for placement priority:
        // 1. VM providers FIRST (they need specific grid positions to center with their clusters)
        // 2. Then by force magnitude (stronger forces placed before weaker ones)
        let mut sorted = force_directed_children.to_vec();
        sorted.sort_by(|(child_a, force_a), (child_b, force_b)| {
            // Check if nodes are VM providers
            let a_is_provider = child_a.edges.iter().any(|e| {
                matches!(e.edge_type, EdgeType::HostVirtualization { .. })
                    && child_a.interface_id == Some(e.source)
            });
            let b_is_provider = child_b.edges.iter().any(|e| {
                matches!(e.edge_type, EdgeType::HostVirtualization { .. })
                    && child_b.interface_id == Some(e.source)
            });

            // VM providers always come first
            if a_is_provider && !b_is_provider {
                return Ordering::Less;
            }
            if !a_is_provider && b_is_provider {
                return Ordering::Greater;
            }

            // For non-providers or when both are providers, sort by force magnitude
            force_b
                .x
                .abs()
                .max(force_b.y.abs())
                .partial_cmp(&force_a.x.abs().max(force_a.y.abs()))
                .unwrap_or(Ordering::Equal)
        });

        // Create a grid to track which cells are occupied
        let mut grid: Vec<Vec<Option<SubnetChild>>> = vec![vec![None; grid_w]; grid_h];

        // Place nodes in grid cells based on force direction
        for (child, force) in &sorted {
            let norm_x = normalize(force.x, min_x, max_x);
            let norm_y = normalize(force.y, min_y, max_y);

            // Map to grid coordinates
            let ideal_gx = (norm_x * (grid_w as f32 - 1.0)).round() as isize;
            let ideal_gy = ((1.0 - norm_y) * (grid_h as f32 - 1.0)).round() as isize;

            let ideal_gx = ideal_gx.clamp(0, (grid_w - 1) as isize) as usize;
            let ideal_gy = ideal_gy.clamp(0, (grid_h - 1) as isize) as usize;

            // Find nearest available grid cell
            let mut found_slot = None;
            let mut radius = 0;
            while found_slot.is_none() && radius < grid_w.max(grid_h) {
                for dy in -(radius as isize)..=(radius as isize) {
                    for dx in -(radius as isize)..=(radius as isize) {
                        let gx = (ideal_gx as isize + dx).clamp(0, (grid_w - 1) as isize) as usize;
                        let gy = (ideal_gy as isize + dy).clamp(0, (grid_h - 1) as isize) as usize;

                        if grid[gy][gx].is_none() {
                            found_slot = Some((gx, gy));
                            break;
                        }
                    }
                    if found_slot.is_some() {
                        break;
                    }
                }
                radius += 1;
            }

            if let Some((gx, gy)) = found_slot {
                grid[gy][gx] = Some((*child).clone());
            }
        }

        // Convert grid positions to actual pixel coordinates
        let mut result: HashMap<Uuid, NodeLayout> = HashMap::new();
        let mut row_heights: Vec<usize> = vec![0; grid_h];
        let mut col_widths: Vec<usize> = vec![0; grid_w];

        // First pass: calculate maximum width/height for each row/column
        for (row_idx, row) in grid.iter().enumerate() {
            for (col_idx, cell) in row.iter().enumerate() {
                if let Some(child) = cell {
                    row_heights[row_idx] = row_heights[row_idx].max(child.size.y);
                    col_widths[col_idx] = col_widths[col_idx].max(child.size.x);
                }
            }
        }

        // Second pass: place nodes using cumulative positions
        let mut current_y = padding.y as isize;
        for (row_idx, row) in grid.iter().enumerate() {
            let mut current_x = padding.x as isize;

            for (col_idx, cell) in row.iter().enumerate() {
                if let Some(child) = cell {
                    result.insert(
                        child.id,
                        NodeLayout {
                            size: child.size,
                            position: Ixy {
                                x: current_x,
                                y: current_y,
                            },
                        },
                    );
                }

                current_x += col_widths[col_idx] as isize + padding.x as isize;
            }

            current_y += row_heights[row_idx] as isize + padding.y as isize;
        }
        result
    }
}
