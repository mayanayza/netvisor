use crate::server::shared::entities::ChangeTriggersTopologyStaleness;
use crate::server::subnets::r#impl::base::Subnet;
use chrono::{DateTime, Utc};
use mac_address::MacAddress;
use rand::Rng;
use serde::{Deserialize, Serialize};
use std::fmt::Display;
use std::hash::Hash;
use std::net::{IpAddr, Ipv4Addr};
use utoipa::ToSchema;
use uuid::Uuid;

pub const ALL_INTERFACES_IP: IpAddr = IpAddr::V4(Ipv4Addr::new(0, 0, 0, 0));

#[derive(Debug, Clone, Serialize, Deserialize, Eq, PartialEq, Hash, ToSchema)]
pub struct InterfaceBase {
    pub network_id: Uuid,
    pub host_id: Uuid,
    pub subnet_id: Uuid,
    #[schema(value_type = String)]
    pub ip_address: IpAddr,
    #[schema(value_type = Option<String>)]
    pub mac_address: Option<MacAddress>,
    pub name: Option<String>,
}

impl Default for InterfaceBase {
    fn default() -> Self {
        Self {
            network_id: Uuid::nil(),
            host_id: Uuid::nil(),
            subnet_id: Uuid::nil(),
            ip_address: IpAddr::V4(Ipv4Addr::new(0, 0, 0, 0)),
            mac_address: None,
            name: None,
        }
    }
}

impl InterfaceBase {
    /// Create a conceptual interface for a subnet.
    /// `host_id` can be `Uuid::nil()` as a placeholder - server will set the correct one.
    pub fn new_conceptual(host_id: Uuid, subnet: &Subnet) -> Self {
        let ip_address = IpAddr::V4(Ipv4Addr::new(203, 0, 113, rand::rng().random_range(1..255)));

        Self {
            network_id: subnet.base.network_id,
            host_id,
            subnet_id: subnet.id,
            ip_address,
            mac_address: None,
            name: Some(subnet.base.name.clone()),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Eq, Default, ToSchema)]
#[schema(example = crate::server::shared::types::examples::interface)]
pub struct Interface {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
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

impl Display for Interface {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "Interface {}: {} on subnet {}",
            self.id, self.base.ip_address, self.base.subnet_id
        )
    }
}

impl Interface {
    pub fn new(base: InterfaceBase) -> Self {
        let now = Utc::now();
        Self {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base,
        }
    }
}

impl ChangeTriggersTopologyStaleness<Interface> for Interface {
    fn triggers_staleness(&self, other: Option<Interface>) -> bool {
        if let Some(other_interface) = other {
            self.base.ip_address != other_interface.base.ip_address
                || self.base.subnet_id != other_interface.base.subnet_id
                || self.base.host_id != other_interface.base.host_id
        } else {
            true
        }
    }
}
