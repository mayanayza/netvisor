use std::{
    net::IpAddr,
    sync::{Arc, atomic::AtomicUsize},
};

use crate::{
    daemon::discovery::{
        manager::DaemonDiscoverySessionManager, types::base::DiscoveryCriticalError,
    },
    server::{
        discovery::r#impl::types::{DiscoveryType, HostNamingFallback},
        groups::r#impl::base::Group,
        services::{
            definitions::docker_container::DockerContainer,
            r#impl::{
                base::{
                    DiscoverySessionServiceMatchParams, ServiceMatchBaselineParams,
                    ServiceMatchServiceParams,
                },
                patterns::MatchConfidence,
                virtualization::{DockerVirtualization, ServiceVirtualization},
            },
        },
        shared::types::entities::{DiscoveryMetadata, EntitySource},
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
        shared::config::ConfigStore,
        utils::base::{PlatformDaemonUtils, create_system_utils},
    },
    server::{
        daemons::r#impl::api::{DaemonDiscoveryRequest, DiscoveryUpdatePayload},
        hosts::r#impl::{
            api::HostWithServicesRequest,
            base::{Host, HostBase},
            ports::{Port, PortBase},
            targets::HostTarget,
        },
        services::{
            definitions::{ServiceDefinitionRegistry, gateway::Gateway},
            r#impl::{
                base::Service,
                bindings::Binding,
                definitions::{ServiceDefinition, ServiceDefinitionExt},
            },
        },
        shared::types::{api::ApiResponse, metadata::HasId},
        subnets::r#impl::base::Subnet,
    },
};

pub struct DiscoveryRunner<T> {
    pub service: Arc<DaemonDiscoveryService>,
    pub manager: Arc<DaemonDiscoverySessionManager>,
    pub domain: T,
}

impl<T> DiscoveryRunner<T> {
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

#[derive(Clone)]
pub struct DiscoverySession {
    pub info: DiscoverySessionInfo,
    pub gateway_ips: Vec<IpAddr>,
    pub processed_count: Arc<AtomicUsize>,
}

impl DiscoverySession {
    pub fn new(info: DiscoverySessionInfo, gateway_ips: Vec<IpAddr>) -> Self {
        Self {
            info,
            gateway_ips,
            processed_count: Arc::new(AtomicUsize::new(0)),
        }
    }
}

impl<T> AsRef<DaemonDiscoveryService> for DiscoveryRunner<T> {
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
        let server_target = self.as_ref().config_store.get_server_url().await?;
        let session = self.as_ref().get_session().await?;
        let discovery_type = self.discovery_type();
        let daemon_id = self.as_ref().config_store.get_id().await?;

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
            .post(format!(
                "{}/api/discovery/{}/update",
                server_target, session.info.session_id
            ))
            .header("X-Daemon-ID", daemon_id.to_string())
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

        tracing::trace!(
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
        total_to_process: usize,
        request: DaemonDiscoveryRequest,
        daemon_id: Uuid,
    ) -> Result<(), Error> {
        tracing::debug!(
            "Setting session info for {} discovery session {}",
            request.discovery_type,
            request.session_id
        );
        let gateway_ips = self.get_gateway_ips().await?;
        let network_id = self
            .as_ref()
            .config_store
            .get_network_id()
            .await?
            .ok_or_else(|| anyhow!("Network ID not set, aborting discovery session"))?;

        let session_info = DiscoverySessionInfo {
            total_to_process,
            session_id: request.session_id,
            network_id,
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
            processed: 0,
            error: None,
            finished_at: None,
        })
        .await?;

        let session = self.as_ref().get_session().await?;

        tracing::info!(
            session_id = %session.info.session_id,
            discovery_type = ?self.discovery_type(),
            total_to_process = %session.info.total_to_process,
            "Discovery session started"
        );

        Ok(())
    }

    async fn finish_discovery(
        &self,
        discovery_result: Result<(), Error>,
        cancel: CancellationToken,
    ) -> Result<(), Error> {
        let session = self.as_ref().get_session().await?;
        let session_id = session.info.session_id;

        let final_processed_count = session
            .processed_count
            .load(std::sync::atomic::Ordering::Relaxed);

        match &discovery_result {
            Ok(_) => {
                tracing::info!(
                    session_id = %session_id,
                    processed = %final_processed_count,
                    "Discovery session completed successfully"
                );
                self.report_discovery_update(DiscoverySessionUpdate {
                    phase: DiscoveryPhase::Complete,
                    processed: final_processed_count,
                    error: None,
                    finished_at: Some(Utc::now()),
                })
                .await?;
            }
            Err(_) if cancel.is_cancelled() => {
                tracing::warn!(
                    session_id = %session_id,
                    processed = %final_processed_count,
                    "Discovery session cancelled"
                );
                self.report_discovery_update(DiscoverySessionUpdate {
                    phase: DiscoveryPhase::Cancelled,
                    processed: final_processed_count,
                    error: None,
                    finished_at: Some(Utc::now()),
                })
                .await?;
            }
            Err(e) => {
                tracing::error!(
                    session_id = %session_id,
                    processed = %final_processed_count,
                    error = %e,
                    "Discovery session failed"
                );

                let error = DiscoveryCriticalError::from_error_string(e.to_string())
                    .map(|e| e.to_string())
                    .unwrap_or(format!("Critical error: {}", e));

                self.report_discovery_update(DiscoverySessionUpdate {
                    phase: DiscoveryPhase::Failed,
                    processed: final_processed_count,
                    error: Some(error),
                    finished_at: Some(Utc::now()),
                })
                .await?;
                cancel.cancel();
            }
        }

        let mut current_session = self.as_ref().current_session.write().await;
        *current_session = None;

        if cancel.is_cancelled() {
            return Ok(());
        }

        Ok(())
    }

    async fn process_host<'a>(
        &self,
        params: ServiceMatchBaselineParams<'a>,
        hostname: Option<String>,
        host_naming_fallback: HostNamingFallback,
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

        // Create host
        let mut host = Host::new(HostBase {
            name: "Unknown Device".to_string(),
            hostname: hostname.clone(),
            target: HostTarget::None,
            network_id,
            description: None,
            interfaces: vec![interface.clone()],
            services: Vec::new(),
            ports: Vec::new(),
            source: EntitySource::Discovery {
                metadata: vec![DiscoveryMetadata::new(discovery_type.clone(), daemon_id)],
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

        // Determine host's name
        let best_service_name = services
            .iter()
            .find(|s| !ServiceDefinitionExt::is_generic(&s.base.service_definition))
            .map(|s| s.base.service_definition.name().to_string());

        if let Some(hostname) = hostname {
            host.base.name = hostname;
            if host.base.target == HostTarget::None {
                host.base.target = HostTarget::Hostname
            }
        } else if host_naming_fallback == HostNamingFallback::BestService
            && let Some(best_service_name) = best_service_name
        {
            host.base.name = best_service_name
        } else if host_naming_fallback == HostNamingFallback::Ip {
            host.base.name = interface.base.ip_address.to_string()
        } else if let Some(best_service_name) = best_service_name {
            host.base.name = best_service_name
        } else {
            host.base.name = interface.base.ip_address.to_string()
        }

        tracing::info!(
            ip = %interface.base.ip_address,
            host_name = %host.base.name,
            service_count = %services.len(),
            "Processed host for ip {}",
            interface.base.ip_address
        );
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

        // Track which ports are bound vs open for services to bind to
        let mut unbound_ports = all_ports.to_vec();

        let mut container_matched = false;

        let mut sorted_service_definitions: Vec<Box<dyn ServiceDefinition>> =
            ServiceDefinitionRegistry::all_service_definitions()
                .into_iter()
                .collect();

        sorted_service_definitions.sort_by_key(|s| {
            if !ServiceDefinitionExt::is_generic(s) {
                0 // Highest priority - non-generic services
            } else if ServiceDefinitionExt::is_generic(s)
                && s.id() != DockerContainer.id()
                && s.id() != Gateway.id()
            {
                1 // Generic services that aren't Docker Container or Gateway
            } else {
                // Docker Containers and Gateways need to go last
                // Other generic services should be able to get matched first
                2
            }
        });

        // Add services from detected ports
        for service_definition in sorted_service_definitions {
            let service_params = ServiceMatchServiceParams {
                service_definition,
                matched_services: &services,
                unbound_ports: &unbound_ports,
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

            if let Some((service, mut result)) = Service::from_discovery(params)
                && !container_matched
            {
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

                // If a container was matched w the provided virtualization, no others can be matched
                if let Some(ServiceVirtualization::Docker(DockerVirtualization {
                    container_id: Some(_),
                    ..
                })) = &service.base.virtualization
                {
                    container_matched = true
                }

                // Add any bound ports to host ports array, remove from open ports
                let bound_port_bases: Vec<PortBase> = result.ports.iter().map(|p| p.base).collect();

                host.base.ports.append(&mut result.ports);

                // Add new service
                unbound_ports.retain(|p| !bound_port_bases.contains(p));
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

        services.iter().for_each(|s| host.add_service(s.id));

        host.base
            .ports
            .extend(unbound_ports.into_iter().map(Port::new));

        Ok(services)
    }

    /// Report discovery progress update periodically
    /// Returns the current processed count for tracking
    async fn periodic_scan_update(
        &self,
        last_reported_processed_count: usize,
    ) -> Result<usize, Error> {
        let session = self.as_ref().get_session().await?;
        let current_processed = session
            .processed_count
            .load(std::sync::atomic::Ordering::Relaxed);

        let total_to_process = session.info.total_to_process;

        // Calculate adaptive threshold based on total size
        // Goal: Report approximately 10-20 updates total
        let min_threshold = 1; // Always report at least every item for very small scans
        let target_updates = 15; // Aim for ~15 progress updates
        let calculated_threshold = (total_to_process / target_updates).max(1);

        // Cap the threshold at reasonable bounds
        let threshold = calculated_threshold.clamp(min_threshold, 50);

        // Report if we've processed enough items since last report
        if current_processed >= last_reported_processed_count + threshold
            || current_processed == total_to_process
        // Always report when complete
        {
            tracing::debug!(
                processed = %current_processed,
                total = %total_to_process,
                percentage = format!("{:.1}%", current_processed as f32 / total_to_process as f32),
                "Discovery progress update"
            );

            self.report_discovery_update(DiscoverySessionUpdate::scanning(current_processed))
                .await?;

            return Ok(current_processed);
        }

        Ok(last_reported_processed_count)
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
        let server_target = self.as_ref().config_store.get_server_url().await?;
        let daemon_id = self.as_ref().config_store.get_id().await?;
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
            .header("X-Daemon-ID", daemon_id.to_string())
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
        let server_target = self.as_ref().config_store.get_server_url().await?;
        let daemon_id = self.as_ref().config_store.get_id().await?;

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
            .header("X-Daemon-ID", daemon_id.to_string())
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
        let server_target = self.as_ref().config_store.get_server_url().await?;
        let daemon_id = self.as_ref().config_store.get_id().await?;

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
            .header("X-Daemon-ID", daemon_id.to_string())
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
        let server_target = self.as_ref().config_store.get_server_url().await?;
        let daemon_id = self.as_ref().config_store.get_id().await?;

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
            .header("X-Daemon-ID", daemon_id.to_string())
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
