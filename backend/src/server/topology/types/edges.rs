use crate::server::{
    groups::r#impl::types::GroupTypeDiscriminants,
    shared::{
        concepts::Concept,
        entities::EntityDiscriminants,
        types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider},
    },
    subnets::r#impl::base::Subnet,
    topology::types::layout::Ixy,
};
use serde::{Deserialize, Serialize};
use strum_macros::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};
use utoipa::ToSchema;
use uuid::Uuid;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash)]
pub struct Edge {
    pub id: Uuid,
    pub source: Uuid,
    pub target: Uuid,
    #[serde(flatten)]
    pub edge_type: EdgeType,
    pub label: Option<String>,
    pub source_handle: EdgeHandle,
    pub target_handle: EdgeHandle,
    pub is_multi_hop: bool,
}

#[derive(
    Serialize, Copy, Deserialize, Debug, Clone, Eq, PartialEq, Hash, PartialOrd, Ord, Default,
)]
pub enum EdgeHandle {
    #[default]
    Top,
    Bottom,
    Left,
    Right,
}

#[derive(
    Serialize, Copy, Deserialize, Debug, Clone, Eq, PartialEq, Hash, Default, IntoStaticStr, Display, ToSchema,
)]
pub enum EdgeStyle {
    Straight,
    #[default]
    SmoothStep,
    Step,
    Bezier,
    SimpleBezier,
}

impl EdgeHandle {
    pub fn layout_priority(&self) -> u8 {
        match self {
            EdgeHandle::Top => 0,
            EdgeHandle::Bottom => 1,
            EdgeHandle::Left => 2,
            EdgeHandle::Right => 3,
        }
    }

    pub fn direction(&self) -> Ixy {
        match self {
            EdgeHandle::Top => Ixy { x: 0, y: 1 },
            EdgeHandle::Bottom => Ixy { x: 0, y: -1 },
            EdgeHandle::Left => Ixy { x: -1, y: 0 },
            EdgeHandle::Right => Ixy { x: 1, y: 0 },
        }
    }

    pub fn is_horizontal(&self) -> bool {
        matches!(self, EdgeHandle::Left | EdgeHandle::Right)
    }

    pub fn is_vertical(&self) -> bool {
        matches!(self, EdgeHandle::Top | EdgeHandle::Bottom)
    }

    /// Determine edge handle orientations based on subnet layer and priority
    pub fn from_subnet_layers(
        source_subnet: &Subnet,
        target_subnet: &Subnet,
        source_is_infra: bool,
        target_is_infra: bool,
        is_multi_hop: bool,
    ) -> (EdgeHandle, EdgeHandle) {
        // Special case: edges within the same subnet
        if source_subnet.id == target_subnet.id {
            return Self::from_same_subnet(source_is_infra, target_is_infra);
        }

        let source_vertical_order = source_subnet.base.subnet_type.vertical_order();
        let source_horizontal_order = source_subnet.base.subnet_type.horizontal_order();
        let target_vertical_order = target_subnet.base.subnet_type.vertical_order();
        let target_horizontal_order = target_subnet.base.subnet_type.horizontal_order();

        match source_vertical_order.cmp(&target_vertical_order) {
            // Different layers - vertical flow
            std::cmp::Ordering::Less => {
                if is_multi_hop {
                    // Multi-hop downward: route around the side
                    Self::choose_side_handles_for_multi_hop(source_is_infra, target_is_infra)
                } else {
                    // Single-hop downward: source Bottom -> target Top
                    (EdgeHandle::Bottom, EdgeHandle::Top)
                }
            }
            std::cmp::Ordering::Greater => {
                if is_multi_hop {
                    // Multi-hop upward: route around the side
                    Self::choose_side_handles_for_multi_hop(source_is_infra, target_is_infra)
                } else {
                    // Single-hop upward: source Top -> target Bottom
                    (EdgeHandle::Top, EdgeHandle::Bottom)
                }
            }
            // Same layer - horizontal flow based on priority and infra status
            std::cmp::Ordering::Equal => {
                match source_horizontal_order.cmp(&target_horizontal_order) {
                    // Source has lower priority (leftmost) -> flows right
                    std::cmp::Ordering::Less => {
                        let source_handle = if source_is_infra {
                            EdgeHandle::Bottom
                        } else {
                            EdgeHandle::Right
                        };
                        let target_handle = if target_is_infra {
                            EdgeHandle::Bottom
                        } else {
                            EdgeHandle::Left
                        };
                        (source_handle, target_handle)
                    }
                    // Source has higher priority (rightmost) -> flows left
                    std::cmp::Ordering::Greater => {
                        let source_handle = if source_is_infra {
                            EdgeHandle::Bottom
                        } else {
                            EdgeHandle::Left
                        };
                        let target_handle = if target_is_infra {
                            EdgeHandle::Bottom
                        } else {
                            EdgeHandle::Right
                        };
                        (source_handle, target_handle)
                    }
                    // Same priority
                    std::cmp::Ordering::Equal => {
                        let source_handle = if source_is_infra {
                            EdgeHandle::Bottom
                        } else {
                            EdgeHandle::Right
                        };
                        let target_handle = if target_is_infra {
                            EdgeHandle::Bottom
                        } else {
                            EdgeHandle::Left
                        };
                        (source_handle, target_handle)
                    }
                }
            }
        }
    }

    /// Choose handles for multi-hop edges that route around the side
    /// Both handles should be on the same side (left or right) for clean routing
    fn choose_side_handles_for_multi_hop(
        source_is_infra: bool,
        target_is_infra: bool,
    ) -> (EdgeHandle, EdgeHandle) {
        // Determine which side to route: left is generally preferred to keep
        // long edges on the periphery

        // Check if either node has infra constraints
        let source_can_use_left = !source_is_infra;
        let source_can_use_right = source_is_infra;
        let target_can_use_left = !target_is_infra;
        let target_can_use_right = target_is_infra;

        // Try to route on the left side first (keeps edges on periphery)
        if source_can_use_left && target_can_use_left {
            return (EdgeHandle::Left, EdgeHandle::Left);
        }

        // If left doesn't work, try right side
        if source_can_use_right && target_can_use_right {
            return (EdgeHandle::Right, EdgeHandle::Right);
        }

        // If we can't use the same side due to infra constraints,
        // fall back to using Bottom for infra nodes
        let source_handle = if source_is_infra {
            EdgeHandle::Bottom
        } else {
            EdgeHandle::Left // Prefer left for non-infra
        };

        let target_handle = if target_is_infra {
            EdgeHandle::Bottom
        } else {
            EdgeHandle::Left // Prefer left for non-infra
        };

        (source_handle, target_handle)
    }

    /// Handle edges within the same subnet - defer to anchor analysis
    /// For intra-subnet edges, we can't know the optimal handles until nodes are positioned
    /// So we return neutral defaults that will be overridden by anchor analysis
    fn from_same_subnet(
        _source_is_infra: bool,
        _target_is_infra: bool,
    ) -> (EdgeHandle, EdgeHandle) {
        // For intra-subnet edges, use Top as a neutral default
        // The anchor analyzer will determine the actual optimal placement
        // based on the node's actual position and all its edges
        (EdgeHandle::Top, EdgeHandle::Top)
    }
}

#[derive(
    Debug,
    Clone,
    PartialEq,
    Eq,
    Hash,
    Serialize,
    Deserialize,
    EnumDiscriminants,
    IntoStaticStr,
    EnumIter,
)]
#[strum_discriminants(derive(Display, Hash, Serialize, Deserialize, EnumIter))]
#[serde(tag = "edge_type")]
pub enum EdgeType {
    Interface {
        host_id: Uuid,
    }, // Connecting hosts with interfaces in multiple subnets
    HostVirtualization {
        vm_service_id: Uuid,
    },
    ServiceVirtualization {
        host_id: Uuid,
        containerizing_service_id: Uuid,
    },
    RequestPath {
        group_id: Uuid,
        source_binding_id: Uuid,
        target_binding_id: Uuid,
    },
    HubAndSpoke {
        group_id: Uuid,
        source_binding_id: Uuid,
        target_binding_id: Uuid,
    },
}

impl HasId for EdgeType {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for EdgeType {
    fn color(&self) -> &'static str {
        match self {
            EdgeType::RequestPath { .. } => EntityDiscriminants::Group.color(),
            EdgeType::HubAndSpoke { .. } => EntityDiscriminants::Group.color(),
            EdgeType::Interface { .. } => EntityDiscriminants::Host.color(),
            EdgeType::HostVirtualization { .. } => Concept::Virtualization.color(),
            EdgeType::ServiceVirtualization { .. } => Concept::Virtualization.color(),
        }
    }

    fn icon(&self) -> &'static str {
        match self {
            EdgeType::RequestPath { .. } => GroupTypeDiscriminants::RequestPath.icon(),
            EdgeType::HubAndSpoke { .. } => GroupTypeDiscriminants::HubAndSpoke.icon(),
            EdgeType::Interface { .. } => EntityDiscriminants::Host.icon(),
            EdgeType::HostVirtualization { .. } => Concept::Virtualization.icon(),
            EdgeType::ServiceVirtualization { .. } => Concept::Virtualization.icon(),
        }
    }
}

impl TypeMetadataProvider for EdgeType {
    fn name(&self) -> &'static str {
        match self {
            EdgeType::RequestPath { .. } => EdgeStyle::SmoothStep.into(),
            EdgeType::HubAndSpoke { .. } => GroupTypeDiscriminants::HubAndSpoke.name(),
            EdgeType::Interface { .. } => "Host Interface",
            EdgeType::HostVirtualization { .. } => "Virtualized Host",
            EdgeType::ServiceVirtualization { .. } => "Virtualized Service",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        let edge_style: &str = match &self {
            EdgeType::RequestPath { .. } => EdgeStyle::SmoothStep.into(),
            EdgeType::HubAndSpoke { .. } => EdgeStyle::SmoothStep.into(),
            EdgeType::Interface { .. } => EdgeStyle::SmoothStep.into(),
            EdgeType::HostVirtualization { .. } => EdgeStyle::Straight.into(),
            EdgeType::ServiceVirtualization { .. } => EdgeStyle::SmoothStep.into(),
        };

        let is_dashed = match &self {
            EdgeType::RequestPath { .. } => false,
            EdgeType::HubAndSpoke { .. } => false,
            EdgeType::Interface { .. } => true,
            EdgeType::HostVirtualization { .. } => true,
            EdgeType::ServiceVirtualization { .. } => true,
        };

        let has_start_marker = false;

        let has_end_marker = match &self {
            EdgeType::RequestPath { .. } => true,
            EdgeType::HubAndSpoke { .. } => true,
            EdgeType::Interface { .. } => false,
            EdgeType::HostVirtualization { .. } => false,
            EdgeType::ServiceVirtualization { .. } => false,
        };

        let is_host_edge = matches!(
            self,
            EdgeType::Interface { .. } | EdgeType::ServiceVirtualization { .. }
        );
        let is_group_edge = matches!(
            self,
            EdgeType::RequestPath { .. } | EdgeType::HubAndSpoke { .. }
        );

        serde_json::json!({
            "is_dashed": is_dashed,
            "has_start_marker": has_start_marker,
            "has_end_marker": has_end_marker,
            "edge_style": edge_style,
            "is_host_edge": is_host_edge,
            "is_group_edge": is_group_edge
        })
    }
}

#[cfg(test)]
mod tests {
    use strum::IntoEnumIterator;

    use crate::server::groups::r#impl::types::GroupTypeDiscriminants;

    #[test]
    fn edge_type_matches_group_type() {
        // This will fail to compile if GroupType adds/removes variants
        // without updating EdgeType
        let group_types: Vec<GroupTypeDiscriminants> = GroupTypeDiscriminants::iter().collect();

        assert_eq!(
            group_types.len(),
            2,
            "Update EdgeType to match GroupType variants!"
        );
        assert!(group_types.contains(&GroupTypeDiscriminants::RequestPath));
        assert!(group_types.contains(&GroupTypeDiscriminants::HubAndSpoke));
    }
}
