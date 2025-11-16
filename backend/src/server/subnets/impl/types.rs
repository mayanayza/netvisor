use serde::{Deserialize, Serialize};
use strum::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};

use crate::server::shared::{
    entities::Entity,
    types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider},
};

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
            SubnetType::Remote | SubnetType::Internet | SubnetType::DockerBridge
        );

        let is_for_containers = matches!(self, SubnetType::DockerBridge);

        serde_json::json!({
            "network_scan_discovery_eligible": network_scan_discovery_eligible,
            "is_for_containers": is_for_containers
        })
    }
}
