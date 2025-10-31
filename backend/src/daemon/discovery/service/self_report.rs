use crate::{
    daemon::discovery::service::{
        base::{CreatesDiscoveredEntities, Discovery, HasDiscoveryType, InitiatesOwnDiscovery},
        docker::DockerScanDiscovery,
    },
    server::{
        daemons::types::api::DaemonDiscoveryRequest,
        discovery::types::base::{DiscoveryMetadata, DiscoveryType, EntitySource},
        hosts::types::{
            interfaces::{ALL_INTERFACES_IP, Interface},
            ports::{Port, PortBase},
        },
        services::{
            definitions::netvisor_daemon::NetvisorDaemon,
            types::{
                base::ServiceBase, bindings::Binding, definitions::ServiceDefinition,
                patterns::MatchDetails,
            },
        },
        subnets::types::base::{Subnet, SubnetTypeDiscriminants},
    },
};
use crate::{
    daemon::utils::base::DaemonUtils,
    server::{
        hosts::types::{
            base::{Host, HostBase},
            targets::HostTarget,
        },
        services::types::base::Service,
    },
};
use anyhow::{Error, Result};
use futures::future::try_join_all;
use std::{
    net::{IpAddr, Ipv4Addr},
    result::Result::Ok,
    sync::Arc,
};
use strum::IntoDiscriminant;
use uuid::Uuid;

#[derive(Default)]
pub struct SelfReportDiscovery {}

impl HasDiscoveryType for Discovery<SelfReportDiscovery> {
    fn discovery_type(&self) -> DiscoveryType {
        DiscoveryType::SelfReport
    }
}

impl CreatesDiscoveredEntities for Discovery<SelfReportDiscovery> {}

impl Discovery<SelfReportDiscovery> {
    pub async fn run_self_report_docker_discovery(&self) -> Result<(), Error> {
        let config_store = &self.as_ref().config_store;
        let utils = &self.as_ref().utils;

        let host_id = config_store.get_host_id().await?;
        let docker_ok = utils.get_own_docker_socket().await?;

        if let (Some(host_id), true) = (host_id, docker_ok) {
            let docker_discovery = Arc::new(Discovery::new(
                self.service.clone(),
                self.manager.clone(),
                DockerScanDiscovery::new(host_id),
            ));

            let session_id = docker_discovery.initiate_own_discovery().await?;

            let request = DaemonDiscoveryRequest {
                session_id,
                discovery_type: DiscoveryType::Docker { host_id },
            };

            docker_discovery.discover_on_network(request).await?;
        }

        Ok(())
    }

    pub async fn run_self_report_discovery(&self) -> Result<(Host, Vec<Service>), Error> {
        let config_store = &self.as_ref().config_store;
        let utils = &self.as_ref().utils;

        let host_id = config_store
            .get_host_id()
            .await?
            .ok_or_else(|| anyhow::anyhow!("Host ID not set"))?;
        let daemon_id = config_store.get_id().await?;
        let network_id = self
            .as_ref()
            .config_store
            .get_network_id()
            .await?
            .ok_or_else(|| anyhow::anyhow!("Network ID not set"))?;

        let binding_address = config_store.get_bind_address().await?;
        let binding_ip = IpAddr::V4(binding_address.parse::<Ipv4Addr>()?);

        let (interfaces, subnets) = utils
            .get_own_interfaces(self.discovery_type(), daemon_id, network_id)
            .await?;

        // Filter out docker bridge subnets, those are handled in docker discovery
        let subnets: Vec<Subnet> = subnets
            .into_iter()
            .filter(|s| s.base.subnet_type.discriminant() != SubnetTypeDiscriminants::DockerBridge)
            .collect();

        let subnet_futures = subnets.iter().map(|subnet| self.create_subnet(subnet));
        let created_subnets = try_join_all(subnet_futures).await?;

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

        let own_port = Port::new(PortBase::new_tcp(config_store.get_port().await?));
        let own_port_id = own_port.id;
        let local_ip = utils.get_own_ip_address()?;
        let hostname = utils.get_own_hostname();

        // Create host base
        let host_base = HostBase {
            name: hostname
                .clone()
                .unwrap_or(format!("Netvisor-Daemon-{}", local_ip)),
            hostname,
            network_id,
            description: Some("NetVisor daemon".to_string()),
            target: HostTarget::Hostname,
            services: Vec::new(),
            interfaces: interfaces.clone(),
            ports: vec![own_port],
            source: EntitySource::Discovery {
                metadata: vec![DiscoveryMetadata::new(DiscoveryType::SelfReport, daemon_id)],
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
                metadata: vec![DiscoveryMetadata::new(DiscoveryType::SelfReport, daemon_id)],
                details: MatchDetails::new_certain("NetVisor Daemon self-report"),
            },
        });

        services.push(daemon_service);

        tracing::info!(
            "Collected information about own host with local IP: {}, Hostname: {:?}",
            local_ip,
            host.base.hostname
        );

        Ok((host, services))
    }
}
