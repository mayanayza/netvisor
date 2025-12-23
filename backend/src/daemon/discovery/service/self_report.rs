use crate::{
    daemon::discovery::{
        service::base::{
            CreatesDiscoveredEntities, DiscoveryRunner, DiscoverySession, RunsDiscovery,
        },
        types::base::{DiscoveryPhase, DiscoverySessionInfo, DiscoverySessionUpdate},
    },
    server::{
        bindings::r#impl::base::Binding,
        daemons::r#impl::api::{DaemonCapabilities, DaemonDiscoveryRequest},
        discovery::r#impl::types::DiscoveryType,
        interfaces::r#impl::base::{ALL_INTERFACES_IP, Interface},
        ports::r#impl::base::{Port, PortType},
        services::{
            definitions::scanopy_daemon::ScanopyDaemon,
            r#impl::{base::ServiceBase, definitions::ServiceDefinition, patterns::MatchDetails},
        },
        shared::{
            storage::traits::StorableEntity,
            types::entities::{DiscoveryMetadata, EntitySource},
        },
        subnets::r#impl::{base::Subnet, types::SubnetTypeDiscriminants},
    },
};
use crate::{
    daemon::utils::base::DaemonUtils,
    server::{
        hosts::r#impl::base::{Host, HostBase},
        services::r#impl::base::Service,
    },
};
use anyhow::{Error, Result};
use async_trait::async_trait;
use chrono::Utc;
use cidr::IpCidr;
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

        let (interfaces, subnets, _) = utils
            .get_own_interfaces(self.discovery_type(), daemon_id, network_id)
            .await?;

        // Get docker subnets to double verify that subnet interface string matching filtered them correctly
        let docker_proxy = self.as_ref().config_store.get_docker_proxy().await;
        let docker_proxy_ssl_info = self.as_ref().config_store.get_docker_proxy_ssl_info().await;

        let docker_client = self
            .as_ref()
            .utils
            .new_local_docker_client(docker_proxy, docker_proxy_ssl_info)
            .await;

        let (docker_cidrs, has_docker_socket) = if let Ok(docker_client) = docker_client {
            let docker_subnets = self
                .as_ref()
                .utils
                .get_subnets_from_docker_networks(
                    daemon_id,
                    network_id,
                    &docker_client,
                    self.discovery_type(),
                )
                .await?;
            let docker_cidrs: Vec<IpCidr> = docker_subnets.iter().map(|s| s.base.cidr).collect();
            (docker_cidrs, true)
        } else {
            (Vec::new(), false)
        };

        // Filter out docker bridge subnets, those are handled in docker discovery
        let subnets_to_create: Vec<Subnet> = subnets
            .into_iter()
            .filter(|s| {
                s.base.subnet_type.discriminant() != SubnetTypeDiscriminants::DockerBridge
                    && !docker_cidrs.contains(&s.base.cidr)
            })
            .collect();

        let subnet_futures = subnets_to_create
            .iter()
            .map(|subnet| self.create_subnet(subnet));
        let created_subnets = try_join_all(subnet_futures).await?;

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

        let own_port = Port::new_hostless(PortType::new_tcp(
            self.as_ref().config_store.get_port().await?,
        ));
        let own_port_id = own_port.id;
        let local_ip = utils.get_own_ip_address()?;
        let hostname = utils.get_own_hostname();

        // Create host base - children (interfaces, ports, services) are passed separately
        let host_base = HostBase {
            name: hostname.clone().unwrap_or(format!("{}", local_ip)),
            hostname,
            network_id,
            description: Some("Scanopy daemon".to_string()),
            tags: Vec::new(),
            source: EntitySource::Discovery {
                metadata: vec![DiscoveryMetadata::new(self.discovery_type(), daemon_id)],
            },
            hidden: false,
            virtualization: None,
        };

        // Ports to create with the host
        let ports = vec![own_port];

        let mut host = Host::new(host_base);

        host.id = host_id;

        let mut services = Vec::new();
        let daemon_service_definition = ScanopyDaemon;

        let daemon_service_bound_interfaces: Vec<&Interface> = interfaces
            .iter()
            .filter(|i| daemon_bound_subnet_ids.contains(&i.base.subnet_id))
            .collect();

        let daemon_service = Service::new(ServiceBase {
            name: ServiceDefinition::name(&daemon_service_definition).to_string(),
            service_definition: Box::new(daemon_service_definition),
            tags: Vec::new(),
            network_id,
            bindings: daemon_service_bound_interfaces
                .iter()
                .map(|i| Binding::new_port_serviceless(own_port_id, Some(i.id)))
                .collect(),
            host_id: host.id,
            virtualization: None,
            source: EntitySource::DiscoveryWithMatch {
                metadata: vec![DiscoveryMetadata::new(self.discovery_type(), daemon_id)],
                details: MatchDetails::new_certain("Scanopy Daemon self-report"),
            },
        });

        services.push(daemon_service);

        tracing::info!(
            "Collected information about own host with local IP: {}, Hostname: {:?}",
            local_ip,
            host.base.hostname
        );

        // Pass interfaces and ports separately - server will create them with the correct host_id
        self.create_host(host, interfaces, ports, services).await?;

        self.report_discovery_update(DiscoverySessionUpdate {
            phase: DiscoveryPhase::Complete,
            progress: 100,
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
        let capabilities = DaemonCapabilities {
            has_docker_socket,
            interfaced_subnet_ids,
        };

        let daemon_id = self.as_ref().api_client.config().get_id().await?;
        let path = format!("/api/daemons/{}/update-capabilities", daemon_id);

        self.as_ref()
            .api_client
            .post_no_data(&path, &capabilities, "Failed to update capabilities")
            .await
    }
}
