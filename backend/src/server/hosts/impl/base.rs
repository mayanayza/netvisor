use crate::server::hosts::r#impl::virtualization::HostVirtualization;
use crate::server::shared::entities::ChangeTriggersTopologyStaleness;
use crate::server::shared::types::api::deserialize_empty_string_as_none;
use crate::server::shared::types::entities::EntitySource;
use crate::server::subnets::r#impl::base::Subnet;
use crate::server::{
    hosts::r#impl::ports::Port,
    hosts::r#impl::{interfaces::Interface, targets::HostTarget},
};
use chrono::{DateTime, Utc};
use mac_address::MacAddress;
use serde::{Deserialize, Serialize};
use std::fmt::Display;
use std::{hash::Hash, net::IpAddr};
use uuid::Uuid;
use validator::Validate;

static INVALID_MACS_BYTES: &[[u8; 6]; 2] = &[
    [0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
    [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF],
];

#[derive(Debug, Clone, Serialize, Validate, Deserialize, Eq, PartialEq, Hash)]
pub struct HostBase {
    #[validate(length(min = 0, max = 100))]
    pub name: String,
    pub network_id: Uuid,
    pub hostname: Option<String>,
    #[validate(length(min = 0, max = 100))]
    #[serde(deserialize_with = "deserialize_empty_string_as_none")]
    pub description: Option<String>,
    pub target: HostTarget,
    pub interfaces: Vec<Interface>,
    pub services: Vec<Uuid>,
    pub ports: Vec<Port>,
    pub source: EntitySource,
    pub virtualization: Option<HostVirtualization>,
    pub hidden: bool,
}

impl Default for HostBase {
    fn default() -> Self {
        Self {
            name: String::new(),
            network_id: Uuid::nil(),
            hostname: None,
            description: None,
            target: HostTarget::None,
            interfaces: Vec::new(),
            services: Vec::new(),
            ports: Vec::new(),
            source: EntitySource::Unknown,
            virtualization: None,
            hidden: false,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Eq)]
pub struct Host {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    pub base: HostBase,
}

impl Hash for Host {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        let invalid_macs = INVALID_MACS_BYTES.map(MacAddress::new);
        // Collect valid MAC addresses
        let mut valid_macs: Vec<MacAddress> = self
            .base
            .interfaces
            .iter()
            .filter_map(|iface| iface.base.mac_address)
            .filter(|mac| !invalid_macs.contains(mac))
            .collect();
        valid_macs.sort_unstable();

        // Collect (subnet_id, ip_address) pairs
        let mut subnet_ips: Vec<(Uuid, IpAddr)> = self
            .base
            .interfaces
            .iter()
            .map(|iface| (iface.base.subnet_id, iface.base.ip_address))
            .collect();
        subnet_ips.sort_unstable();

        // Hash both collections
        valid_macs.hash(state);
        subnet_ips.hash(state);
    }
}

impl PartialEq for Host {
    fn eq(&self, other: &Self) -> bool {
        let network_match = self.base.network_id == other.base.network_id;
        let invalid_macs = INVALID_MACS_BYTES.map(MacAddress::new);
        let macs_a: Vec<Option<MacAddress>> = self
            .base
            .interfaces
            .iter()
            .map(|s| s.base.mac_address)
            .collect();
        let macs_b: Vec<Option<MacAddress>> = other
            .base
            .interfaces
            .iter()
            .map(|s| s.base.mac_address)
            .collect();

        let mac_match = macs_a.iter().any(|mac_a| {
            macs_b.iter().any(|mac_b| match (mac_a, mac_b) {
                (Some(a), Some(b)) => !invalid_macs.contains(a) && a == b,
                (_, _) => false,
            })
        });

        let subnet_ip_match = self.base.interfaces.iter().any(|subnet_a| {
            other.base.interfaces.iter().any(|subnet_b| {
                subnet_a.base.subnet_id == subnet_b.base.subnet_id
                    && subnet_a.base.ip_address == subnet_b.base.ip_address
            })
        });

        self.id == other.id || (network_match && mac_match) || (network_match && subnet_ip_match)
    }
}

impl Display for Host {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}: {:?}", self.base.name, self.id)
    }
}

impl Host {
    pub fn new(base: HostBase) -> Self {
        let now = chrono::Utc::now();
        Self {
            id: uuid::Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base,
        }
    }

    pub fn get_interface(&self, interface_id: &Option<Uuid>) -> Option<&Interface> {
        match interface_id {
            Some(id) => self.base.interfaces.iter().find(|i| &i.id == id),
            None => None,
        }
    }

    pub fn get_first_non_docker_bridge_interface(&self, subnets: &[Subnet]) -> Option<&Interface> {
        self.base.interfaces.iter().find(|i| {
            subnets
                .iter()
                .find(|s| s.id == i.base.subnet_id)
                .map(|s| !s.is_docker_bridge_subnet())
                .unwrap_or(false)
        })
    }

    pub fn get_port(&self, port_id: &Uuid) -> Option<&Port> {
        self.base.ports.iter().find(|p| &p.id == port_id)
    }

    pub fn add_service(&mut self, service_id: Uuid) {
        self.base.services.push(service_id);
    }
}

impl ChangeTriggersTopologyStaleness<Host> for Host {
    fn triggers_staleness(&self, other: Option<Host>) -> bool {
        if let Some(other_host) = other {
            self.base.services != other_host.base.services
                || self.base.hostname != other_host.base.hostname
                || self.base.interfaces != other_host.base.interfaces
                || self.base.virtualization != other_host.base.virtualization
                || self.base.hidden != other_host.base.hidden
        } else {
            true
        }
    }
}
