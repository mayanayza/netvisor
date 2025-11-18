use crate::{
    daemon::discovery::{
        service::base::{
            CreatesDiscoveredEntities, DiscoveryRunner, DiscoverySession, RunsDiscovery,
        },
        types::base::{DiscoveryPhase, DiscoverySessionInfo, DiscoverySessionUpdate},
    },
    server::{
        daemons::r#impl::api::{DaemonCapabilities, DaemonDiscoveryRequest},
        discovery::r#impl::types::DiscoveryType,
        hosts::r#impl::{
            interfaces::{ALL_INTERFACES_IP, Interface},
            ports::{Port, PortBase},
        },
        services::{
            definitions::netvisor_daemon::NetvisorDaemon,
            r#impl::{
                base::ServiceBase, bindings::Binding, definitions::ServiceDefinition,
                patterns::MatchDetails,
            },
        },
        shared::{
            storage::traits::StorableEntity,
            types::{
                api::ApiResponse,
                entities::{DiscoveryMetadata, EntitySource},
            },
        },
        subnets::r#impl::{base::Subnet, types::SubnetTypeDiscriminants},
    },
};
use crate::{
    daemon::utils::base::DaemonUtils,
    server::{
        hosts::r#impl::{
            base::{Host, HostBase},
            targets::HostTarget,
        },
        services::r#impl::base::Service,
    },
};
use anyhow::{Error, Result};
use async_trait::async_trait;
use chrono::Utc;
use futures::future::try_join_all;
use std::net::{IpAddr, Ipv4Addr};
use strum::IntoDiscriminant;
use tokio_util::sync::CancellationToken;
use uuid::Uuid;

#[derive(Default)]
pub struct SelfReportDiscovery {
    host_id: Uuid,
}

impl SelfReportDiscovery {
    pub fn new(host_id: Uuid) -> Self {
        Self { host_id }
    }
}

impl CreatesDiscoveredEntities for DiscoveryRunner<SelfReportDiscovery> {}

#[async_trait]
impl RunsDiscovery for DiscoveryRunner<SelfReportDiscovery> {
    fn discovery_type(&self) -> DiscoveryType {
        DiscoveryType::SelfReport {
            host_id: self.domain.host_id,
        }
    }

    async fn discover(
        &self,
        request: DaemonDiscoveryRequest,
        _cancel: CancellationToken,
    ) -> Result<(), Error> {
        let daemon_id = self.as_ref().config_store.get_id().await?;
        let network_id = self
            .as_ref()
            .config_store
            .get_network_id()
            .await?
            .ok_or_else(|| anyhow::anyhow!("Network ID not set, aborting discovery session"))?;

        let session_info = DiscoverySessionInfo {
            total_to_process: 1,
            session_id: request.session_id,
            network_id,
            daemon_id,
            started_at: Some(Utc::now()),
        };

        let session = DiscoverySession::new(session_info, Vec::new());
        let mut current_session = self.as_ref().current_session.write().await;
        *current_session = Some(session);
        drop(current_session);

        let utils = &self.as_ref().utils;

        let host_id = self.domain.host_id;

        let network_id = self
            .as_ref()
            .config_store
            .get_network_id()
            .await?
            .ok_or_else(|| anyhow::anyhow!("Network ID not set"))?;

        let binding_address = self.as_ref().config_store.get_bind_address().await?;
        let binding_ip = IpAddr::V4(binding_address.parse::<Ipv4Addr>()?);

        let (interfaces, subnets) = utils
            .get_own_interfaces(self.discovery_type(), daemon_id, network_id)
            .await?;

        // Filter out docker bridge subnets, those are handled in docker discovery
        let subnets_to_create: Vec<Subnet> = subnets
            .into_iter()
            .filter(|s| s.base.subnet_type.discriminant() != SubnetTypeDiscriminants::DockerBridge)
            .collect();

        let subnet_futures = subnets_to_create
            .iter()
            .map(|subnet| self.create_subnet(subnet));
        let created_subnets = try_join_all(subnet_futures).await?;

        // Get docker socket
        let has_docker_socket = self.as_ref().utils.get_own_docker_socket().await?;

        // Update capabilities
        let interfaced_subnet_ids: Vec<Uuid> = created_subnets.iter().map(|s| s.id).collect();

        tracing::info!(
            "Updating capabilities with {} interfaced subnets: {:?}",
            interfaced_subnet_ids.len(),
            interfaced_subnet_ids
        );

        self.update_capabilities(has_docker_socket, interfaced_subnet_ids)
            .await?;

        // Created subnets may differ from discovered if there are existing subnets with the same CIDR, so we need to update interface subnet_id references
        // Also filter out interfaces where subnet creation didn't happen for any reason
        let interfaces: Vec<Interface> = interfaces
            .into_iter()
            .filter_map(|mut i| {
                if let Some(subnet) = created_subnets
                    .iter()
                    .find(|s| s.base.cidr.contains(&i.base.ip_address))
                {
                    i.base.subnet_id = subnet.id;
                    return Some(i);
                }
                None
            })
            .collect();

        let daemon_bound_subnet_ids: Vec<Uuid> = if binding_address == ALL_INTERFACES_IP.to_string()
        {
            created_subnets.iter().map(|s| s.id).collect()
        } else {
            created_subnets
                .iter()
                .filter(|s| s.base.cidr.contains(&binding_ip))
                .map(|s| s.id)
                .collect()
        };

        let own_port = Port::new(PortBase::new_tcp(
            self.as_ref().config_store.get_port().await?,
        ));
        let own_port_id = own_port.id;
        let local_ip = utils.get_own_ip_address()?;
        let hostname = utils.get_own_hostname();

        // Create host base
        let host_base = HostBase {
            name: hostname.clone().unwrap_or(format!("{}", local_ip)),
            hostname,
            network_id,
            description: Some("NetVisor daemon".to_string()),
            target: HostTarget::Hostname,
            services: Vec::new(),
            interfaces: interfaces.clone(),
            ports: vec![own_port],
            source: EntitySource::Discovery {
                metadata: vec![DiscoveryMetadata::new(self.discovery_type(), daemon_id)],
            },
            hidden: false,
            virtualization: None,
        };

        let mut host = Host::new(host_base);

        host.id = host_id;

        let mut services = Vec::new();
        let daemon_service_definition = NetvisorDaemon;

        let daemon_service_bound_interfaces: Vec<&Interface> = interfaces
            .iter()
            .filter(|i| daemon_bound_subnet_ids.contains(&i.base.subnet_id))
            .collect();

        let daemon_service = Service::new(ServiceBase {
            name: ServiceDefinition::name(&daemon_service_definition).to_string(),
            service_definition: Box::new(daemon_service_definition),
            network_id,
            bindings: daemon_service_bound_interfaces
                .iter()
                .map(|i| Binding::new_port(own_port_id, Some(i.id)))
                .collect(),
            host_id: host.id,
            virtualization: None,
            source: EntitySource::DiscoveryWithMatch {
                metadata: vec![DiscoveryMetadata::new(self.discovery_type(), daemon_id)],
                details: MatchDetails::new_certain("NetVisor Daemon self-report"),
            },
        });

        services.push(daemon_service);

        tracing::info!(
            "Collected information about own host with local IP: {}, Hostname: {:?}",
            local_ip,
            host.base.hostname
        );

        self.create_host(host, services).await?;

        self.report_discovery_update(DiscoverySessionUpdate {
            phase: DiscoveryPhase::Complete,
            processed: 1,
            error: None,
            finished_at: Some(Utc::now()),
        })
        .await?;

        Ok(())
    }
}

impl DiscoveryRunner<SelfReportDiscovery> {
    async fn update_capabilities(
        &self,
        has_docker_socket: bool,
        interfaced_subnet_ids: Vec<Uuid>,
    ) -> Result<(), Error> {
        let server_target = self.as_ref().config_store.get_server_url().await?;

        let capabilities = DaemonCapabilities {
            has_docker_socket,
            interfaced_subnet_ids,
        };

        let api_key = self
            .as_ref()
            .config_store
            .get_api_key()
            .await?
            .ok_or_else(|| anyhow::anyhow!("API key not set"))?;

        let daemon_id = self.as_ref().config_store.get_id().await?;

        let response = self
            .as_ref()
            .client
            .post(format!(
                "{}/api/daemons/{}/update-capabilities",
                server_target, daemon_id
            ))
            .header("Authorization", format!("Bearer {}", api_key))
            .json(&capabilities)
            .send()
            .await?;

        if !response.status().is_success() {
            anyhow::bail!("Failed to update capabilities: HTTP {}", response.status());
        }

        let api_response: ApiResponse<()> = response.json().await?;

        if !api_response.success {
            let error_msg = api_response
                .error
                .unwrap_or_else(|| "Unknown error".to_string());
            anyhow::bail!("Failed to update capabilities: {}", error_msg);
        }

        Ok(())
    }
}
