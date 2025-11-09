#[cfg(target_os = "linux")]
use crate::daemon::utils::base::DaemonUtils;

#[cfg(target_os = "linux")]
pub struct LinuxDaemonUtils;

#[cfg(target_os = "linux")]
use anyhow::{Error, Result, anyhow};
#[cfg(target_os = "linux")]
use async_trait::async_trait;
#[cfg(target_os = "linux")]
use mac_address::MacAddress;
#[cfg(target_os = "linux")]
use std::net::IpAddr;
#[cfg(target_os = "linux")]
#[async_trait]
impl DaemonUtils for LinuxDaemonUtils {
    fn new() -> Self {
        Self {}
    }

    async fn get_mac_address_for_ip(&self, ip: IpAddr) -> Result<Option<MacAddress>, Error> {
        use procfs::net;

        let ipv4_addr = match ip {
            IpAddr::V4(addr) => addr,
            IpAddr::V6(_) => return Ok(None), // IPv6 ARP not supported yet
        };

        let arp_table = net::arp()
            .map_err(|e| anyhow!("Failed to read ARP table from /proc/net/arp: {}", e))?;

        for entry in arp_table {
            if entry.ip_address == ipv4_addr
                && let Some(hw_addr) = entry.hw_address
            {
                let mac = MacAddress::new(hw_addr);
                return Ok(Some(mac));
            }
        }

        Ok(None)
    }

    #[cfg(unix)]
    async fn get_optimal_port_batch_size(&self) -> Result<usize, Error> {
        use rlimit::{Resource, getrlimit};

        let (soft_limit, _hard_limit) = getrlimit(Resource::NOFILE)
            .map_err(|e| anyhow::anyhow!("Failed to get ulimit: {}", e))?;

        // Reserve file descriptors for:
        // - stdin, stdout, stderr (3)
        // - HTTP client connections for endpoints (50)
        // - Docker socket and other daemon operations (50)
        // - Buffer for safety (100)
        let reserved = 203;

        let available = soft_limit.saturating_sub(reserved);

        // Calculate optimal batch size
        let optimal = if available < 50 {
            // Very constrained system (like macOS default of 256)
            // Use minimal batch size
            tracing::warn!(
                "Low file descriptor limit detected ({}). Using minimal batch size of 20. \
                Consider increasing with 'ulimit -n 8192'",
                soft_limit
            );
            20
        } else if available < 500 {
            // Moderate system
            available / 2 // Use half of available to be conservative
        } else {
            // High-limit system (Linux default ~8000+)
            // Cap at 1000 for reasonable performance without overwhelming target
            std::cmp::min(available, 1000)
        };

        tracing::debug!(
            "File descriptor limit: {}, reserved: {}, available: {}, batch size: {}",
            soft_limit,
            reserved,
            available,
            optimal
        );

        Ok(optimal.try_into().unwrap())
    }
}
