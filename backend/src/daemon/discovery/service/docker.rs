use anyhow::anyhow;
use anyhow::{Error, Result};
use async_trait::async_trait;
use bollard::{
    Docker,
    query_parameters::{InspectContainerOptions, ListContainersOptions, ListNetworksOptions},
    secret::{ContainerInspectResponse, ContainerSummary, PortTypeEnum},
};
use futures::future::try_join_all;
use futures::stream::{self, StreamExt};
use std::str::FromStr;
use std::sync::Arc;
use std::sync::atomic::AtomicUsize;
use std::{collections::HashMap, net::IpAddr, sync::OnceLock};
use strum::IntoDiscriminant;
use tokio_util::sync::CancellationToken;

use crate::daemon::discovery::service::base::RunsDiscovery;
use crate::daemon::discovery::types::base::DiscoverySessionUpdate;
use crate::daemon::utils::base::DaemonUtils;
use crate::server::discovery::types::base::{DiscoveryMetadata, DiscoveryType};
use crate::server::hosts::types::base::HostBase;
use crate::server::hosts::types::interfaces::ALL_INTERFACES_IP;
use crate::server::hosts::types::ports::Port;
use crate::server::services::types::base::{Service, ServiceBase, ServiceMatchBaselineParams};
use crate::server::services::types::bindings::{Binding, BindingDiscriminants};
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::endpoints::{Endpoint, EndpointResponse};
use crate::server::services::types::patterns::MatchDetails;
use crate::server::services::types::virtualization::{DockerVirtualization, ServiceVirtualization};
use crate::server::subnets::types::base::{
    Subnet, SubnetBase, SubnetType, SubnetTypeDiscriminants,
};
use crate::{
    daemon::discovery::service::base::{
        CreatesDiscoveredEntities, DiscoversNetworkedEntities, Discovery,
    },
    server::{
        daemons::types::api::DaemonDiscoveryRequest,
        discovery::types::base::EntitySource,
        hosts::types::{
            base::Host,
            interfaces::{Interface, InterfaceBase},
            ports::PortBase,
        },
    },
};
use cidr::IpCidr;
use mac_address::MacAddress;
use uuid::Uuid;

type IpPortHashMap = HashMap<IpAddr, Vec<PortBase>>;

pub struct DockerScanDiscovery {
    docker_client: OnceLock<Docker>,
    host_id: Uuid,
}

pub struct ProcessContainerParams<'a> {
    pub containers_interfaces_and_subnets: &'a HashMap<String, Vec<(Interface, Subnet)>>,
    pub container: &'a ContainerInspectResponse,
    pub container_summary: &'a ContainerSummary,
    pub docker_service_id: &'a Uuid,
    pub scanned_count: Arc<AtomicUsize>,
    pub discovered_count: Arc<AtomicUsize>,
    pub cancel: CancellationToken,
}

#[async_trait]
impl RunsDiscovery for Discovery<DockerScanDiscovery> {
    fn discovery_type(&self) -> DiscoveryType {
        DiscoveryType::Docker {
            host_id: self.domain.host_id,
        }
    }

    async fn discover(
        &self,
        request: DaemonDiscoveryRequest,
        cancel: CancellationToken,
    ) -> Result<(), Error> {
        let daemon_id = self.as_ref().config_store.get_id().await?;
        let network_id = self
            .as_ref()
            .config_store
            .get_network_id()
            .await?
            .ok_or_else(|| anyhow::anyhow!("Network ID not set"))?;

        let docker = self.new_local_docker_client().await?;
        self.domain
            .docker_client
            .set(docker.clone())
            .map_err(|_| anyhow!("Failed to set docker client"))?;

        let container_list = self.get_containers_to_scan().await?;

        self.start_discovery(container_list.len(), request).await?;

        // Create service for docker daemon
        let (_, services) = self.create_docker_daemon_service().await?;

        let docker_daemon_service = services
            .first()
            .ok_or_else(|| anyhow!("Docker daemon service was not created, aborting"))?;

        // Get and create docker and host subnets
        let subnets = self.discover_create_subnets().await?;

        // Get host interfaces
        let (mut host_interfaces, _) = self
            .as_ref()
            .utils
            .get_own_interfaces(self.discovery_type(), daemon_id, network_id)
            .await?;

        // Get container info
        let containers = self.get_containers_and_summaries().await?;

        // Combine host interfaces + subnets to get a map of containers to the interfaces they have + subnets those interfaces are for
        let containers_interfaces_and_subnets =
            self.get_container_interfaces(&containers, &subnets, &mut host_interfaces);

        let discovered_hosts_services = self
            .scan_and_process_containers(
                cancel.clone(),
                containers,
                &containers_interfaces_and_subnets,
                &docker_daemon_service.id,
            )
            .await;

        let discovery_result = if discovered_hosts_services.is_ok() {
            Ok(())
        } else {
            Err(anyhow::Error::msg(""))
        };

        self.finish_discovery(discovery_result, cancel.clone())
            .await?;

        Ok(())
    }
}

impl DockerScanDiscovery {
    pub fn new(host_id: Uuid) -> Self {
        Self {
            docker_client: OnceLock::new(),
            host_id,
        }
    }
}

impl CreatesDiscoveredEntities for Discovery<DockerScanDiscovery> {}

#[async_trait]
impl DiscoversNetworkedEntities for Discovery<DockerScanDiscovery> {
    async fn get_gateway_ips(&self) -> Result<Vec<IpAddr>, Error> {
        let docker = self
            .domain
            .docker_client
            .get()
            .ok_or_else(|| anyhow!("Docker client unavailable"))?;

        let gateway_ips: Vec<IpAddr> = docker
            .list_networks(None::<ListNetworksOptions>)
            .await?
            .iter()
            .filter_map(|n| {
                if let Some(ipam) = &n.ipam
                    && let Some(config) = &ipam.config
                {
                    return Some(
                        config
                            .iter()
                            .filter_map(|c| c.gateway.as_ref())
                            .filter_map(|g| g.parse::<IpAddr>().ok())
                            .collect::<Vec<IpAddr>>(),
                    );
                }
                None
            })
            .flatten()
            .collect();

        Ok(gateway_ips)
    }

    async fn discover_create_subnets(&self) -> Result<Vec<Subnet>, Error> {
        let daemon_id = self.as_ref().config_store.get_id().await?;

        let network_id = self
            .as_ref()
            .config_store
            .get_network_id()
            .await?
            .ok_or_else(|| anyhow::anyhow!("Network ID not set"))?;

        let (_, host_subnets) = self
            .as_ref()
            .utils
            .get_own_interfaces(self.discovery_type(), daemon_id, network_id)
            .await?;

        let docker_subnets = self
            .get_subnets_from_docker_networks(daemon_id, network_id)
            .await?;

        let subnets: Vec<Subnet> = [host_subnets, docker_subnets].concat();

        let subnet_futures = subnets.iter().map(|subnet| self.create_subnet(subnet));
        let subnets = try_join_all(subnet_futures).await?;

        Ok(subnets)
    }
}

impl Discovery<DockerScanDiscovery> {
    /// Create a new Docker discovery instance connecting to a remote Docker daemon
    pub async fn new_local_docker_client(&self) -> Result<Docker, Error> {
        tracing::debug!("Connecting to Docker daemon");

        let client = Docker::connect_with_local_defaults()
            .map_err(|e| anyhow::anyhow!("Failed to connect to Docker: {}", e))?;

        client.ping().await?;

        Ok(client)
    }

    /// Create docker daemon service which has all discovered containers in containers field
    /// Create netvisor daemon service which has container relationship with docker daemon service
    pub async fn create_docker_daemon_service(&self) -> Result<(Host, Vec<Service>), Error> {
        let daemon_id = self.as_ref().config_store.get_id().await?;
        let network_id = self
            .as_ref()
            .config_store
            .get_network_id()
            .await?
            .ok_or_else(|| anyhow::anyhow!("Network ID not set"))?;

        let host_id = self.domain.host_id;

        let docker_service_definition = crate::server::services::definitions::docker_daemon::Docker;

        let docker_service = Service::new(ServiceBase {
            name: ServiceDefinition::name(&docker_service_definition).to_string(),
            service_definition: Box::new(docker_service_definition),
            bindings: vec![],
            host_id,
            network_id,
            virtualization: None,
            source: EntitySource::DiscoveryWithMatch {
                metadata: vec![DiscoveryMetadata::new(
                    DiscoveryType::SelfReport { host_id },
                    daemon_id,
                )],
                details: MatchDetails::new_certain("Docker daemon self-report"),
            },
        });

        let mut temp_docker_daemon_host = Host::new(HostBase::default());
        temp_docker_daemon_host.id = self.domain.host_id;
        temp_docker_daemon_host.base.network_id = network_id;
        temp_docker_daemon_host.base.source = EntitySource::Discovery {
            metadata: vec![DiscoveryMetadata::new(self.discovery_type(), daemon_id)],
        };
        temp_docker_daemon_host.base.services = vec![docker_service.id];

        self.create_host(temp_docker_daemon_host, vec![docker_service])
            .await
    }

    async fn scan_and_process_containers(
        &self,
        cancel: CancellationToken,
        containers: Vec<(ContainerInspectResponse, ContainerSummary)>,
        containers_interfaces_and_subnets: &HashMap<String, Vec<(Interface, Subnet)>>,
        docker_service_id: &Uuid,
    ) -> Result<Vec<(Host, Vec<Service>)>> {
        let session = self.as_ref().get_session().await?;
        let scanned_count = session.scanned_count.clone();
        let discovered_count = session.discovered_count.clone();

        let concurrent_scans = self.as_ref().config_store.get_concurrent_scans().await?;

        self.report_discovery_update(DiscoverySessionUpdate::scanning(0, 0))
            .await?;

        // Process containers concurrently using streams
        let results = stream::iter(containers.into_iter())
            .map(|(container, container_summary)| {
                let scanned_count = scanned_count.clone();
                let discovered_count = discovered_count.clone();
                let cancel = cancel.clone();

                async move {
                    self.process_single_container(&ProcessContainerParams {
                        containers_interfaces_and_subnets,
                        container: &container,
                        container_summary: &container_summary,
                        docker_service_id,
                        scanned_count,
                        discovered_count,
                        cancel,
                    })
                    .await
                }
            })
            .buffer_unordered(concurrent_scans);

        let mut stream_pin = Box::pin(results);
        let mut last_reported_scan_count: usize = 0;
        let mut last_reported_discovery_count: usize = 0;
        let mut all_container_data = Vec::new();

        while let Some(result) = stream_pin.next().await {
            if cancel.is_cancelled() {
                tracing::warn!("Docker discovery session was cancelled");
                return Err(Error::msg("Docker discovery session was cancelled"));
            }

            match result {
                Ok(Some((host, services))) => all_container_data.push((host, services)),
                Ok(None) => {}
                Err(e) => tracing::warn!("Error processing container: {}", e),
            }

            (last_reported_scan_count, last_reported_discovery_count) = self
                .periodic_scan_update(5, last_reported_scan_count, last_reported_discovery_count)
                .await?;
        }

        Ok(all_container_data)
    }

    async fn process_single_container(
        &self,
        params: &ProcessContainerParams<'_>,
    ) -> Result<Option<(Host, Vec<Service>)>> {
        let ProcessContainerParams {
            container,
            container_summary,
            scanned_count,
            cancel,
            ..
        } = params;

        scanned_count.fetch_add(1, std::sync::atomic::Ordering::Relaxed);

        if let Some(container_id) = container.id.clone() {
            if cancel.is_cancelled() {
                return Err(Error::msg("Discovery was cancelled"));
            }

            if container_id != container_summary.id.clone().unwrap_or_default() {
                tracing::warn!(
                    "Container inspection failure; inspected container does not match container summary"
                );
                return Ok(None);
            }

            let host_networking_mode = container
                .host_config
                .as_ref()
                .and_then(|c| c.network_mode.clone())
                .unwrap_or_default()
                == "host";

            if host_networking_mode {
                return self
                    .process_host_mode_container(params, &container_id)
                    .await;
            } else {
                return self
                    .process_bridge_mode_container(params, &container_id)
                    .await;
            }
        }

        Ok(None)
    }

    async fn process_host_mode_container(
        &self,
        params: &ProcessContainerParams<'_>,
        container_id: &String,
    ) -> Result<Option<(Host, Vec<Service>)>> {
        let ProcessContainerParams {
            containers_interfaces_and_subnets,
            container,
            scanned_count,
            discovered_count,
            cancel,
            docker_service_id,
            ..
        } = params;

        scanned_count.fetch_add(1, std::sync::atomic::Ordering::Relaxed);

        tracing::info!(
            "Processing host mode container {}",
            container
                .name
                .as_ref()
                .unwrap_or(&"Unknown Container Name".to_string())
        );

        let host_ip = self.as_ref().utils.get_own_ip_address()?;

        if let Some(Some(p)) = container.config.as_ref().map(|c| c.exposed_ports.as_ref()) {
            let open_ports: Vec<PortBase> = p
                .keys()
                .filter_map(|v| PortBase::from_str(v).ok())
                .collect();

            // Scan ports and any endpoints that match open ports
            let endpoint_responses = tokio::spawn(Self::scan_endpoints(
                host_ip,
                cancel.clone(),
                Some(open_ports.clone()),
            ))
            .await
            .map_err(|e| anyhow!("Scan task panicked: {}", e))?
            .map_err(|e| anyhow!("Endpoint scanning error: {}", e))?;

            let empty_vec_ref = &vec![];

            let container_interfaces_and_subnets = containers_interfaces_and_subnets
                .get(container_id)
                .unwrap_or(empty_vec_ref);

            for (interface, subnet) in container_interfaces_and_subnets {
                let params = ServiceMatchBaselineParams {
                    subnet,
                    interface,
                    all_ports: &open_ports,
                    endpoint_responses: &endpoint_responses,
                    virtualization: &Some(ServiceVirtualization::Docker(DockerVirtualization {
                        container_name: container
                            .name
                            .clone()
                            .map(|n| n.trim_start_matches("/").to_string()),
                        container_id: container.id.clone(),
                        service_id: **docker_service_id,
                    })),
                };

                if let Ok(Some((mut host, services))) = self.process_host(params, None).await {
                    host.id = self.domain.host_id;

                    discovered_count.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
                    if let Ok((created_host, created_services)) =
                        self.create_host(host, services).await
                    {
                        return Ok::<Option<(Host, Vec<Service>)>, Error>(Some((
                            created_host,
                            created_services,
                        )));
                    }
                    return Ok(None);
                }
            }
        }
        Ok(None)
    }

    async fn process_bridge_mode_container(
        &self,
        params: &ProcessContainerParams<'_>,
        container_id: &String,
    ) -> Result<Option<(Host, Vec<Service>)>> {
        let ProcessContainerParams {
            containers_interfaces_and_subnets,
            container,
            container_summary,
            scanned_count,
            discovered_count,
            cancel,
            docker_service_id,
        } = params;

        tracing::info!(
            "Processing bridge mode container {}",
            container
                .name
                .as_ref()
                .unwrap_or(&"Unknown Container Name".to_string())
        );

        scanned_count.fetch_add(1, std::sync::atomic::Ordering::Relaxed);

        let empty_vec_ref = &vec![];

        let container_interfaces_and_subnets = containers_interfaces_and_subnets
            .get(container_id)
            .unwrap_or(empty_vec_ref);

        let (host_ip_to_host_ports, container_ips_to_container_ports, host_to_container_port_map) =
            self.get_ports_from_container(container_summary, container_interfaces_and_subnets);

        for (interface, subnet) in container_interfaces_and_subnets {
            if cancel.is_cancelled() {
                return Err(Error::msg("Discovery was cancelled"));
            }

            let endpoint_responses = if let Some(name) = &container.name {
                self.scan_container_endpoints(
                    interface,
                    &host_to_container_port_map,
                    name.trim_start_matches("/"),
                    cancel.clone(),
                )
                .await?
            } else {
                vec![]
            };

            if !endpoint_responses.is_empty() {
                tracing::debug!(
                    "Found {} endpoint responses for container at {}",
                    endpoint_responses.len(),
                    interface.base.ip_address
                );
            }

            let empty_vec_ref: &Vec<_> = &Vec::new();
            let container_ports_on_interface = container_ips_to_container_ports
                .get(&interface.base.ip_address)
                .unwrap_or(empty_vec_ref);

            if let Ok(Some((mut host, mut services))) = self
                .process_host(
                    ServiceMatchBaselineParams {
                        subnet,
                        interface,
                        all_ports: container_ports_on_interface,
                        endpoint_responses: &endpoint_responses,
                        virtualization: &Some(ServiceVirtualization::Docker(
                            DockerVirtualization {
                                container_name: container
                                    .name
                                    .clone()
                                    .map(|n| n.trim_start_matches("/").to_string()),
                                container_id: container.id.clone(),
                                service_id: **docker_service_id,
                            },
                        )),
                    },
                    None,
                )
                .await
            {
                // Add information that we have from docker context to processed host + services

                host.id = self.domain.host_id;

                // Add all interfaces relevant to container to the host
                container_interfaces_and_subnets.iter().for_each(|(i, _)| {
                    if !host.base.interfaces.contains(i) {
                        host.base.interfaces.push(i.clone())
                    }
                });

                let docker_bridge_subnet_ids: Vec<Uuid> = container_interfaces_and_subnets
                    .iter()
                    .filter(|(_, subnet)| {
                        subnet.base.subnet_type.discriminant()
                            == SubnetTypeDiscriminants::DockerBridge
                    })
                    .map(|(_, subnet)| subnet.id)
                    .collect();

                services.iter_mut().for_each(|s| {
                    // Add all host port + IPs and any container ports which weren't matched
                    // We know they are open on this host even if no services matched them
                    container_ports_on_interface
                        .iter()
                        .for_each(|container_port| {
                            // Add bindings for container ports which weren't matched
                            match host.base.ports.iter().find(|p| p.base == *container_port) {
                                Some(unmatched_container_port)
                                    if !s
                                        .base
                                        .bindings
                                        .iter()
                                        .filter_map(|b| b.port_id())
                                        .any(|port_id| port_id == unmatched_container_port.id) =>
                                {
                                    s.base.bindings.push(Binding::new_port(
                                        unmatched_container_port.id,
                                        Some(interface.id),
                                    ))
                                }
                                _ => (),
                            }
                        });

                    // Add bindings for all host ports, provided there's an interface
                    host_ip_to_host_ports.iter().for_each(|(ip, pbs)| {
                        pbs.iter().for_each(|pb| {
                            // If there's an existing port and existing non-docker bindings, they'll need to be replaced if listener is on all interfaces otherwise there'll be duplicate bindings
                            let (port, existing_non_docker_bindings) =
                                match host.base.ports.iter().find(|p| p.base == *pb) {
                                    // Port exists on host, so get IDs of existing non-Docker bridge service bindings
                                    Some(existing_port) => (
                                        *existing_port,
                                        s.base
                                            .bindings
                                            .iter()
                                            .filter_map(|b| {
                                                if let Some(port_id) = b.port_id()
                                                    && port_id == existing_port.id
                                                {
                                                    // Only include if it's NOT on a Docker bridge
                                                    if let Some(interface) =
                                                        host.get_interface(&b.interface_id())
                                                        && !docker_bridge_subnet_ids
                                                            .contains(&interface.base.subnet_id)
                                                    {
                                                        return Some(b.id());
                                                    }
                                                }
                                                None
                                            })
                                            .collect(),
                                    ),
                                    // Port doesn't exist on host yet, so it can't have been bound by service
                                    None => (Port::new(*pb), vec![]),
                                };

                            // Get host interface
                            let host_interface = host
                                .base
                                .interfaces
                                .iter()
                                .find(|i| i.base.ip_address == *ip);

                            // Add binding to specific interface, or all interfaces if it's on ALL_INTERFACES_IP
                            match host_interface {
                                Some(host_interface) => {
                                    s.base
                                        .bindings
                                        .push(Binding::new_port(port.id, Some(host_interface.id)));
                                    host.base.ports.push(port);
                                }
                                None if *ip == ALL_INTERFACES_IP => {
                                    // Remove existing non-Docker bridge bindings for this port
                                    s.base.bindings = s
                                        .base
                                        .bindings
                                        .iter()
                                        .filter(|b| !existing_non_docker_bindings.contains(&b.id()))
                                        .cloned()
                                        .collect();

                                    // Add bindings for all non-Docker bridge interfaces
                                    for (interface, subnet) in container_interfaces_and_subnets {
                                        if subnet.base.subnet_type.discriminant()
                                            != SubnetTypeDiscriminants::DockerBridge
                                        {
                                            s.base.bindings.push(Binding::new_port(
                                                port.id,
                                                Some(interface.id),
                                            ));
                                        }
                                    }

                                    host.base.ports.push(port);
                                }
                                _ => {}
                            }
                        });
                    });

                    // Remove any interface bindings which are now superceded by port bindings
                    // (interface binding is implicit in port binding)
                    let interface_ids_with_port_binding: Vec<Uuid> = s
                        .base
                        .bindings
                        .clone()
                        .into_iter()
                        .filter_map(|b| {
                            if b.discriminant() == BindingDiscriminants::Port
                                && let Some(interface_id) = b.interface_id()
                            {
                                return Some(interface_id);
                            }
                            None
                        })
                        .collect();

                    s.base.bindings.retain(|b| {
                        b.discriminant() == BindingDiscriminants::Port
                            || !interface_ids_with_port_binding
                                .contains(&b.interface_id().unwrap_or_default())
                    });
                });

                discovered_count.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
                if let Ok((created_host, created_services)) = self.create_host(host, services).await
                {
                    return Ok::<Option<(Host, Vec<Service>)>, Error>(Some((
                        created_host,
                        created_services,
                    )));
                }
                return Ok(None);
            }
        }

        Ok(None)
    }

    pub async fn get_containers_to_scan(&self) -> Result<Vec<ContainerSummary>, Error> {
        let docker = self
            .domain
            .docker_client
            .get()
            .ok_or_else(|| anyhow!("Docker client unavailable"))?;

        docker
            .list_containers(None::<ListContainersOptions>)
            .await
            .map_err(|e| anyhow!(e))
    }

    pub async fn get_subnets_from_docker_networks(
        &self,
        daemon_id: Uuid,
        network_id: Uuid,
    ) -> Result<Vec<Subnet>> {
        let docker = self
            .domain
            .docker_client
            .get()
            .ok_or_else(|| anyhow!("Docker client unavailable"))?;

        let subnets: Vec<Subnet> = docker
            .list_networks(None::<ListNetworksOptions>)
            .await?
            .into_iter()
            .filter_map(|n| {
                let network_name = n.name.clone().unwrap_or("Unknown Network".to_string());
                n.ipam.clone().map(|ipam| (network_name, ipam))
            })
            .filter_map(|(network_name, ipam)| ipam.config.map(|config| (network_name, config)))
            .flat_map(|(network_name, configs)| {
                configs
                    .iter()
                    .filter_map(|c| {
                        if let Some(cidr) = &c.subnet {
                            return Some(Subnet::new(SubnetBase {
                                cidr: IpCidr::from_str(cidr).ok()?,
                                description: None,
                                network_id,
                                name: network_name.clone(),
                                subnet_type: SubnetType::DockerBridge,
                                source: EntitySource::Discovery {
                                    metadata: vec![DiscoveryMetadata::new(
                                        self.discovery_type(),
                                        daemon_id,
                                    )],
                                },
                            }));
                        }
                        None
                    })
                    .collect::<Vec<Subnet>>()
            })
            .collect();

        Ok(subnets)
    }

    pub async fn get_containers_and_summaries(
        &self,
    ) -> Result<Vec<(ContainerInspectResponse, ContainerSummary)>, Error> {
        let docker = self
            .domain
            .docker_client
            .get()
            .ok_or_else(|| anyhow!("Docker client unavailable"))?;

        let container_summaries = self.get_containers_to_scan().await?;

        let containers_to_inspect: Vec<_> = container_summaries
            .iter()
            .filter_map(|c| {
                if let Some(id) = &c.id {
                    return Some(docker.inspect_container(id, None::<InspectContainerOptions>));
                }
                None
            })
            .collect();

        let inspected_containers: Vec<ContainerInspectResponse> =
            try_join_all(containers_to_inspect).await?;

        Ok(inspected_containers
            .into_iter()
            .zip(container_summaries)
            .collect())
    }

    async fn scan_container_endpoints(
        &self,
        interface: &Interface,
        host_to_container_port_map: &HashMap<(IpAddr, u16), u16>,
        container_name: &str,
        cancel: CancellationToken,
    ) -> Result<Vec<EndpointResponse>, Error> {
        use std::collections::HashMap;

        // Build inverse map: (container_port) -> Vec<(host_ip, host_port)>
        let mut container_to_host_port_map: HashMap<u16, Vec<(IpAddr, u16)>> = HashMap::new();
        for ((host_ip, host_port), container_port) in host_to_container_port_map {
            container_to_host_port_map
                .entry(*container_port)
                .or_default()
                .push((*host_ip, *host_port));
        }

        let docker = self
            .domain
            .docker_client
            .get()
            .ok_or_else(|| anyhow!("Docker client unavailable"))?;

        let all_endpoints = Service::all_discovery_endpoints();

        // Group endpoints by (port, path) to avoid duplicate requests
        let mut unique_endpoints: HashMap<(u16, String), Endpoint> = HashMap::new();
        for endpoint in all_endpoints {
            let key = (endpoint.port_base.number(), endpoint.path.clone());
            unique_endpoints.entry(key).or_insert(endpoint);
        }

        tracing::debug!(
            "Scanning {} unique endpoints for container {} at {} using docker exec (deduplicated from {} total)",
            unique_endpoints.len(),
            container_name,
            interface.base.ip_address,
            Service::all_discovery_endpoints().len()
        );

        let mut endpoint_responses = Vec::new();

        // Only make one docker exec per unique (port, path) combination
        for ((container_port, path), endpoint) in unique_endpoints {
            if cancel.is_cancelled() {
                break;
            }

            let url = format!(
                "{}://127.0.0.1:{}{}",
                endpoint.protocol, container_port, path
            );

            // Execute curl with -i to include headers, or wget with -S
            let exec = docker
                .create_exec(
                    container_name,
                    bollard::exec::CreateExecOptions {
                        cmd: Some(vec![
                            "sh",
                            "-c",
                            &format!(
                                "curl -i -s -m 1 -L --max-redirs 2 {} 2>/dev/null || wget -S -q -O- -T 1 {} 2>&1 || echo ''",
                                url, url
                            ),
                        ]),
                        attach_stdout: Some(true),
                        attach_stderr: Some(false),
                        ..Default::default()
                    },
                )
                .await;

            let Ok(exec_result) = exec else {
                continue;
            };

            if let Ok(bollard::exec::StartExecResults::Attached { mut output, .. }) =
                docker.start_exec(&exec_result.id, None).await
            {
                use futures::StreamExt;
                let mut full_response = String::new();

                while let Some(Ok(msg)) = output.next().await {
                    match msg {
                        bollard::container::LogOutput::StdOut { message } => {
                            full_response.push_str(&String::from_utf8_lossy(&message));
                        }
                        bollard::container::LogOutput::StdErr { message } => {
                            // wget outputs headers to stderr with -S flag
                            full_response.push_str(&String::from_utf8_lossy(&message));
                        }
                        _ => {}
                    }
                }

                let full_response = full_response.trim();

                // Parse response to check status code and extract body
                if let Some((status_code, response_body)) = Self::parse_http_response(full_response)
                {
                    // Only accept 2xx-3xx status codes
                    if (199..400).contains(&status_code) {
                        tracing::debug!(
                            "Endpoint {}:{}{} returned status {} for container {}",
                            interface.base.ip_address,
                            container_port,
                            path,
                            status_code,
                            container_name
                        );

                        // Map back to the host-visible endpoint
                        if let Some(host_mappings) = container_to_host_port_map.get(&container_port)
                        {
                            for (host_ip, host_port) in host_mappings {
                                let host_endpoint = Endpoint {
                                    ip: Some(*host_ip),
                                    port_base: PortBase::new_tcp(*host_port),
                                    protocol: endpoint.protocol,
                                    path: path.clone(),
                                };

                                endpoint_responses.push(EndpointResponse {
                                    endpoint: host_endpoint,
                                    response: response_body.clone(),
                                });
                            }
                        }
                    }
                }
            }
        }

        Ok(endpoint_responses)
    }

    /// Parse HTTP response to extract status code and body
    /// Returns (status_code, body) if successful
    fn parse_http_response(response: &str) -> Option<(u16, String)> {
        if response.is_empty() {
            return None;
        }

        let response_bytes = response.as_bytes();

        let mut headers = [httparse::EMPTY_HEADER; 64];
        let mut parsed_response = httparse::Response::new(&mut headers);

        match parsed_response.parse(response_bytes) {
            Ok(httparse::Status::Complete(headers_len)) => {
                let status_code = parsed_response.code?;
                let body = &response_bytes[headers_len..];
                let body_str = String::from_utf8_lossy(body).to_string();

                Some((status_code, body_str))
            }
            Ok(httparse::Status::Partial) => {
                // Not enough data, might be incomplete response
                tracing::debug!("Partial HTTP response received");
                None
            }
            Err(_) => None,
        }
    }

    fn get_ports_from_container(
        &self,
        container_summary: &ContainerSummary,
        container_interfaces_and_subnets: &[(Interface, Subnet)],
    ) -> (IpPortHashMap, IpPortHashMap, HashMap<(IpAddr, u16), u16>) {
        let mut host_ip_to_host_ports: IpPortHashMap = HashMap::new();
        let mut container_ips_to_container_ports: IpPortHashMap = HashMap::new();
        let mut host_to_container_port_map: HashMap<(IpAddr, u16), u16> = HashMap::new();

        let container_ips: Vec<IpAddr> = container_interfaces_and_subnets
            .iter()
            .map(|(i, _)| i.base.ip_address)
            .collect();

        if let Some(ports) = &container_summary.ports {
            ports.iter().for_each(|p| {
                let ip = p.ip.clone().unwrap_or_default().parse::<IpAddr>().ok();

                if let (Some(port_type @ (PortTypeEnum::TCP | PortTypeEnum::UDP)), Some(ip)) =
                    (p.typ, ip)
                {
                    let private_port = match port_type {
                        PortTypeEnum::TCP => PortBase::new_tcp(p.private_port),
                        PortTypeEnum::UDP => PortBase::new_udp(p.private_port),
                        _ => unreachable!("Already matched TCP/UDP in outer pattern"),
                    };

                    container_ips.iter().for_each(|ip| {
                        container_ips_to_container_ports
                            .entry(*ip)
                            .or_default()
                            .push(private_port);
                    });

                    if let Some(public) = p.public_port {
                        let public_port = match port_type {
                            PortTypeEnum::TCP => PortBase::new_tcp(public),
                            PortTypeEnum::UDP => PortBase::new_udp(public),
                            _ => unreachable!("Already matched TCP/UDP in outer pattern"),
                        };

                        host_ip_to_host_ports
                            .entry(ip)
                            .or_default()
                            .push(public_port);

                        host_to_container_port_map.insert((ip, public), p.private_port);
                    }
                }
            });

            return (
                host_ip_to_host_ports,
                container_ips_to_container_ports,
                host_to_container_port_map,
            );
        };

        (
            host_ip_to_host_ports,
            container_ips_to_container_ports,
            host_to_container_port_map,
        )
    }

    fn get_container_interfaces(
        &self,
        containers: &[(ContainerInspectResponse, ContainerSummary)],
        subnets: &[Subnet],
        host_interfaces: &mut [Interface],
    ) -> HashMap<String, Vec<(Interface, Subnet)>> {
        // Created subnets may differ from discovered if there are existing subnets with the same CIDR, so we need to update interface subnet_id references
        let host_interfaces_and_subnets = host_interfaces
            .iter_mut()
            .filter_map(|i| {
                if let Some(subnet) = subnets
                    .iter()
                    .find(|s| s.base.cidr.contains(&i.base.ip_address))
                {
                    i.base.subnet_id = subnet.id;

                    return Some((i.clone(), subnet.clone()));
                }

                None
            })
            .collect::<Vec<(Interface, Subnet)>>();

        // Collect interfaces from containers
        containers
            .iter()
            .filter_map(|(container, _)| {
                let host_networking_mode = container
                    .host_config
                    .as_ref()
                    .and_then(|c| c.network_mode.clone())
                    .unwrap_or_default()
                    == "host";

                let mut interfaces_and_subnets: Vec<(Interface, Subnet)> = if host_networking_mode {
                    host_interfaces_and_subnets.clone()
                }
                // Containers not in host networking mode
                else if let Some(network_settings) = &container.network_settings {
                    if let Some(networks) = &network_settings.networks {
                        networks
                            .iter()
                            .filter_map(|(network_name, endpoint)| {
                                // Parse interface if IP
                                if let Some(ip_string) = &endpoint.ip_address {
                                    let ip_address = ip_string.parse::<IpAddr>().ok();

                                    if let Some(ip_address) = ip_address
                                        && let Some(subnet) = subnets
                                            .iter()
                                            .find(|s| s.base.cidr.contains(&ip_address))
                                    {
                                        // Parse MAC address
                                        let mac_address =
                                            if let Some(mac_string) = &endpoint.mac_address {
                                                mac_string.parse::<MacAddress>().ok()
                                            } else {
                                                None
                                            };

                                        return Some((
                                            Interface::new(InterfaceBase {
                                                subnet_id: subnet.id,
                                                ip_address,
                                                mac_address,
                                                name: Some(network_name.to_owned()),
                                            }),
                                            subnet.clone(),
                                        ));
                                    }
                                }
                                tracing::warn!(
                                    "No matching subnet found for container {:?} on network '{}'",
                                    container.name,
                                    network_name
                                );

                                None
                            })
                            .collect::<Vec<(Interface, Subnet)>>()
                    } else {
                        Vec::new()
                    }
                } else {
                    Vec::new()
                };

                // Merge in host interfaces
                interfaces_and_subnets.extend(host_interfaces_and_subnets.clone());

                container
                    .id
                    .as_ref()
                    .map(|id| (id.clone(), interfaces_and_subnets))
            })
            .collect()
    }
}
