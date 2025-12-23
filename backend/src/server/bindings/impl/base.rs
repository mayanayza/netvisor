use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::{fmt::Display, hash::Hash};
use strum_macros::{EnumDiscriminants, IntoStaticStr};
use utoipa::ToSchema;
use uuid::Uuid;

use crate::server::shared::entities::ChangeTriggersTopologyStaleness;

/// The type of binding - either to an interface or to a port
#[derive(Copy, Debug, Clone, Serialize, Deserialize, Eq, PartialEq, EnumDiscriminants, ToSchema)]
#[strum_discriminants(derive(IntoStaticStr))]
#[serde(tag = "type")]
pub enum BindingType {
    #[schema(title = "Interface")]
    Interface { interface_id: Uuid },
    #[schema(title = "Port")]
    Port {
        port_id: Uuid,
        #[serde(skip_serializing_if = "Option::is_none")]
        interface_id: Option<Uuid>, // None = all interfaces
    },
}

impl Default for BindingType {
    fn default() -> Self {
        BindingType::Port {
            port_id: Uuid::nil(),
            interface_id: Some(Uuid::nil()),
        }
    }
}

/// The base data for a Binding entity (everything except id, created_at, updated_at)
#[derive(Copy, Debug, Clone, Eq, Serialize, Deserialize, ToSchema)]
pub struct BindingBase {
    #[serde(default)]
    pub service_id: Uuid,
    #[serde(default)]
    pub network_id: Uuid,
    #[serde(flatten)]
    pub binding_type: BindingType,
}

impl BindingBase {
    pub fn new(service_id: Uuid, network_id: Uuid, binding_type: BindingType) -> Self {
        Self {
            service_id,
            network_id,
            binding_type,
        }
    }

    /// Create a BindingBase without service/network (will be set by server)
    pub fn new_serviceless(binding_type: BindingType) -> Self {
        Self {
            service_id: Uuid::nil(),
            network_id: Uuid::nil(),
            binding_type,
        }
    }
}

impl Default for BindingBase {
    fn default() -> Self {
        Self::new_serviceless(BindingType::default())
    }
}

impl PartialEq for BindingBase {
    fn eq(&self, other: &Self) -> bool {
        self.binding_type == other.binding_type
    }
}

impl Hash for BindingBase {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.binding_type.hash(state);
    }
}

impl Hash for BindingType {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        match self {
            BindingType::Interface { interface_id } => {
                "interface".hash(state);
                interface_id.hash(state);
            }
            BindingType::Port {
                port_id,
                interface_id,
            } => {
                "port".hash(state);
                port_id.hash(state);
                interface_id.hash(state);
            }
        }
    }
}

/// The Binding entity
#[derive(Copy, Debug, Clone, Eq, Serialize, Deserialize, ToSchema)]
pub struct Binding {
    pub id: Uuid,
    #[serde(default = "Utc::now")]
    pub created_at: DateTime<Utc>,
    #[serde(default = "Utc::now")]
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    pub base: BindingBase,
}

impl Hash for Binding {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.id.hash(state);
    }
}

impl PartialEq for Binding {
    fn eq(&self, other: &Self) -> bool {
        self.base == other.base
    }
}

impl Default for Binding {
    fn default() -> Self {
        Self::new_serviceless(BindingType::default())
    }
}

impl ChangeTriggersTopologyStaleness<Binding> for Binding {
    fn triggers_staleness(&self, other: Option<Binding>) -> bool {
        if let Some(other_binding) = other {
            self.base.binding_type != other_binding.base.binding_type
                || self.base.service_id != other_binding.base.service_id
        } else {
            true // New or deleted binding triggers staleness
        }
    }
}

impl Display for Binding {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match &self.base.binding_type {
            BindingType::Interface { interface_id } => {
                write!(f, "Interface binding {} -> {}", self.id, interface_id)
            }
            BindingType::Port {
                port_id,
                interface_id,
            } => {
                if let Some(iface_id) = interface_id {
                    write!(
                        f,
                        "Port binding {} -> {} (interface {})",
                        self.id, port_id, iface_id
                    )
                } else {
                    write!(
                        f,
                        "Port binding {} -> {} (all interfaces)",
                        self.id, port_id
                    )
                }
            }
        }
    }
}

impl Binding {
    pub fn new(base: BindingBase) -> Self {
        let now = Utc::now();
        Self {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base,
        }
    }

    /// Create a Binding with just a BindingType (service_id/network_id set to nil).
    /// Use this for bindings created during discovery before service assignment.
    pub fn new_serviceless(binding_type: BindingType) -> Self {
        Self::new(BindingBase::new_serviceless(binding_type))
    }

    // Convenience accessors
    pub fn id(&self) -> Uuid {
        self.id
    }

    pub fn service_id(&self) -> Uuid {
        self.base.service_id
    }

    pub fn network_id(&self) -> Uuid {
        self.base.network_id
    }

    pub fn binding_type(&self) -> BindingType {
        self.base.binding_type
    }

    pub fn interface_id(&self) -> Option<Uuid> {
        match self.base.binding_type {
            BindingType::Interface { interface_id } => Some(interface_id),
            BindingType::Port { interface_id, .. } => interface_id,
        }
    }

    pub fn port_id(&self) -> Option<Uuid> {
        match self.base.binding_type {
            BindingType::Interface { .. } => None,
            BindingType::Port { port_id, .. } => Some(port_id),
        }
    }

    /// Set the service_id and network_id (for serviceless bindings that get resolved later)
    pub fn with_service(mut self, service_id: Uuid, network_id: Uuid) -> Self {
        self.base.service_id = service_id;
        self.base.network_id = network_id;
        self
    }

    // Legacy convenience constructors (full versions)
    pub fn new_interface(service_id: Uuid, network_id: Uuid, interface_id: Uuid) -> Self {
        Self::new(BindingBase::new(
            service_id,
            network_id,
            BindingType::Interface { interface_id },
        ))
    }

    pub fn new_port(
        service_id: Uuid,
        network_id: Uuid,
        port_id: Uuid,
        interface_id: Option<Uuid>,
    ) -> Self {
        Self::new(BindingBase::new(
            service_id,
            network_id,
            BindingType::Port {
                port_id,
                interface_id,
            },
        ))
    }

    // Serviceless convenience constructors (renamed from _placeholder)
    pub fn new_interface_serviceless(interface_id: Uuid) -> Self {
        Self::new_serviceless(BindingType::Interface { interface_id })
    }

    pub fn new_port_serviceless(port_id: Uuid, interface_id: Option<Uuid>) -> Self {
        Self::new_serviceless(BindingType::Port {
            port_id,
            interface_id,
        })
    }
}

// Keep BindingDiscriminants for external code that uses it
pub use BindingTypeDiscriminants as BindingDiscriminants;
