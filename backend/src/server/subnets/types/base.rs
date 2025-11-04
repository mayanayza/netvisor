use std::net::Ipv4Addr;

use crate::server::discovery::types::base::DiscoveryType;
use crate::server::shared::types::api::deserialize_empty_string_as_none;
use crate::server::shared::types::entities::{DiscoveryMetadata, EntitySource};
use chrono::{DateTime, Utc};
use cidr::{IpCidr, Ipv4Cidr};
use pnet::ipnetwork::IpNetwork;
use serde::{Deserialize, Serialize};
use std::hash::Hash;
use strum_macros::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};
use uuid::Uuid;
use validator::Validate;

use crate::server::{
    hosts::types::base::Host,
    services::types::base::Service,
    shared::{
        constants::Entity,
        types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider},
    },
};

#[derive(Debug, Clone, Validate, Serialize, Deserialize, Eq, PartialEq, Hash)]
pub struct SubnetBase {
    pub cidr: IpCidr,
    pub network_id: Uuid,
    #[validate(length(min = 0, max = 100))]
    pub name: String, // "Home LAN", "VPN Network", etc.
    #[serde(deserialize_with = "deserialize_empty_string_as_none")]
    #[validate(length(min = 0, max = 500))]
    pub description: Option<String>,
    pub subnet_type: SubnetType,
    pub source: EntitySource,
}

impl Default for SubnetBase {
    fn default() -> Self {
        Self {
            cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(127, 0, 0, 1), 24).unwrap()),
            name: "New Subnet".to_string(),
            network_id: Uuid::new_v4(),
            description: None,
            subnet_type: SubnetType::Unknown,
            source: EntitySource::Manual,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Subnet {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    pub base: SubnetBase,
}

impl Subnet {
    pub fn new(base: SubnetBase) -> Self {
        let now = Utc::now();
        Self {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base,
        }
    }

    pub fn is_docker_bridge_subnet(&self) -> bool {
        self.base.subnet_type == SubnetType::DockerBridge
    }

    pub fn from_discovery(
        interface_name: String,
        ip_network: &IpNetwork,
        daemon_id: Uuid,
        discovery_type: &DiscoveryType,
        network_id: Uuid,
    ) -> Option<Self> {
        let subnet_type = SubnetType::from_interface_name(&interface_name);

        match ip_network {
            IpNetwork::V6(_) => None,
            IpNetwork::V4(ipv4_network) => {
                let (network_addr, prefix_len) = match (&subnet_type, ipv4_network.prefix()) {
                    // VPN tunnels with /32 -> expand to /24
                    (SubnetType::VpnTunnel, 32) => {
                        let ip_octets = ipv4_network.ip().octets();
                        let network_addr =
                            std::net::Ipv4Addr::new(ip_octets[0], ip_octets[1], ip_octets[2], 0);
                        (network_addr, 24)
                    }
                    // Skip other /32 single IPs
                    (_, 32) => return None,
                    // Normal case - use the network's actual network address and prefix
                    _ => (ipv4_network.network(), ipv4_network.prefix()),
                };

                let cidr = IpCidr::V4(Ipv4Cidr::new(network_addr, prefix_len).ok()?);

                Some(Subnet::new(SubnetBase {
                    cidr,
                    network_id,
                    description: None,
                    name: cidr.to_string(),
                    subnet_type,
                    source: EntitySource::Discovery {
                        metadata: vec![DiscoveryMetadata::new(discovery_type.clone(), daemon_id)],
                    },
                }))
            }
        }
    }

    pub fn has_interface_with_service(&self, host: &Host, service: &Service) -> bool {
        service.base.bindings.iter().any(|binding| {
            host.base.interfaces.iter().any(|interface| {
                let interface_match = match binding.interface_id() {
                    Some(id) => interface.id == id,
                    None => true, // Listens on all interfaces
                };

                interface_match && interface.base.subnet_id == self.id
            })
        })
    }

    pub fn is_organizational_subnet(&self) -> bool {
        let organizational_cidr = IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(0, 0, 0, 0), 0).unwrap());
        self.base.cidr == organizational_cidr
    }
}

impl PartialEq for Subnet {
    fn eq(&self, other: &Self) -> bool {
        let network_match =
            self.base.cidr == other.base.cidr && self.base.network_id == other.base.network_id;

        network_match || self.id == other.id
    }
}

impl Hash for Subnet {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.base.cidr.hash(state);
    }
}

#[derive(
    Debug,
    Clone,
    Copy,
    Serialize,
    Deserialize,
    Eq,
    PartialEq,
    Hash,
    EnumDiscriminants,
    EnumIter,
    IntoStaticStr,
    Default,
)]
#[strum_discriminants(derive(Display, Hash, Serialize, Deserialize, EnumIter))]
pub enum SubnetType {
    Internet,
    Remote,

    Gateway,
    VpnTunnel,
    Dmz,

    Lan,
    WiFi,
    IoT,
    Guest,

    DockerBridge,
    Management,
    Storage,

    Unknown,
    #[default]
    None,
}

impl SubnetType {
    pub fn from_interface_name(interface_name: &str) -> Self {
        // Docker containers
        if Self::match_interface_names(&["docker", "br-"], interface_name) {
            return SubnetType::DockerBridge;
        }

        // VPN tunnels
        if Self::match_interface_names(&["tun", "utun", "wg", "tap", "ppp", "vpn"], interface_name)
        {
            return SubnetType::VpnTunnel;
        }

        // WiFi interfaces
        if Self::match_interface_names(&["wlan", "wifi", "wl"], interface_name) {
            return SubnetType::WiFi;
        }

        // Guest network (often labeled explicitly)
        if Self::match_interface_names(&["guest"], interface_name) {
            return SubnetType::Guest;
        }

        // IoT network (some routers use this naming)
        if Self::match_interface_names(&["iot"], interface_name) {
            return SubnetType::IoT;
        }

        // DMZ (often labeled explicitly)
        if Self::match_interface_names(&["dmz"], interface_name) {
            return SubnetType::Dmz;
        }

        // Management interfaces
        if Self::match_interface_names(&["mgmt", "ipmi", "bmc"], interface_name) {
            return SubnetType::Management;
        }

        // Storage networks
        if Self::match_interface_names(&["iscsi", "san", "storage"], interface_name) {
            return SubnetType::Storage;
        }

        // Standard LAN interfaces (catch-all for ethernet)
        if Self::match_interface_names(&["eth", "en", "eno", "enp", "ens"], interface_name) {
            return SubnetType::Lan;
        }

        SubnetType::Unknown
    }

    fn match_interface_names(patterns: &[&str], interface_name: &str) -> bool {
        let name_lower = interface_name.to_lowercase();
        patterns.iter().any(|pattern| {
            if *pattern == "br-" {
                // Special case for Docker bridges: br- followed by hex chars
                name_lower.starts_with(pattern)
                    && name_lower
                        .get(pattern.len()..)
                        .map(|rest| {
                            !rest.is_empty() && rest.chars().all(|c| c.is_ascii_alphanumeric())
                        })
                        .unwrap_or(false)
            } else {
                // Original logic for other patterns
                name_lower.starts_with(pattern)
                    && name_lower
                        .get(pattern.len()..)
                        .map(|rest| {
                            rest.is_empty()
                                || rest.chars().next().unwrap_or_default().is_ascii_digit()
                        })
                        .unwrap_or(false)
            }
        })
    }
}

impl HasId for SubnetType {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for SubnetType {
    fn color(&self) -> &'static str {
        match self {
            SubnetType::Internet => "blue",
            SubnetType::Remote => Entity::Subnet.color(),

            SubnetType::Gateway => Entity::Gateway.color(),
            SubnetType::VpnTunnel => Entity::Vpn.color(),
            SubnetType::Dmz => "rose",

            SubnetType::Lan => Entity::Subnet.color(),
            SubnetType::IoT => Entity::IoT.color(),
            SubnetType::Guest => "green",
            SubnetType::WiFi => "teal",

            SubnetType::Management => "gray",
            SubnetType::DockerBridge => Entity::Virtualization.color(),
            SubnetType::Storage => Entity::Storage.color(),

            SubnetType::Unknown => "gray",
            SubnetType::None => "gray",
        }
    }
    fn icon(&self) -> &'static str {
        match self {
            SubnetType::Internet => "Globe",
            SubnetType::Remote => Entity::Subnet.icon(),

            SubnetType::Gateway => Entity::Gateway.icon(),
            SubnetType::VpnTunnel => Entity::Vpn.icon(),
            SubnetType::Dmz => Entity::Subnet.icon(),

            SubnetType::Lan => Entity::Subnet.icon(),
            SubnetType::IoT => Entity::IoT.icon(),
            SubnetType::Guest => "User",
            SubnetType::WiFi => "WiFi",

            SubnetType::Management => "ServerCog",
            SubnetType::DockerBridge => "Box",
            SubnetType::Storage => Entity::Storage.icon(),

            SubnetType::Unknown => Entity::Subnet.icon(),
            SubnetType::None => Entity::Subnet.icon(),
        }
    }
}

impl TypeMetadataProvider for SubnetType {
    fn name(&self) -> &'static str {
        match self {
            SubnetType::Internet => "Internet",
            SubnetType::Remote => "Remote",

            SubnetType::Gateway => "Gateway",
            SubnetType::VpnTunnel => "VPN",
            SubnetType::Dmz => "DMZ",

            SubnetType::Lan => "LAN",
            SubnetType::IoT => "IoT",
            SubnetType::Guest => "Guest",
            SubnetType::WiFi => "WiFi",

            SubnetType::Management => "Management",
            SubnetType::DockerBridge => "Docker Bridge",
            SubnetType::Storage => "Storage",

            SubnetType::Unknown => "Unknown",
            SubnetType::None => "No Subnet",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            SubnetType::Internet => "Internet",
            SubnetType::Remote => "Remote network",

            SubnetType::Gateway => "Gateway subnet",
            SubnetType::VpnTunnel => "Virtual private network",
            SubnetType::Dmz => "Demilitarized zone",

            SubnetType::Lan => "Local area network",
            SubnetType::IoT => "Internet of things",
            SubnetType::Guest => "Guest network",
            SubnetType::WiFi => "WiFi network",

            SubnetType::Management => "Management network",
            SubnetType::DockerBridge => "Docker bridge network",
            SubnetType::Storage => "Storage network",

            SubnetType::Unknown => "Unknown network type",
            SubnetType::None => "No Subnet",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        let network_scan_discovery_eligible = !matches!(
            &self,
            SubnetType::Remote
                | SubnetType::Internet
                | SubnetType::DockerBridge
                | SubnetType::Unknown
                | SubnetType::None
        );

        serde_json::json!({
            "network_scan_discovery_eligible": network_scan_discovery_eligible,
        })
    }
}
