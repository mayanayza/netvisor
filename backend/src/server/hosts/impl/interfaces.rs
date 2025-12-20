use mac_address::MacAddress;
use rand::Rng;
use serde::{Deserialize, Serialize};
use std::hash::Hash;
use std::net::{IpAddr, Ipv4Addr};
use uuid::Uuid;

use crate::server::subnets::r#impl::base::Subnet;

pub const ALL_INTERFACES_IP: IpAddr = IpAddr::V4(Ipv4Addr::new(0, 0, 0, 0));

#[derive(Debug, Clone, Serialize, Deserialize, Eq, PartialEq, Hash)]
pub struct InterfaceBase {
    pub subnet_id: Uuid,
    pub ip_address: IpAddr,
    pub mac_address: Option<MacAddress>,
    pub name: Option<String>,
}

impl InterfaceBase {
    pub fn new_conceptual(subnet: &Subnet) -> Self {
        let ip_address = IpAddr::V4(Ipv4Addr::new(203, 0, 113, rand::rng().random_range(1..255)));

        Self {
            subnet_id: subnet.id,
            ip_address,
            mac_address: None,
            name: Some(subnet.base.name.clone()),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Eq)]
pub struct Interface {
    pub id: Uuid,
    #[serde(flatten)]
    pub base: InterfaceBase,
}

impl Hash for Interface {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.base.ip_address.hash(state);
        self.base.subnet_id.hash(state);
        self.base.mac_address.hash(state);
    }
}

impl PartialEq for Interface {
    fn eq(&self, other: &Self) -> bool {
        (self.base.ip_address == other.base.ip_address
            && self.base.subnet_id == other.base.subnet_id)
            || (self.base.mac_address == other.base.mac_address
                && self.base.mac_address.is_some()
                && other.base.mac_address.is_some())
            || (self.id == other.id)
    }
}

impl Interface {
    pub fn new(base: InterfaceBase) -> Self {
        Self {
            id: Uuid::new_v4(),
            base,
        }
    }
}
