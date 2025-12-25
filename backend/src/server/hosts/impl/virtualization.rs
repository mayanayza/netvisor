use serde::{Deserialize, Serialize};
use std::hash::Hash;
use strum_macros::IntoStaticStr;
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

use crate::server::shared::{
    concepts::Concept,
    types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider},
};

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize, IntoStaticStr, ToSchema)]
#[schema(title = "HostVirtualization")]
#[serde(tag = "type", content = "details")]
pub enum HostVirtualization {
    #[schema(title = "Proxmox")]
    Proxmox(ProxmoxVirtualization),
}

#[derive(Debug, Clone, Serialize, Validate, Deserialize, PartialEq, Eq, Hash, ToSchema)]
pub struct ProxmoxVirtualization {
    pub vm_name: Option<String>,
    pub vm_id: Option<String>,
    pub service_id: Uuid,
}

impl HasId for HostVirtualization {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for HostVirtualization {
    fn color(&self) -> &'static str {
        Concept::Virtualization.color()
    }
    fn icon(&self) -> &'static str {
        Concept::Virtualization.icon()
    }
}

impl TypeMetadataProvider for HostVirtualization {
    fn name(&self) -> &'static str {
        "Proxmox"
    }

    fn description(&self) -> &'static str {
        "A host running as a Proxmox VM"
    }
}
