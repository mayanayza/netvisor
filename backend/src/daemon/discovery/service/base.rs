use std::{
    net::IpAddr,
    sync::{Arc, atomic::AtomicUsize},
    time::Duration,
};

use crate::server::hosts::types::ports::TransportProtocol;
use crate::server::services::types::endpoints::Endpoint;
use crate::{
    daemon::discovery::{
        manager::DaemonDiscoverySessionManager, types::base::DiscoveryCriticalError,
    },
    server::{
        discovery::types::{
            api::InitiateDiscoveryRequest,
            base::{DiscoveryMetadata, DiscoveryType},
        },
        groups::types::Group,
        services::types::{
            base::{
                DiscoverySessionServiceMatchParams, ServiceMatchBaselineParams,
                ServiceMatchServiceParams,
            },
            endpoints::EndpointResponse,
            patterns::MatchConfidence,
        },
    },
};
use anyhow::{Error, anyhow};
use async_trait::async_trait;
use chrono::Utc;
use dhcproto::v4::{self, Decodable, Encodable, Encoder, Message, MessageType};
use rand::{Rng, SeedableRng};
use rsntp::AsyncSntpClient;
use snmp2::{AsyncSession, Oid};
use std::net::SocketAddr;
use tokio::{net::TcpStream, sync::RwLock, time::timeout};
use tokio_util::sync::CancellationToken;

use tokio::net::UdpSocket;

use trust_dns_resolver::TokioAsyncResolver;
use trust_dns_resolver::config::{NameServerConfig, Protocol, ResolverConfig, ResolverOpts};
use uuid::Uuid;

use crate::{
    daemon::{
        discovery::types::base::{DiscoveryPhase, DiscoverySessionInfo, DiscoverySessionUpdate},
        shared::storage::ConfigStore,
        utils::base::{PlatformDaemonUtils, create_system_utils},
    },
    server::{
        daemons::types::api::{DaemonDiscoveryRequest, DiscoveryUpdatePayload},
        discovery::types::base::EntitySource,
        hosts::types::{
            api::HostWithServicesRequest,
            base::{Host, HostBase},
            ports::{Port, PortBase},
            targets::HostTarget,
        },
        services::{
            definitions::{ServiceDefinitionRegistry, gateway::Gateway},
            types::{
                base::Service,
                bindings::Binding,
                definitions::{ServiceDefinition, ServiceDefinitionExt},
            },
        },
        shared::types::{api::ApiResponse, metadata::HasId},
        subnets::types::base::Subnet,
    },
};

pub const SCAN_TIMEOUT: Duration = Duration::from_millis(800);

pub trait HasDiscoveryType {
    fn discovery_type(&self) -> DiscoveryType;
}

pub struct Discovery<T> {
    pub service: Arc<DaemonDiscoveryService>,
    pub manager: Arc<DaemonDiscoverySessionManager>,
    pub domain: T,
}

impl<T> Discovery<T> {
    pub fn new(
        service: Arc<DaemonDiscoveryService>,
        manager: Arc<DaemonDiscoverySessionManager>,
        domain: T,
    ) -> Self {
        Self {
            service,
            domain,
            manager,
        }
    }
}

impl<T> Discovery<T>
where
    T: 'static,
    Self: DiscoversNetworkedEntities,
{
    pub async fn discover_on_network(
        self: Arc<Self>,
        request: DaemonDiscoveryRequest,
    ) -> Result<(), Error> {
        if self.manager.is_discovery_running().await {
            Err(anyhow!("Discovery session already running"))
        } else {
            let cancel_token = self.manager.start_new_session().await;

            let handler = self.clone();
            let request_clone = request.clone();

            let inner_manager = self.manager.clone();
            let handle = tokio::spawn(async move {
                match handler
                    .start_discovery_session(request_clone, cancel_token)
                    .await
                {
                    Ok(()) => {
                        tracing::info!("Discovery completed successfully");
                    }
                    Err(e) => {
                        tracing::error!("Discovery failed: {}", e);
                    }
                }
                inner_manager.clear_completed_task().await;
            });
            self.manager.set_current_task(handle).await;

            // Return immediate acknowledgment
            Ok(())
        }
    }

    pub async fn scan_ports_and_endpoints(
        ip: IpAddr,
        cancel: CancellationToken,
        filter_endpoint_ports: Option<Vec<PortBase>>,
    ) -> Result<(Vec<PortBase>, Vec<EndpointResponse>), Error> {
        if cancel.is_cancelled() {
            return Err(anyhow!("Operation cancelled"));
        }

        let mut open_ports = Vec::new();
        let mut endpoint_responses = Vec::new();

        // Scan TCP ports sequentially (not concurrently)
        let tcp_ports = Self::scan_tcp_ports(ip, cancel.clone()).await?;
        open_ports.extend(tcp_ports);

        if cancel.is_cancelled() {
            return Err(anyhow!("Operation cancelled"));
        }

        // Scan UDP ports sequentially
        let udp_ports = Self::scan_udp_ports(ip, cancel.clone()).await?;
        open_ports.extend(udp_ports);

        if cancel.is_cancelled() {
            return Err(anyhow!("Operation cancelled"));
        }

        // Scan endpoints sequentially
        let endpoints = Self::scan_endpoints(ip, cancel.clone(), filter_endpoint_ports).await?;
        endpoint_responses.extend(endpoints);

        tracing::debug!(
            "Scan results for {}: found {} open ports, {} endpoint responses",
            ip,
            open_ports.len(),
            endpoint_responses.len()
        );

        Ok((open_ports, endpoint_responses))
    }

    pub async fn scan_tcp_ports(
        ip: IpAddr,
        cancel: CancellationToken,
    ) -> Result<Vec<PortBase>, Error> {
        let discovery_ports = Service::all_discovery_ports();
        let ports: Vec<u16> = discovery_ports
            .iter()
            .filter(|p| p.protocol() == TransportProtocol::Tcp)
            .map(|p| p.number())
            .collect();
        let mut open_ports = Vec::new();

        for port in ports {
            if cancel.is_cancelled() {
                break;
            }

            match timeout(SCAN_TIMEOUT, TcpStream::connect((ip, port))).await {
                Ok(Ok(_)) => {
                    open_ports.push(PortBase::new_tcp(port));
                    tracing::debug!("Found open TCP port {}:{}", ip, port);
                }
                Ok(Err(e)) => {
                    if DiscoveryCriticalError::is_critical_error(e.to_string()) {
                        return Err(e.into());
                    }
                }
                Err(_) => {
                    // Timeout - normal for closed/filtered ports
                }
            }
        }

        Ok(open_ports)
    }

    pub async fn scan_udp_ports(
        ip: IpAddr,
        cancel: CancellationToken,
    ) -> Result<Vec<PortBase>, anyhow::Error> {
        let discovery_ports = Service::all_discovery_ports();
        let ports: Vec<u16> = discovery_ports
            .iter()
            .filter(|p| p.protocol() == TransportProtocol::Udp)
            .map(|p| p.number())
            .collect();

        let mut open_ports = Vec::new();

        for port in ports {
            if cancel.is_cancelled() {
                break;
            }

            let result = match port {
                53 => Self::test_dns_service(ip).await,
                123 => Self::test_ntp_service(ip).await,
                161 => Self::test_snmp_service(ip).await,
                67 => Self::test_dhcp_service(ip).await,
                _ => Ok(None),
            };

            match result {
                Ok(Some(detected_port)) => {
                    open_ports.push(PortBase::new_udp(detected_port));
                    tracing::debug!("Found open UDP port {}:{}", ip, detected_port);
                }
                Ok(None) => {
                    // Port closed or no response
                }
                Err(e) => {
                    if DiscoveryCriticalError::is_critical_error(e.to_string()) {
                        return Err(e);
                    }
                }
            }
        }

        Ok(open_ports)
    }

    pub async fn scan_endpoints(
        ip: IpAddr,
        cancel: CancellationToken,
        filter_ports: Option<Vec<PortBase>>,
    ) -> Result<Vec<EndpointResponse>, Error> {
        use std::collections::HashMap;

        let client = reqwest::Client::builder()
            .timeout(SCAN_TIMEOUT)
            .build()
            .map_err(|e| anyhow!("Could not build client {}", e))?;

        let all_endpoints: Vec<Endpoint> = Service::all_discovery_endpoints()
            .into_iter()
            .filter_map(|e| {
                if let Some(filter_ports) = &filter_ports {
                    if filter_ports.contains(&e.port_base) {
                        return Some(e);
                    }
                    None
                } else {
                    Some(e)
                }
            })
            .collect();

        // Group endpoints by (port, path) to avoid duplicate requests
        let mut unique_endpoints: HashMap<(u16, String), Endpoint> = HashMap::new();
        for endpoint in all_endpoints {
            let key = (endpoint.port_base.number(), endpoint.path.clone());
            unique_endpoints.entry(key).or_insert(endpoint);
        }

        let mut responses = Vec::new();

        // Only make one request per unique (port, path) combination
        for ((_, _), endpoint) in unique_endpoints {
            if cancel.is_cancelled() {
                break;
            }

            let endpoint_with_ip = endpoint.use_ip(ip);
            let url = endpoint_with_ip.to_string();

            match client.get(&url).send().await {
                Ok(response) if response.status().is_success() => {
                    if let Ok(text) = response.text().await {
                        // Return single response that can be checked by all patterns
                        responses.push(EndpointResponse {
                            endpoint: endpoint_with_ip,
                            response: text,
                        });
                    }
                }
                Ok(_) => (),
                Err(e) => {
                    if DiscoveryCriticalError::is_critical_error(e.to_string()) {
                        return Err(e.into());
                    }
                }
            }
        }

        Ok(responses)
    }

    // Use simpler DNS resolver that doesn't have API issues
    pub async fn test_dns_service(ip: IpAddr) -> Result<Option<u16>, Error> {
        // Use the simpler approach - create resolver with custom config directly
        let mut config = ResolverConfig::new();
        let name_server = NameServerConfig::new(SocketAddr::new(ip, 53), Protocol::Udp);
        config.add_name_server(name_server);

        let test_resolver = TokioAsyncResolver::tokio(config, ResolverOpts::default());

        match timeout(
            Duration::from_millis(2000),
            test_resolver.lookup_ip("google.com"),
        )
        .await
        {
            Ok(Ok(_)) => {
                tracing::debug!("DNS server responding at {}:53", ip);
                Ok(Some(53))
            }
            _ => {
                tracing::debug!("DNS server not responding at {}:53", ip);
                Ok(None)
            }
        }
    }

    pub async fn test_ntp_service(ip: IpAddr) -> Result<Option<u16>, Error> {
        let client = AsyncSntpClient::new();
        let server_addr = format!("{}:123", ip);

        match timeout(
            Duration::from_millis(2000),
            client.synchronize(&server_addr),
        )
        .await
        {
            Ok(Ok(result)) => {
                // Validate that we got a meaningful time response
                if let Ok(datetime) = result.datetime().unix_timestamp() {
                    if datetime > Duration::from_secs(0) {
                        // Sanity check for valid timestamp
                        tracing::debug!(
                            "NTP server responding at {}:123 with time {}",
                            ip,
                            datetime.as_millis()
                        );
                        Ok(Some(123))
                    } else {
                        tracing::debug!("Invalid NTP response from {}:123", ip);
                        Ok(None)
                    }
                } else {
                    tracing::debug!("Invalid NTP response from {}:123", ip);
                    Ok(None)
                }
            }
            Ok(Err(e)) => {
                tracing::debug!("NTP error from {}:123 - {}", ip, e);
                Ok(None)
            }
            Err(_) => {
                tracing::debug!("NTP timeout from {}:123", ip);
                Ok(None)
            }
        }
    }

    pub async fn test_snmp_service(ip: IpAddr) -> Result<Option<u16>, Error> {
        let target = format!("{}:161", ip);
        let community = b"public";

        match AsyncSession::new_v2c(&target, community, 0).await {
            Ok(mut session) => {
                let sys_descr_oid = Oid::from(&[1, 3, 6, 1, 2, 1, 1, 1, 0])
                    .map_err(|e| anyhow!("Invalid Oid: {:?}", e))?;

                match timeout(Duration::from_millis(2000), session.get(&sys_descr_oid)).await {
                    Ok(Ok(mut response)) => {
                        if let Some(_varbind) = response.varbinds.next() {
                            tracing::debug!("SNMP server responding at {}:161", ip);
                            Ok(Some(161))
                        } else {
                            tracing::debug!("Empty SNMP response from {}:161", ip);
                            Ok(None)
                        }
                    }
                    Ok(Err(e)) => {
                        tracing::debug!("SNMP error from {}:161 - {}", ip, e);
                        Ok(None)
                    }
                    Err(_) => {
                        tracing::debug!("SNMP timeout from {}:161", ip);
                        Ok(None)
                    }
                }
            }
            Err(e) => {
                tracing::debug!("SNMP session creation failed for {}:161 - {}", ip, e);
                Ok(None)
            }
        }
    }

    /// Test if a host is running a DHCP server on port 67
    pub async fn test_dhcp_service(ip: IpAddr) -> Result<Option<u16>, Error> {
        let socket = UdpSocket::bind("0.0.0.0:0").await?;
        let target = SocketAddr::new(ip, 67);

        // Create a minimal DHCP DISCOVER message
        let mut rng = rand::rngs::StdRng::from_os_rng();
        let mac_addr: [u8; 6] = rng.random();
        let transaction_id = rng.random::<u32>();

        let mut msg = Message::default();
        msg.set_opcode(v4::Opcode::BootRequest)
            .set_htype(v4::HType::Eth)
            .set_xid(transaction_id)
            .set_flags(v4::Flags::default().set_broadcast())
            .set_chaddr(&mac_addr);

        msg.opts_mut()
            .insert(v4::DhcpOption::MessageType(MessageType::Discover));

        // Encode and send DHCP DISCOVER packet
        let mut buf = Vec::new();
        let mut encoder = Encoder::new(&mut buf);
        msg.encode(&mut encoder)?;
        socket.send_to(&buf, target).await?;

        // Wait for DHCP OFFER response
        let mut response_buf = [0u8; 1500];
        match timeout(
            Duration::from_millis(2000),
            socket.recv_from(&mut response_buf),
        )
        .await
        {
            Ok(Ok((len, _))) if len > 0 => {
                // Try to parse as DHCP message and validate response type
                match Message::decode(&mut dhcproto::Decoder::new(&response_buf[..len])) {
                    Ok(response_msg) => {
                        let is_valid_response = response_msg.opts().iter().any(|(_, opt)| {
                            matches!(
                                opt,
                                v4::DhcpOption::MessageType(MessageType::Offer)
                                    | v4::DhcpOption::MessageType(MessageType::Ack)
                            )
                        });

                        if is_valid_response {
                            tracing::debug!("DHCP server responding at {}:67", ip);
                            Ok(Some(67))
                        } else {
                            tracing::debug!("Invalid DHCP response from {}:67", ip);
                            Ok(None)
                        }
                    }
                    Err(_) => {
                        tracing::debug!("Failed to parse DHCP response from {}:67", ip);
                        Ok(None)
                    }
                }
            }
            _ => {
                tracing::debug!("DHCP timeout from {}:67", ip);
                Ok(None)
            }
        }
    }
}

impl<T> AsRef<DaemonDiscoveryService> for Discovery<T> {
    fn as_ref(&self) -> &DaemonDiscoveryService {
        &self.service
    }
}

#[derive(Clone)]
pub struct DiscoverySession {
    pub info: DiscoverySessionInfo,
    pub gateway_ips: Vec<IpAddr>,
    pub scanned_count: Arc<AtomicUsize>,
    pub discovered_count: Arc<AtomicUsize>,
}

impl DiscoverySession {
    pub fn new(info: DiscoverySessionInfo, gateway_ips: Vec<IpAddr>) -> Self {
        Self {
            info,
            gateway_ips,
            scanned_count: Arc::new(AtomicUsize::new(0)),
            discovered_count: Arc::new(AtomicUsize::new(0)),
        }
    }
}

pub struct DaemonDiscoveryService {
    pub config_store: Arc<ConfigStore>,
    pub client: reqwest::Client,
    pub utils: PlatformDaemonUtils,
    pub current_session: Arc<RwLock<Option<DiscoverySession>>>,
}

impl DaemonDiscoveryService {
    pub fn new(config_store: Arc<ConfigStore>) -> Self {
        Self {
            config_store,
            client: reqwest::Client::new(),
            utils: create_system_utils(),
            current_session: Arc::new(RwLock::new(None)),
        }
    }

    pub async fn get_session(&self) -> Result<DiscoverySession, Error> {
        self.current_session
            .read()
            .await
            .as_ref()
            .cloned()
            .ok_or_else(|| anyhow!("No active discovery session"))
    }
}

impl AsRef<DaemonDiscoveryService> for DaemonDiscoveryService {
    fn as_ref(&self) -> &DaemonDiscoveryService {
        self
    }
}

#[async_trait]
pub trait DiscoversNetworkedEntities:
    AsRef<DaemonDiscoveryService> + Send + Sync + HasDiscoveryType
{
    async fn get_gateway_ips(&self) -> Result<Vec<IpAddr>, Error>;

    async fn initialize_discovery_session(
        &self,
        total_to_scan: usize,
        request: DaemonDiscoveryRequest,
        daemon_id: Uuid,
    ) -> Result<(), Error> {
        tracing::debug!(
            "Setting session info for {} discovery session {}",
            request.discovery_type,
            request.session_id
        );
        let gateway_ips = self.get_gateway_ips().await?;

        let session_info = DiscoverySessionInfo {
            total_to_scan,
            session_id: request.session_id,
            daemon_id,
            started_at: Some(Utc::now()),
        };

        let session = DiscoverySession::new(session_info, gateway_ips);

        let mut current_session = self.as_ref().current_session.write().await;
        *current_session = Some(session);

        Ok(())
    }

    async fn discover_create_subnets(&self) -> Result<Vec<Subnet>, Error>;

    async fn start_discovery_session(
        &self,
        request: DaemonDiscoveryRequest,
        cancel: CancellationToken,
    ) -> Result<(), Error>;

    async fn start_discovery(
        &self,
        total_to_scan: usize,
        request: DaemonDiscoveryRequest,
    ) -> Result<(), Error> {
        let daemon_id = self.as_ref().config_store.get_id().await?;

        tracing::info!(
            "Starting {} discovery session {}",
            request.discovery_type,
            request.session_id
        );

        self.initialize_discovery_session(total_to_scan, request, daemon_id)
            .await?;

        self.report_discovery_update(DiscoverySessionUpdate {
            phase: DiscoveryPhase::Started,
            completed: 0,
            error: None,
            discovered_count: 0,
            finished_at: None,
        })
        .await?;

        Ok(())
    }

    async fn finish_discovery(
        &self,
        discovery_result: Result<(), Error>,
        cancel: CancellationToken,
    ) -> Result<(), Error> {
        let session = self.as_ref().get_session().await?;
        let session_id = session.info.session_id;

        let final_scanned_count = session
            .scanned_count
            .load(std::sync::atomic::Ordering::Relaxed);
        let final_discovered_count = session
            .discovered_count
            .load(std::sync::atomic::Ordering::Relaxed);

        match &discovery_result {
            Ok(_) => {
                tracing::info!("Discovery session {} completed successfully", session_id);
                self.report_discovery_update(DiscoverySessionUpdate {
                    phase: DiscoveryPhase::Complete,
                    completed: final_scanned_count,
                    error: None,
                    discovered_count: final_discovered_count,
                    finished_at: Some(Utc::now()),
                })
                .await?;
            }
            Err(_) if cancel.is_cancelled() => {
                tracing::warn!("Discovery session {} was cancelled", session_id);
                self.report_discovery_update(DiscoverySessionUpdate {
                    phase: DiscoveryPhase::Cancelled,
                    completed: final_scanned_count,
                    error: None,
                    discovered_count: final_discovered_count,
                    finished_at: Some(Utc::now()),
                })
                .await?;
            }
            Err(e) => {
                tracing::error!("Discovery session {} failed: {}", session_id, e);

                let error = DiscoveryCriticalError::from_error_string(e.to_string())
                    .map(|e| e.to_string())
                    .unwrap_or(format!("Critical error: {}", e));

                self.report_discovery_update(DiscoverySessionUpdate {
                    phase: DiscoveryPhase::Failed,
                    completed: final_scanned_count,
                    error: Some(error),
                    discovered_count: final_discovered_count,
                    finished_at: Some(Utc::now()),
                })
                .await?;
                cancel.cancel();
            }
        }

        let mut current_session = self.as_ref().current_session.write().await;
        *current_session = None;

        if cancel.is_cancelled() {
            tracing::info!("Discovery session {} was cancelled", session_id);
            return Ok(());
        }

        tracing::info!(
            "Discovery session {} finished with {} discovered",
            session_id,
            final_discovered_count
        );
        Ok(())
    }

    async fn process_host<'a>(
        &self,
        params: ServiceMatchBaselineParams<'a>,
        hostname: Option<String>,
    ) -> Result<Option<(Host, Vec<Service>)>, Error> {
        let ServiceMatchBaselineParams::<'a> { interface, .. } = params;

        let daemon_id = self.as_ref().config_store.get_id().await?;
        let network_id = self
            .as_ref()
            .config_store
            .get_network_id()
            .await?
            .ok_or_else(|| anyhow::anyhow!("Network ID not set"))?;

        let session = self.as_ref().get_session().await?;
        let gateway_ips = session.gateway_ips.clone();
        let discovery_type = self.discovery_type();

        let (name, target) = match hostname.clone() {
            Some(hostname) => (hostname, HostTarget::Hostname),
            None => ("Unknown Device".to_owned(), HostTarget::None),
        };

        // Create host
        let mut host = Host::new(HostBase {
            name,
            hostname,
            target,
            network_id,
            description: None,
            interfaces: vec![interface.clone()],
            services: Vec::new(),
            ports: Vec::new(),
            source: EntitySource::Discovery {
                metadata: vec![DiscoveryMetadata::new(discovery_type, daemon_id)],
            },
            virtualization: None,
        });

        let services = self.discover_services(
            &mut host,
            &params,
            &gateway_ips,
            &daemon_id,
            &network_id,
            &discovery_type,
        )?;

        tracing::info!("Processed host for ip {}", interface.base.ip_address);
        Ok(Some((host, services)))
    }

    fn discover_services(
        &self,
        host: &mut Host,
        baseline_params: &ServiceMatchBaselineParams,
        gateway_ips: &[IpAddr],
        daemon_id: &Uuid,
        network_id: &Uuid,
        discovery_type: &DiscoveryType,
    ) -> Result<Vec<Service>, Error> {
        let ServiceMatchBaselineParams { all_ports, .. } = baseline_params;

        let mut services = Vec::new();

        // Need to track which ports are bound vs open for services to bind to
        let mut l4_unbound_ports = all_ports.to_vec();

        let mut sorted_service_definitions: Vec<Box<dyn ServiceDefinition>> =
            ServiceDefinitionRegistry::all_service_definitions()
                .into_iter()
                .collect();

        sorted_service_definitions.sort_by_key(|s| {
            if !ServiceDefinitionExt::is_generic(s) {
                0 // Highest priority - non-generic services
            } else if ServiceDefinitionExt::is_generic(s) && s.id() != Gateway.id() {
                1 // Generic services that aren't Gateway
            } else {
                2 // Generic gateways need to go last, as other services may be classified as gateway first
            }
        });

        // Add services from detected ports
        for service_definition in sorted_service_definitions {
            let service_params = ServiceMatchServiceParams {
                service_definition,
                matched_services: &services,
                unbound_ports: &l4_unbound_ports,
            };

            let params: DiscoverySessionServiceMatchParams<'_> =
                DiscoverySessionServiceMatchParams {
                    service_params,
                    baseline_params,
                    daemon_id,
                    discovery_type,
                    network_id,
                    gateway_ips,
                    host_id: &host.id,
                };

            if let Some((service, mut result)) = Service::from_discovery(params) {
                // If there's a endpoint match + host target is hostname or none, use a binding as the host target
                if let (Some(binding), true) = (
                    service.base.bindings.iter().find(|b| {
                        match b {
                            Binding::Interface { .. } => false,
                            Binding::Port { port_id, .. } => {
                                if let Some(port) = host.get_port(port_id) {
                                    return result
                                        .endpoint
                                        .iter()
                                        .any(|e| e.port_base == port.base);
                                }
                                false
                            }
                        };
                        false
                    }),
                    matches!(host.base.target, HostTarget::Hostname | HostTarget::None),
                ) {
                    host.base.target = HostTarget::ServiceBinding(binding.id())
                }

                // Add any bound ports to host ports array, remove from open ports
                let bound_port_bases: Vec<PortBase> = result.ports.iter().map(|p| p.base).collect();

                host.base.ports.append(&mut result.ports);

                // Add new service
                l4_unbound_ports.retain(|p| !bound_port_bases.contains(p));
                services.push(service);
            }
        }

        services.sort_by_key(|a| {
            -(match &a.base.source {
                EntitySource::DiscoveryWithMatch { details, .. } => {
                    (details.confidence as i32)
                        + if a.base.service_definition.has_logo() {
                            1
                        } else {
                            0
                        }
                }
                _ => MatchConfidence::NotApplicable as i32,
            })
        });

        if let Some(service) = services
            .iter()
            .find(|s| !ServiceDefinitionExt::is_generic(&s.base.service_definition))
        {
            host.base.name = service.base.service_definition.name().to_string();
        }

        services.iter().for_each(|s| host.add_service(s.id));

        host.base
            .ports
            .extend(l4_unbound_ports.into_iter().map(Port::new));

        Ok(services)
    }

    async fn periodic_scan_update(
        &self,
        frequency: usize,
        last_reported_scanned: usize,
        last_reported_discovered: usize,
    ) -> Result<(usize, usize), Error> {
        let session = self.as_ref().get_session().await?;

        let current_scanned = session
            .scanned_count
            .load(std::sync::atomic::Ordering::Relaxed);
        let current_discovered = session
            .discovered_count
            .load(std::sync::atomic::Ordering::Relaxed);

        if current_scanned >= last_reported_scanned + frequency
            || last_reported_discovered > current_discovered
        {
            self.report_discovery_update(DiscoverySessionUpdate::scanning(
                current_scanned,
                current_discovered,
            ))
            .await?;

            return Ok((current_scanned, current_discovered));
        }

        Ok((last_reported_scanned, last_reported_discovered))
    }

    /// Report discovery progress to server
    async fn report_discovery_update(&self, update: DiscoverySessionUpdate) -> Result<(), Error> {
        let server_target = self.as_ref().config_store.get_server_endpoint().await?;
        let session = self.as_ref().get_session().await?;

        let api_key = self
            .as_ref()
            .config_store
            .get_api_key()
            .await?
            .ok_or_else(|| anyhow::anyhow!("API key not set"))?;

        let payload = DiscoveryUpdatePayload::from_state_and_update(session.info.clone(), update);

        let response = self
            .as_ref()
            .client
            .post(format!("{}/api/discovery/update", server_target))
            .header("Authorization", format!("Bearer {}", api_key))
            .json(&payload)
            .send()
            .await?;

        if !response.status().is_success() {
            anyhow::bail!(
                "Failed to report discovery update: HTTP {}",
                response.status()
            );
        }

        tracing::debug!(
            "Discovery update reported for session {}",
            session.info.session_id
        );
        Ok(())
    }
}

#[async_trait]
pub trait InitiatesOwnDiscovery:
    AsRef<DaemonDiscoveryService> + Send + Sync + HasDiscoveryType
{
    async fn initiate_own_discovery(&self) -> Result<Uuid, Error> {
        let server_target = self.as_ref().config_store.get_server_endpoint().await?;
        let daemon_id = self.as_ref().config_store.get_id().await?;

        let api_key = self
            .as_ref()
            .config_store
            .get_api_key()
            .await?
            .ok_or_else(|| anyhow::anyhow!("API key not set"))?;

        tracing::info!("Initiating discovery");

        let url = format!("{}/api/discovery/daemon-initiate", server_target);
        tracing::info!("Initiating discovery at URL: {}", url); // Add this line

        let response = self
            .as_ref()
            .client
            .post(format!("{}/api/discovery/daemon-initiate", server_target))
            .header("Authorization", format!("Bearer {}", api_key))
            .json(&InitiateDiscoveryRequest { daemon_id })
            .send()
            .await?;

        tracing::info!("Response status: {}", response.status());

        if !response.status().is_success() {
            anyhow::bail!(
                "Failed to initiate own discovery: HTTP {}",
                response.status()
            );
        }

        let api_response: ApiResponse<Uuid> = response.json().await?;

        if !api_response.success {
            let error_msg = api_response
                .error
                .unwrap_or_else(|| "Unknown error".to_string());
            anyhow::bail!("Failed to initiate discovery: {}", error_msg);
        }

        let session_id = api_response
            .data
            .ok_or_else(|| anyhow::anyhow!("No session id in successful response"))?;

        Ok(session_id)
    }
}

#[async_trait]
pub trait CreatesDiscoveredEntities:
    AsRef<DaemonDiscoveryService> + Send + Sync + HasDiscoveryType
{
    async fn create_host(
        &self,
        host: Host,
        services: Vec<Service>,
    ) -> Result<(Host, Vec<Service>), Error> {
        let server_target = self.as_ref().config_store.get_server_endpoint().await?;

        tracing::info!("Creating host {}", host.base.name);

        let api_key = self
            .as_ref()
            .config_store
            .get_api_key()
            .await?
            .ok_or_else(|| anyhow::anyhow!("API key not set"))?;

        let response = self
            .as_ref()
            .client
            .post(format!("{}/api/hosts", server_target))
            .header("Authorization", format!("Bearer {}", api_key))
            .json(&HostWithServicesRequest { host, services })
            .send()
            .await?;

        if !response.status().is_success() {
            anyhow::bail!(
                "Failed to report discovered host: HTTP {}",
                response.status()
            );
        }

        let api_response: ApiResponse<HostWithServicesRequest> = response.json().await?;

        if !api_response.success {
            let error_msg = api_response
                .error
                .unwrap_or_else(|| "Unknown error".to_string());
            anyhow::bail!("Failed to create host: {}", error_msg);
        }

        let HostWithServicesRequest { host, services } = api_response
            .data
            .ok_or_else(|| anyhow::anyhow!("No host data in successful response"))?;

        Ok((host, services))
    }

    async fn create_subnet(&self, subnet: &Subnet) -> Result<Subnet, Error> {
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
            .post(format!("{}/api/subnets", server_target))
            .header("Authorization", format!("Bearer {}", api_key))
            .json(&subnet)
            .send()
            .await?;

        if !response.status().is_success() {
            anyhow::bail!(
                "Failed to report discovered subnet: HTTP {}",
                response.status(),
            );
        }

        let api_response: ApiResponse<Subnet> = response.json().await?;

        if !api_response.success {
            let error_msg = api_response
                .error
                .unwrap_or_else(|| "Unknown error".to_string());
            anyhow::bail!("Failed to create subnet: {}", error_msg);
        }

        let created_subnet = api_response
            .data
            .ok_or_else(|| anyhow::anyhow!("No subnet data in successful response"))?;

        Ok(created_subnet)
    }

    async fn create_service(&self, service: &Service) -> Result<Service, Error> {
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
            .post(format!("{}/api/services", server_target))
            .header("Authorization", format!("Bearer {}", api_key))
            .json(&service)
            .send()
            .await?;

        if !response.status().is_success() {
            anyhow::bail!(
                "Failed to report discovered service: HTTP {}",
                response.status()
            );
        }

        let api_response: ApiResponse<Service> = response.json().await?;

        if !api_response.success {
            let error_msg = api_response
                .error
                .unwrap_or_else(|| "Unknown error".to_string());
            anyhow::bail!("Failed to create service: {}", error_msg);
        }

        let created_service = api_response
            .data
            .ok_or_else(|| anyhow::anyhow!("No service data in successful response"))?;

        Ok(created_service)
    }

    async fn create_group(&self, group: &Group) -> Result<Group, Error> {
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
            .post(format!("{}/api/groups", server_target))
            .header("Authorization", format!("Bearer {}", api_key))
            .json(&group)
            .send()
            .await?;

        if !response.status().is_success() {
            anyhow::bail!(
                "Failed to report discovered group: HTTP {}",
                response.status()
            );
        }

        let api_response: ApiResponse<Group> = response.json().await?;

        if !api_response.success {
            let error_msg = api_response
                .error
                .unwrap_or_else(|| "Unknown error".to_string());
            anyhow::bail!("Failed to create group: {}", error_msg);
        }

        let created_group = api_response
            .data
            .ok_or_else(|| anyhow::anyhow!("No group data in successful response"))?;

        Ok(created_group)
    }
}
