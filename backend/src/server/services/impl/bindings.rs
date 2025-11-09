use serde::{Deserialize, Serialize};
use std::hash::Hash;
use strum_macros::{EnumDiscriminants, IntoStaticStr};
use uuid::Uuid;

// impl PartialEq for ServiceBinding {
//     fn eq(&self, other: &Self) -> bool {
//         self.binding_id == other.binding_id && self.service_id == other.service_id
//     }
// }

#[derive(Copy, Debug, Clone, Serialize, Deserialize, Eq, EnumDiscriminants)]
#[strum_discriminants(derive(IntoStaticStr))]
#[serde(tag = "type")]
pub enum Binding {
    Interface {
        id: Uuid,
        interface_id: Uuid,
    },
    Port {
        id: Uuid,
        port_id: Uuid,
        interface_id: Option<Uuid>, // None = all interfaces
    },
}

impl Binding {
    pub fn id(&self) -> Uuid {
        match self {
            Binding::Interface { id, .. } => *id,
            Binding::Port { id, .. } => *id,
        }
    }

    pub fn interface_id(&self) -> Option<Uuid> {
        match self {
            Binding::Interface { interface_id, .. } => Some(*interface_id),
            Binding::Port { interface_id, .. } => *interface_id,
        }
    }

    pub fn port_id(&self) -> Option<Uuid> {
        match self {
            Binding::Interface { .. } => None,
            Binding::Port { port_id, .. } => Some(*port_id),
        }
    }
}

impl Default for Binding {
    fn default() -> Self {
        Self::Port {
            id: Uuid::nil(),
            port_id: Uuid::nil(),
            interface_id: Some(Uuid::nil()),
        }
    }
}

impl PartialEq for Binding {
    fn eq(&self, other: &Self) -> bool {
        match (self, other) {
            (
                Binding::Interface {
                    interface_id: self_interface_id,
                    ..
                },
                Binding::Interface {
                    interface_id: other_interface_id,
                    ..
                },
            ) => self_interface_id == other_interface_id,
            (
                Binding::Port {
                    port_id: self_port_id,
                    interface_id: self_interface_id,
                    ..
                },
                Binding::Port {
                    port_id: other_port_id,
                    interface_id: other_interface_id,
                    ..
                },
            ) => self_interface_id == other_interface_id && self_port_id == other_port_id,
            _ => false,
        }
    }
}

impl Hash for Binding {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.id().hash(state);
    }
}

impl Binding {
    pub fn new_interface(interface_id: Uuid) -> Self {
        Binding::Interface {
            id: Uuid::new_v4(),
            interface_id,
        }
    }

    pub fn new_port(port_id: Uuid, interface_id: Option<Uuid>) -> Self {
        Binding::Port {
            id: Uuid::new_v4(),
            port_id,
            interface_id,
        }
    }
}
