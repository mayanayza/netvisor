use std::{
    net::IpAddr,
    sync::{Arc, atomic::AtomicUsize},
    time::Duration,
};

use crate::{
    daemon::discovery::{
        manager::DaemonDiscoverySessionManager, types::base::DiscoveryCriticalError,
    },
    server::{
        discovery::types::base::{DiscoveryMetadata, DiscoveryType},
        groups::types::Group,
        services::types::{
            base::{
                DiscoverySessionServiceMatchParams, ServiceMatchBaselineParams,
                ServiceMatchServiceParams,
            },
            endpoints::{Endpoint, EndpointResponse},
            patterns::MatchConfidence,
        },
    },
};
use anyhow::{Error, anyhow};
use async_trait::async_trait;
use chrono::Utc;
use tokio::sync::RwLock;
use tokio_util::sync::CancellationToken;

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
            manager,
            domain,
        }
    }
}

impl<T> AsRef<DaemonDiscoveryService> for Discovery<T> {
    fn as_ref(&self) -> &DaemonDiscoveryService {
        &self.service
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

#[async_trait]
pub trait RunsDiscovery: AsRef<DaemonDiscoveryService> + Send + Sync {
    fn discovery_type(&self) -> DiscoveryType;

    async fn discover(
        &self,
        request: DaemonDiscoveryRequest,
        cancel: CancellationToken,
    ) -> Result<(), Error>;

    /// Report discovery progress to server
    async fn report_discovery_update(&self, update: DiscoverySessionUpdate) -> Result<(), Error> {
        let server_target = self.as_ref().config_store.get_server_endpoint().await?;
        let session = self.as_ref().get_session().await?;
        let discovery_type = self.discovery_type();

        let api_key = self
            .as_ref()
            .config_store
            .get_api_key()
            .await?
            .ok_or_else(|| anyhow::anyhow!("API key not set"))?;

        let payload = DiscoveryUpdatePayload::from_state_and_update(
            discovery_type,
            session.info.clone(),
            update,
        );

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
pub trait DiscoversNetworkedEntities:
    AsRef<DaemonDiscoveryService> + Send + Sync + RunsDiscovery
{
    async fn get_gateway_ips(&self) -> Result<Vec<IpAddr>, Error>;

    async fn discover_create_subnets(&self) -> Result<Vec<Subnet>, Error>;

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
            hidden: false,
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

    async fn scan_endpoints(
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
}

#[async_trait]
pub trait CreatesDiscoveredEntities:
    AsRef<DaemonDiscoveryService> + Send + Sync + RunsDiscovery
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
            .json(&HostWithServicesRequest {
                host,
                services: Some(services),
            })
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

        let services = services.unwrap_or(vec![]);

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
