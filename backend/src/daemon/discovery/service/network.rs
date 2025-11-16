use crate::daemon::discovery::service::base::{
    CreatesDiscoveredEntities, DiscoversNetworkedEntities, DiscoveryRunner, RunsDiscovery,
};
use crate::daemon::discovery::types::base::{DiscoveryCriticalError, DiscoverySessionUpdate};
use crate::daemon::utils::scanner::scan_ports_and_endpoints;
use crate::server::discovery::r#impl::types::{DiscoveryType, HostNamingFallback};
use crate::server::hosts::r#impl::{
    interfaces::{Interface, InterfaceBase},
    ports::PortBase,
};
use crate::server::services::r#impl::base::ServiceMatchBaselineParams;
use crate::server::shared::types::api::ApiResponse;
use crate::server::subnets::r#impl::types::{SubnetType, SubnetTypeDiscriminants};
use crate::{
    daemon::utils::base::DaemonUtils,
    server::{
        daemons::r#impl::api::DaemonDiscoveryRequest, hosts::r#impl::base::Host,
        services::r#impl::endpoints::EndpointResponse, subnets::r#impl::base::Subnet,
    },
};
use anyhow::Error;
use async_trait::async_trait;
use cidr::IpCidr;
use futures::{
    future::try_join_all,
    stream::{self, StreamExt},
};
use std::result::Result::Ok;
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

impl CreatesDiscoveredEntities for DiscoveryRunner<NetworkScanDiscovery> {}

#[async_trait]
impl RunsDiscovery for DiscoveryRunner<NetworkScanDiscovery> {
    fn discovery_type(&self) -> DiscoveryType {
        DiscoveryType::Network {
            subnet_ids: None,
            host_naming_fallback: HostNamingFallback::BestService,
        }
    }

    async fn discover(
        &self,
        request: DaemonDiscoveryRequest,
        cancel: CancellationToken,
    ) -> Result<(), Error> {
        // Ignore docker bridge subnets, they are discovered through Docker Discovery
        let subnets: Vec<Subnet> = self.discover_create_subnets().await?;

        let total_ips_across_subnets: usize = subnets
            .iter()
            .map(|subnet| subnet.base.cidr.iter().count())
            .sum();

        self.start_discovery(total_ips_across_subnets, request)
            .await?;

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
            let (_, subnets) = self
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
    /// Scan subnet concurrently and process hosts immediately as they're discovered
    async fn scan_and_process_hosts(
        &self,
        subnets: Vec<Subnet>,
        cancel: CancellationToken,
    ) -> Result<Vec<Host>, Error> {
        let configured_concurrent_scans = self.as_ref().config_store.get_concurrent_scans().await?;
        let concurrent_scans = self
            .as_ref()
            .utils
            .get_optimal_concurrent_scans(configured_concurrent_scans)
            .await?;

        tracing::info!(
            "🔍 Starting scan with concurrent_scans={}",
            concurrent_scans
        );

        let session = self.as_ref().get_session().await?;
        let scanned_count = session.processed_count.clone();

        self.report_discovery_update(DiscoverySessionUpdate::scanning(0))
            .await?;

        let all_ips_with_subnets: Vec<(IpAddr, Subnet)> = subnets
            .iter()
            .flat_map(|subnet| {
                self.determine_scan_order(&subnet.base.cidr)
                    .map(move |ip| (ip, subnet.clone()))
            })
            .collect();

        let total_ips = all_ips_with_subnets.len();
        tracing::info!("📋 Total IPs to scan: {}", total_ips);

        let results = stream::iter(all_ips_with_subnets)
            .map(|(ip, subnet)| {
                let cancel = cancel.clone();
                let subnet = subnet.clone();
                let scanned_count = scanned_count.clone();

                async move {
                    match self
                        .scan_host(ip, scanned_count, cancel, subnet.base.cidr)
                        .await
                    {
                        Ok(None) => {
                            tracing::trace!("Host {} - no ports/endpoints found", ip);
                            Ok(None)
                        }
                        Err(e) => {
                            tracing::warn!(
                                ip = %ip,
                                error = %e,
                                phase = "port_endpoint_scan",
                                "Scan error"
                            );
                            Err(e)
                        }
                        Ok(Some((all_ports, endpoint_responses))) => {
                            tracing::debug!(
                                "Host {} - found {} ports, {} endpoints",
                                ip,
                                all_ports.len(),
                                endpoint_responses.len()
                            );

                            let hostname = self.get_hostname_for_ip(ip).await?;
                            let mac = match subnet.base.subnet_type {
                                SubnetType::VpnTunnel => None,
                                _ => self.as_ref().utils.get_mac_address_for_ip(ip).await?,
                            };

                            let interface = Interface::new(InterfaceBase {
                                name: None,
                                subnet_id: subnet.id,
                                ip_address: ip,
                                mac_address: mac,
                            });

                            if let Ok(Some((host, services))) = self
                                .process_host(
                                    ServiceMatchBaselineParams {
                                        subnet: &subnet,
                                        interface: &interface,
                                        all_ports: &all_ports,
                                        endpoint_responses: &endpoint_responses,
                                        virtualization: &None,
                                    },
                                    hostname,
                                    self.domain.host_naming_fallback,
                                )
                                .await
                            {
                                tracing::info!(
                                    "✓ Host {} - processed, {} services matched",
                                    ip,
                                    services.len()
                                );

                                if let Ok((created_host, _)) =
                                    self.create_host(host, services).await
                                {
                                    tracing::info!("✓ Host {} - created successfully", ip);
                                    return Ok::<Option<Host>, Error>(Some(created_host));
                                } else {
                                    tracing::warn!("✗ Host {} - failed to create in database", ip);
                                }
                            } else {
                                tracing::debug!(
        ip = %ip,
        "Host processing returned None - no services matched or error occurred"
    );
                            }
                            Ok(None)
                        }
                    }
                }
            })
            .buffer_unordered(concurrent_scans);

        let mut stream_pin = Box::pin(results);
        let mut last_reported_processed_count: usize = 0;
        let mut successful_discoveries = Vec::new();
        let mut scanned = 0;

        while let Some(result) = stream_pin.next().await {
            scanned += 1;

            if cancel.is_cancelled() {
                tracing::warn!("Discovery session was cancelled");
                return Err(Error::msg("Discovery session was cancelled"));
            }

            match result {
                Ok(Some(host)) => successful_discoveries.push(host),
                Ok(None) => {}
                Err(e) => {
                    if DiscoveryCriticalError::is_critical_error(e.to_string()) {
                        return Err(e);
                    } else {
                        tracing::warn!(
                            error = %e,
                            phase = "scan_and_process",
                            "Host scan/processing error"
                        );
                    }
                }
            }

            last_reported_processed_count = self
                .periodic_scan_update(last_reported_processed_count)
                .await?;
        }

        tracing::warn!(
            total_ips = %total_ips,
            scanned = %scanned,
            discovered = %successful_discoveries.len(),
            "📊 Scan complete"
        );

        Ok(successful_discoveries)
    }

    pub async fn scan_host(
        &self,
        ip: IpAddr,
        scanned_count: Arc<std::sync::atomic::AtomicUsize>,
        cancel: CancellationToken,
        cidr: IpCidr,
    ) -> Result<Option<(Vec<PortBase>, Vec<EndpointResponse>)>, Error> {
        // Check cancellation at the start
        if cancel.is_cancelled() {
            return Err(Error::msg("Discovery was cancelled"));
        }

        let port_scan_batch_size = self.as_ref().utils.get_optimal_port_batch_size().await?;

        let gateway_ips = self
            .as_ref()
            .utils
            .get_own_routing_table_gateway_ips()
            .await?;

        // Scan ports and endpoints
        let scan_result =
            scan_ports_and_endpoints(ip, cancel.clone(), port_scan_batch_size, cidr, gateway_ips)
                .await
                .map_err(|e| anyhow::anyhow!("Scan task panicked: {}", e));

        // Check cancellation after network operation
        if cancel.is_cancelled() {
            scanned_count.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
            return Err(Error::msg("Discovery was cancelled"));
        }

        match scan_result {
            Ok((open_ports, endpoint_responses)) => {
                if !open_ports.is_empty() || !endpoint_responses.is_empty() {
                    tracing::info!(
                        "Processing host {} with {} open ports and {} endpoint responses",
                        ip,
                        open_ports.len(),
                        endpoint_responses.len()
                    );

                    // Check cancellation before processing
                    if cancel.is_cancelled() {
                        scanned_count.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
                        return Err(Error::msg("Discovery was cancelled"));
                    }

                    Ok(Some((open_ports, endpoint_responses)))
                } else {
                    tracing::debug!("No open ports found on {}", ip);
                    scanned_count.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
                    Ok(None)
                }
            }
            Err(e) => {
                tracing::warn!(
                    ip = %ip,
                    error = %e,
                    "Host scan failed"
                );

                if DiscoveryCriticalError::is_critical_error(e.to_string()) {
                    Err(e)
                } else {
                    scanned_count.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
                    Ok(None)
                }
            }
        }
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
        let server_target = self.as_ref().config_store.get_server_endpoint().await?;

        let api_key = self
            .as_ref()
            .config_store
            .get_api_key()
            .await?
            .ok_or_else(|| anyhow::anyhow!("API key not set"))?;

        let response = self
            .as_ref()
            .client
            .get(format!("{}/api/subnets", server_target))
            .header("Authorization", format!("Bearer {}", api_key))
            .send()
            .await?;

        if !response.status().is_success() {
            anyhow::bail!(
                "Failed to report discovered subnet: HTTP {}",
                response.status(),
            );
        }

        let api_response: ApiResponse<Vec<Subnet>> = response.json().await?;

        if !api_response.success {
            let error_msg = api_response
                .error
                .unwrap_or_else(|| "Unknown error".to_string());
            anyhow::bail!("Failed to create subnet: {}", error_msg);
        }

        let subnets = api_response
            .data
            .ok_or_else(|| anyhow::anyhow!("No subnet data in successful response"))?;

        Ok(subnets)
    }
}
