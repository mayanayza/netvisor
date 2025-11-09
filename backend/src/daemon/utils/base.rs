use crate::server::discovery::r#impl::types::DiscoveryType;
use crate::server::hosts::r#impl::interfaces::{Interface, InterfaceBase};
use crate::server::subnets::r#impl::base::Subnet;
use anyhow::Error;
use anyhow::Result;
use anyhow::anyhow;
use async_trait::async_trait;
use bollard::Docker;
use cidr::IpCidr;
use local_ip_address::local_ip;
use mac_address::MacAddress;
use net_route::Handle;
use pnet::ipnetwork::IpNetwork;
use std::collections::HashMap;
use std::net::IpAddr;
use uuid::Uuid;

/// Cross-platform system utilities trait
#[async_trait]
pub trait DaemonUtils {
    fn new() -> Self;

    /// Get MAC address for an IP from ARP table
    async fn get_mac_address_for_ip(&self, ip: IpAddr) -> Result<Option<MacAddress>, Error>;

    fn get_own_ip_address(&self) -> Result<IpAddr, Error> {
        local_ip().map_err(|e| anyhow!("Failed to get local IP address: {}", e))
    }

    fn get_own_mac_address(&self) -> Result<Option<MacAddress>, Error> {
        mac_address::get_mac_address().map_err(|e| anyhow!("Failed to get own MAC address: {}", e))
    }

    fn get_own_hostname(&self) -> Option<String> {
        hostname::get()
            .ok()
            .map(|os_str| os_str.to_string_lossy().into_owned())
    }

    async fn get_own_interfaces(
        &self,
        discovery_type: DiscoveryType,
        daemon_id: Uuid,
        network_id: Uuid,
    ) -> Result<(Vec<Interface>, Vec<Subnet>)> {
        let interfaces = pnet::datalink::interfaces();

        // First pass: collect all interface data and potential subnets
        let mut potential_subnets: Vec<(String, IpNetwork)> = Vec::new();
        let mut interface_data: Vec<(String, IpAddr, Option<MacAddress>)> = Vec::new();

        for interface in interfaces.into_iter().filter(|i| !i.is_loopback()) {
            let name = interface.name.clone();
            let mac_address = match interface.mac {
                Some(mac) if !mac.octets().iter().all(|o| *o == 0) => {
                    Some(MacAddress::new(mac.octets()))
                }
                _ => None,
            };

            for ip in interface.ips.iter() {
                interface_data.push((name.clone(), ip.ip(), mac_address));
                potential_subnets.push((name.clone(), *ip));
            }
        }

        // Second pass: create unique subnets from valid networks
        let mut subnet_map: HashMap<IpCidr, Subnet> = HashMap::new();

        for (interface_name, ip_network) in potential_subnets {
            if let Some(subnet) = Subnet::from_discovery(
                interface_name,
                &ip_network,
                daemon_id,
                &discovery_type,
                network_id,
            ) {
                subnet_map.entry(subnet.base.cidr).or_insert(subnet);
            }
        }

        // Third pass: assign all interfaces to appropriate subnets
        let mut interfaces_list = Vec::new();

        for (interface_name, ip_addr, mac_address) in interface_data {
            // Find which subnet this IP belongs to
            if let Some(subnet) = subnet_map.values().find(|s| s.base.cidr.contains(&ip_addr)) {
                interfaces_list.push(Interface::new(InterfaceBase {
                    name: Some(interface_name),
                    subnet_id: subnet.id,
                    ip_address: ip_addr,
                    mac_address,
                }));
            }
        }

        let subnets: Vec<Subnet> = subnet_map.into_values().collect();

        Ok((interfaces_list, subnets))
    }

    async fn get_own_docker_socket(&self) -> Result<bool, Error> {
        match Docker::connect_with_local_defaults() {
            Ok(docker) => {
                // Actually verify it's a Docker daemon by pinging it
                if docker.ping().await.is_ok() {
                    Ok(true)
                } else {
                    Ok(false)
                }
            }
            Err(_) => Ok(false),
        }
    }

    async fn get_own_routing_table_gateway_ips(&self) -> Result<Vec<IpAddr>, Error> {
        let routing_handle = Handle::new()?;
        let routes = routing_handle.list().await?;

        Ok(routes
            .into_iter()
            .filter_map(|r| match r.gateway {
                Some(gateway) if gateway != r.destination => Some(gateway),
                _ => None,
            })
            .collect())
    }
}

#[cfg(target_os = "linux")]
use crate::daemon::utils::linux::LinuxDaemonUtils;
#[cfg(target_os = "linux")]
pub type PlatformDaemonUtils = LinuxDaemonUtils;

#[cfg(target_os = "macos")]
use crate::daemon::utils::macos::MacOsDaemonUtils;
#[cfg(target_os = "macos")]
pub type PlatformDaemonUtils = MacOsDaemonUtils;

#[cfg(target_family = "windows")]
use crate::daemon::utils::windows::WindowsDaemonUtils;
#[cfg(target_family = "windows")]
pub type PlatformDaemonUtils = WindowsDaemonUtils;

pub fn create_system_utils() -> PlatformDaemonUtils {
    PlatformDaemonUtils::new()
}
