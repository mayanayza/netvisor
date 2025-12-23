use crate::daemon::discovery::service::base::{
    CreatesDiscoveredEntities, DiscoversNetworkedEntities, DiscoveryRunner, RunsDiscovery,
};
use crate::daemon::discovery::types::base::{DiscoveryCriticalError, DiscoverySessionUpdate};
use crate::daemon::utils::scanner::{
    arp_scan_host, can_arp_scan, scan_endpoints, scan_tcp_ports, scan_udp_ports,
};
use crate::server::discovery::r#impl::types::{DiscoveryType, HostNamingFallback};
use crate::server::interfaces::r#impl::base::{Interface, InterfaceBase};
use crate::server::ports::r#impl::base::PortType;
use crate::server::services::r#impl::base::{Service, ServiceMatchBaselineParams};
use crate::server::subnets::r#impl::types::SubnetTypeDiscriminants;
use crate::{
    daemon::utils::base::DaemonUtils,
    server::{
        daemons::r#impl::api::DaemonDiscoveryRequest, hosts::r#impl::base::Host,
        subnets::r#impl::base::Subnet,
    },
};
use anyhow::Error;
use async_trait::async_trait;
use cidr::IpCidr;
use futures::{
    future::try_join_all,
    stream::{self, StreamExt},
};
use mac_address::MacAddress;
use std::collections::{HashMap, HashSet};
use std::result::Result::Ok;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::time::Duration;
use std::{net::IpAddr, sync::Arc};
use strum::IntoDiscriminant;
use tokio::time::timeout;
use tokio_util::sync::CancellationToken;
use uuid::Uuid;

#[derive(Default)]
pub struct NetworkScanDiscovery {
    subnet_ids: Option<Vec<Uuid>>,
    host_naming_fallback: HostNamingFallback,
}

impl NetworkScanDiscovery {
    pub fn new(subnet_ids: Option<Vec<Uuid>>, host_naming_fallback: HostNamingFallback) -> Self {
        Self {
            subnet_ids,
            host_naming_fallback,
        }
    }
}

pub struct DeepScanParams<'a> {
    ip: IpAddr,
    subnet: &'a Subnet,
    mac: Option<MacAddress>,
    phase1_ports: Vec<PortType>,
    cancel: CancellationToken,
    port_scan_batch_size: usize,
    gateway_ips: &'a [IpAddr],
    batches_done: &'a Arc<AtomicUsize>,
    total_batches: usize,
}

impl CreatesDiscoveredEntities for DiscoveryRunner<NetworkScanDiscovery> {}

#[async_trait]
impl RunsDiscovery for DiscoveryRunner<NetworkScanDiscovery> {
    fn discovery_type(&self) -> DiscoveryType {
        DiscoveryType::Network {
            subnet_ids: self.domain.subnet_ids.clone(),
            host_naming_fallback: self.domain.host_naming_fallback,
        }
    }

    async fn discover(
        &self,
        request: DaemonDiscoveryRequest,
        cancel: CancellationToken,
    ) -> Result<(), Error> {
        // Ignore docker bridge subnets, they are discovered through Docker Discovery
        let subnets: Vec<Subnet> = self.discover_create_subnets().await?;

        self.start_discovery(request).await?;

        let discovery_result = self
            .scan_and_process_hosts(subnets, cancel.clone())
            .await
            .map(|_| ());

        self.finish_discovery(discovery_result, cancel.clone())
            .await?;

        Ok(())
    }
}

#[async_trait]
impl DiscoversNetworkedEntities for DiscoveryRunner<NetworkScanDiscovery> {
    async fn get_gateway_ips(&self) -> Result<Vec<IpAddr>, Error> {
        self.as_ref()
            .utils
            .get_own_routing_table_gateway_ips()
            .await
    }

    async fn discover_create_subnets(&self) -> Result<Vec<Subnet>, Error> {
        let daemon_id = self.as_ref().config_store.get_id().await?;
        let network_id = self
            .as_ref()
            .config_store
            .get_network_id()
            .await?
            .ok_or_else(|| anyhow::anyhow!("Network ID not set"))?;

        // Target specific subnets if provided in discovery type
        let subnets = if let Some(subnet_ids) = &self.domain.subnet_ids {
            let all_subnets = self.get_subnets().await?;
            all_subnets
                .into_iter()
                .filter(|s| subnet_ids.contains(&s.id))
                .collect()

        // Target all interfaced subnets if not
        } else {
            let (_, subnets, _) = self
                .as_ref()
                .utils
                .get_own_interfaces(self.discovery_type(), daemon_id, network_id)
                .await?;

            // Filter out docker bridge subnets, those are handled in docker discovery
            // Filter out subnets with
            let subnets: Vec<Subnet> = subnets
                .into_iter()
                .filter(|s| {

                    if s.base.cidr.network_length() < 10 {
                        tracing::warn!("Skipping {} with CIDR {}, scanning would take too long", s.base.name, s.base.cidr);
                        return false
                    }

                    if s.base.subnet_type.discriminant() == SubnetTypeDiscriminants::DockerBridge {
                        tracing::warn!("Skipping {} with CIDR {}, docker bridge subnets are scanning in docker discovery", s.base.name, s.base.cidr);
                        return false
                    }

                    true
                })
                .collect();
            let subnet_futures = subnets.iter().map(|subnet| self.create_subnet(subnet));
            try_join_all(subnet_futures).await?
        };

        Ok(subnets)
    }
}

impl DiscoveryRunner<NetworkScanDiscovery> {
    async fn scan_and_process_hosts(
        &self,
        subnets: Vec<Subnet>,
        cancel: CancellationToken,
    ) -> Result<Vec<Host>, Error> {
        let session = self.as_ref().get_session().await?;

        let (_, _, subnet_cidr_to_mac) = self
            .as_ref()
            .utils
            .get_own_interfaces(
                self.discovery_type(),
                session.info.daemon_id,
                session.info.network_id,
            )
            .await?;

        let all_ips_with_subnets: Vec<(IpAddr, Subnet)> = subnets
            .iter()
            .flat_map(|subnet| {
                self.determine_scan_order(&subnet.base.cidr)
                    .map(move |ip| (ip, subnet.clone()))
            })
            .collect();

        let total_ips = all_ips_with_subnets.len();

        // Pre-compute values used in streams
        let daemon_ip = self.as_ref().utils.get_own_ip_address()?;
        let port_scan_batch_size = self.as_ref().utils.get_optimal_port_batch_size().await?;
        let discovery_ports: Vec<u16> = Service::all_discovery_ports()
            .iter()
            .filter(|p| p.is_tcp())
            .map(|p| p.number())
            .collect();

        // Check ARP capability once before partitioning
        let arp_available = can_arp_scan();

        // Partition IPs - only use ARP path if we have capability
        let (interfaced_ips, non_interfaced_ips): (Vec<_>, Vec<_>) = if arp_available {
            all_ips_with_subnets.into_iter().partition(|(_, subnet)| {
                subnet_cidr_to_mac
                    .get(&subnet.base.cidr)
                    .and_then(|m| *m)
                    .is_some()
            })
        } else {
            // No ARP capability - treat all as non-interfaced (port scan only)
            (Vec::new(), all_ips_with_subnets)
        };

        // =============================================================
        // PHASE 1: Responsiveness check (0-50%)
        // =============================================================
        tracing::info!(
            total_ips = total_ips,
            interfaced_ips = interfaced_ips.len(),
            non_interfaced_ips = non_interfaced_ips.len(),
            "Phase 1: Checking host responsiveness"
        );

        self.report_discovery_update(DiscoverySessionUpdate::scanning(0))
            .await?;

        let phase1_scanned = Arc::new(AtomicUsize::new(0));
        let mut responsive_hosts: Vec<(IpAddr, Subnet, Option<MacAddress>, Vec<PortType>)> =
            Vec::new();

        // Process interfaced subnets with ARP
        if !interfaced_ips.is_empty() {
            let arp_concurrency = self.as_ref().utils.get_optimal_arp_concurrency()?;

            tracing::info!(
                count = interfaced_ips.len(),
                concurrency = arp_concurrency,
                "Phase 1a: ARP scanning interfaced subnets"
            );

            let subnet_cidr_to_mac_clone = subnet_cidr_to_mac.clone();
            let arp_responsive: Vec<_> = stream::iter(interfaced_ips)
            .map(|(ip, subnet)| {
                let cancel = cancel.clone();
                let phase1_scanned = phase1_scanned.clone();
                let subnet_mac = subnet_cidr_to_mac_clone.get(&subnet.base.cidr).and_then(|m| *m);

                async move {
                    let result = self
                        .check_host_responsive_arp(ip, subnet_mac.unwrap(), daemon_ip, cancel)
                        .await;

                    let scanned = phase1_scanned.fetch_add(1, Ordering::Relaxed) + 1;
                    let pct = (scanned * 50 / total_ips.max(1)) as u8;
                    let _ = self.report_scanning_progress(pct).await;

                    match result {
                        Ok(Some(mac)) => Some((ip, subnet, Some(mac), Vec::new())),
                        Ok(None) => None,
                        Err(e) => {
                            if DiscoveryCriticalError::is_critical_error(e.to_string()) {
                                tracing::error!(ip = %ip, error = %e, "Critical error in ARP check");
                            } else {
                                tracing::trace!(ip = %ip, error = %e, "ARP check failed");
                            }
                            None
                        }
                    }
                }
            })
            .buffer_unordered(arp_concurrency)
            .filter_map(|x| async { x })
            .collect()
            .await;

            if cancel.is_cancelled() {
                return Err(Error::msg("Discovery session was cancelled"));
            }

            responsive_hosts.extend(arp_responsive);
        }

        // Process non-interfaced subnets with port scanning
        if !non_interfaced_ips.is_empty() {
            let configured = self.as_ref().config_store.get_concurrent_scans().await?;
            let port_concurrency = self
                .as_ref()
                .utils
                .get_optimal_concurrent_scans(configured)
                .await?;

            tracing::info!(
                count = non_interfaced_ips.len(),
                concurrency = port_concurrency,
                "Phase 1b: Port scanning non-interfaced subnets"
            );

            let port_responsive: Vec<_> = stream::iter(non_interfaced_ips)
            .map(|(ip, subnet)| {
                let cancel = cancel.clone();
                let phase1_scanned = phase1_scanned.clone();
                let discovery_ports = discovery_ports.clone();

                async move {
                    let result = self
                        .check_host_responsive_ports(ip, &discovery_ports, port_scan_batch_size, cancel)
                        .await;

                    let scanned = phase1_scanned.fetch_add(1, Ordering::Relaxed) + 1;
                    let pct = (scanned * 50 / total_ips.max(1)) as u8;
                    let _ = self.report_scanning_progress(pct).await;

                    match result {
                        Ok(Some(discovered_ports)) => Some((ip, subnet, None, discovered_ports)),
                        Ok(None) => None,
                        Err(e) => {
                            if DiscoveryCriticalError::is_critical_error(e.to_string()) {
                                tracing::error!(ip = %ip, error = %e, "Critical error in port check");
                            } else {
                                tracing::trace!(ip = %ip, error = %e, "Port check failed");
                            }
                            None
                        }
                    }
                }
            })
            .buffer_unordered(port_concurrency)
            .filter_map(|x| async { x })
            .collect()
            .await;

            if cancel.is_cancelled() {
                return Err(Error::msg("Discovery session was cancelled"));
            }

            responsive_hosts.extend(port_responsive);
        }

        self.report_discovery_update(DiscoverySessionUpdate::scanning(50))
            .await?;

        tracing::info!(
            responsive = responsive_hosts.len(),
            total_ips = total_ips,
            "Phase 1 complete"
        );

        if responsive_hosts.is_empty() {
            self.report_discovery_update(DiscoverySessionUpdate::scanning(100))
                .await?;
            tracing::info!("No responsive hosts found, skipping Phase 2");
            return Ok(Vec::new());
        }

        // =============================================================
        // PHASE 2: Deep scan responsive hosts (50-100%)
        // =============================================================
        let ports_per_host_batch = 200;
        let deep_scan_concurrency = self
            .as_ref()
            .utils
            .get_optimal_deep_scan_concurrency(ports_per_host_batch)?;

        let responsive_count = responsive_hosts.len();
        let batches_per_host = 65535_usize.div_ceil(ports_per_host_batch);
        let total_batches = responsive_count * batches_per_host;

        tracing::info!(
            responsive_hosts = responsive_count,
            ports_per_host_batch = ports_per_host_batch,
            deep_scan_concurrency = deep_scan_concurrency,
            total_batches = total_batches,
            "Phase 2: Deep scanning responsive hosts"
        );

        let gateway_ips = self
            .as_ref()
            .utils
            .get_own_routing_table_gateway_ips()
            .await?;

        let phase2_batches_done = Arc::new(AtomicUsize::new(0));

        // In scan_and_process_hosts, box the deep scan futures
        let results = stream::iter(responsive_hosts)
    .map(|(ip, subnet, mac, phase1_ports)| {
        let cancel = cancel.clone();
        let gateway_ips = gateway_ips.clone();
        let batches_done = phase2_batches_done.clone();

        Box::pin(async move {
            let result = self
                .deep_scan_host(DeepScanParams {
                    ip,
                    subnet: &subnet,
                    mac,
                    phase1_ports,
                    cancel,
                    port_scan_batch_size: ports_per_host_batch,
                    gateway_ips: &gateway_ips,
                    batches_done: &batches_done,
                    total_batches,
                })
                .await;

            match result {
                Ok(Some(host)) => Some(host),
                Ok(None) => None,
                Err(e) => {
                    if DiscoveryCriticalError::is_critical_error(e.to_string()) {
                        tracing::error!(ip = %ip, error = %e, "Critical error in deep scan");
                    } else {
                        tracing::warn!(ip = %ip, error = %e, "Deep scan failed");
                    }
                    None
                }
            }
        })
    })
    .buffer_unordered(deep_scan_concurrency)
    .filter_map(|x| async { x })
    .collect::<Vec<Host>>()
    .await;

        self.report_discovery_update(DiscoverySessionUpdate::scanning(100))
            .await?;

        tracing::info!(
            discovered = results.len(),
            responsive = responsive_count,
            "Phase 2 complete"
        );

        Ok(results)
    }

    async fn check_host_responsive_arp(
        &self,
        ip: IpAddr,
        subnet_mac: MacAddress,
        daemon_ip: IpAddr,
        cancel: CancellationToken,
    ) -> Result<Option<MacAddress>, Error> {
        if cancel.is_cancelled() {
            return Err(Error::msg("Discovery was cancelled"));
        }

        let mac = arp_scan_host(&subnet_mac, daemon_ip, ip).await?;

        if mac.is_some() {
            tracing::debug!(ip = %ip, mac = ?mac, "Host responsive (ARP)");
        } else {
            tracing::trace!(ip = %ip, "Host not responsive (ARP timeout)");
        }

        Ok(mac)
    }

    async fn check_host_responsive_ports(
        &self,
        ip: IpAddr,
        discovery_ports: &[u16],
        port_scan_batch_size: usize,
        cancel: CancellationToken,
    ) -> Result<Option<Vec<PortType>>, Error> {
        if cancel.is_cancelled() {
            return Err(Error::msg("Discovery was cancelled"));
        }

        let open_ports =
            scan_tcp_ports(ip, cancel, port_scan_batch_size, discovery_ports.to_vec()).await?;

        if !open_ports.is_empty() {
            let discovered_ports: Vec<PortType> = open_ports.iter().map(|(p, _)| *p).collect();
            tracing::debug!(ip = %ip, open_ports = discovered_ports.len(), "Host responsive (TCP)");
            Ok(Some(discovered_ports))
        } else {
            tracing::trace!(ip = %ip, "Host not responsive (no discovery ports open)");
            Ok(None)
        }
    }

    async fn deep_scan_host(&self, params: DeepScanParams<'_>) -> Result<Option<Host>, Error> {
        let DeepScanParams {
            ip,
            subnet,
            mac,
            phase1_ports,
            cancel,
            port_scan_batch_size,
            gateway_ips,
            batches_done,
            total_batches,
        } = params;

        if cancel.is_cancelled() {
            return Err(Error::msg("Discovery was cancelled"));
        }

        let phase1_port_nums: HashSet<u16> = phase1_ports.iter().map(|p| p.number()).collect();
        let remaining_tcp_ports: Vec<u16> = (1..=65535)
            .filter(|p| !phase1_port_nums.contains(p))
            .collect();

        tracing::debug!(
            ip = %ip,
            phase1_ports = phase1_ports.len(),
            remaining_ports = remaining_tcp_ports.len(),
            "Starting deep scan"
        );

        // Scan in batches, reporting progress after each
        let mut all_tcp_ports = Vec::new();
        for chunk in remaining_tcp_ports.chunks(port_scan_batch_size) {
            if cancel.is_cancelled() {
                return Err(Error::msg("Discovery was cancelled"));
            }

            let open_ports =
                scan_tcp_ports(ip, cancel.clone(), port_scan_batch_size, chunk.to_vec()).await?;
            all_tcp_ports.extend(open_ports);

            let done = batches_done.fetch_add(1, Ordering::Relaxed) + 1;
            let pct = (50 + done * 40 / total_batches.max(1)) as u8; // 50-90%
            let _ = self.report_scanning_progress(pct).await;
        }

        let use_https_ports: HashMap<u16, bool> = all_tcp_ports
            .iter()
            .map(|(p, h)| (p.number(), *h))
            .collect();
        let mut open_ports: Vec<PortType> = all_tcp_ports.iter().map(|(p, _)| *p).collect();

        // Merge phase 1 discovered ports
        open_ports.extend(phase1_ports);
        open_ports.sort_by_key(|p| (p.number(), p.protocol()));
        open_ports.dedup();

        // UDP and endpoint scanning
        let udp_ports = scan_udp_ports(
            ip,
            cancel.clone(),
            port_scan_batch_size,
            subnet.base.cidr,
            gateway_ips.to_vec(),
        )
        .await?;
        open_ports.extend(udp_ports);

        self.report_discovery_update(DiscoverySessionUpdate::scanning(95))
            .await?;

        let mut ports_to_check = open_ports.clone();
        let endpoint_only_ports = Service::endpoint_only_ports();
        ports_to_check.extend(endpoint_only_ports);
        ports_to_check.sort_by_key(|p| (p.number(), p.protocol()));
        ports_to_check.dedup();

        let endpoint_responses = scan_endpoints(
            ip,
            cancel.clone(),
            Some(ports_to_check),
            Some(use_https_ports),
            port_scan_batch_size,
        )
        .await?;

        self.report_discovery_update(DiscoverySessionUpdate::scanning(98))
            .await?;

        for endpoint_response in &endpoint_responses {
            let port = endpoint_response.endpoint.port_type;
            if !open_ports.contains(&port) {
                open_ports.push(port);
            }
        }

        open_ports.sort_by_key(|p| (p.number(), p.protocol()));
        open_ports.dedup();

        if cancel.is_cancelled() {
            return Err(Error::msg("Discovery was cancelled"));
        }

        tracing::info!(
            ip = %ip,
            open_ports = open_ports.len(),
            endpoints = endpoint_responses.len(),
            "Deep scan complete"
        );

        let hostname = self.get_hostname_for_ip(ip).await?;

        let interface = Interface::new(InterfaceBase {
            network_id: subnet.base.network_id,
            host_id: Uuid::nil(), // Placeholder - server will set correct host_id
            name: None,
            subnet_id: subnet.id,
            ip_address: ip,
            mac_address: mac,
        });

        if let Ok(Some((host, interfaces, ports, services))) = self
            .process_host(
                ServiceMatchBaselineParams {
                    subnet,
                    interface: &interface,
                    all_ports: &open_ports,
                    endpoint_responses: &endpoint_responses,
                    virtualization: &None,
                },
                hostname,
                self.domain.host_naming_fallback,
            )
            .await
        {
            let services_count = services.len();

            if let Ok(host_response) = self.create_host(host, interfaces, ports, services).await {
                tracing::info!(
                    ip = %ip,
                    services = services_count,
                    "Host created"
                );
                return Ok(Some(host_response.to_host()));
            } else {
                tracing::warn!(ip = %ip, "Host creation failed");
            }
        } else {
            tracing::debug!(ip = %ip, "Host processing returned None");
        }

        Ok(None)
    }

    async fn get_hostname_for_ip(&self, ip: IpAddr) -> Result<Option<String>, Error> {
        match timeout(Duration::from_millis(800), async {
            tokio::task::spawn_blocking(move || dns_lookup::lookup_addr(&ip)).await?
        })
        .await
        {
            Ok(Ok(hostname)) => Ok(Some(hostname)),
            _ => Ok(None),
        }
    }

    /// Figure out what order to scan IPs in given allocation patterns
    fn determine_scan_order(&self, subnet: &IpCidr) -> impl Iterator<Item = IpAddr> {
        let mut ips: Vec<IpAddr> = subnet.iter().map(|ip| ip.address()).collect();

        // Sort by likelihood of being active hosts - highest probability first
        ips.sort_by_key(|ip| {
            let last_octet = match ip {
                IpAddr::V4(ipv4) => ipv4.octets()[3],
                IpAddr::V6(_) => return 9999, // IPv6 gets lowest priority for now
            };

            match last_octet {
                // Tier 1: Almost guaranteed to be active infrastructure
                1 => 1,   // Default gateway (.1)
                254 => 2, // Alternative gateway (.254)

                // Tier 2: Very common infrastructure and static assignments
                2 => 10,   // Secondary router/switch
                3 => 11,   // Tertiary infrastructure
                10 => 12,  // Common DHCP start
                100 => 13, // Common DHCP end
                253 => 14, // Alt gateway range
                252 => 15, // Alt gateway range

                // Tier 3: Common static device ranges
                4..=9 => 20 + last_octet as u16, // Infrastructure devices
                11..=20 => 30 + last_octet as u16, // Servers, printers
                21..=30 => 50 + last_octet as u16, // Network devices

                // Tier 4: Active DHCP ranges (most devices live here)
                31..=50 => 100 + last_octet as u16, // Early DHCP range
                51..=100 => 200 + last_octet as u16, // Mid DHCP range
                101..=150 => 400 + last_octet as u16, // Late DHCP range

                // Tier 5: Less common but still viable
                151..=200 => 600 + last_octet as u16, // Extended DHCP
                201..=251 => 800 + last_octet as u16, // High static range

                // Skip entirely - reserved addresses
                0 | 255 => 9998, // Network/broadcast addresses
            }
        });

        ips.into_iter()
    }

    async fn get_subnets(&self) -> Result<Vec<Subnet>, Error> {
        self.as_ref()
            .api_client
            .get("/api/subnets", "Failed to get subnets")
            .await
    }
}
