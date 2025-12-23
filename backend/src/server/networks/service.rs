use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    hosts::service::HostService,
    networks::r#impl::Network,
    shared::{
        events::bus::EventBus,
        services::traits::{CrudService, EventBusService},
        storage::{
            generic::GenericPostgresStorage,
            seed_data::{
                create_internet_connectivity_host, create_public_dns_host, create_remote_host,
                create_remote_subnet, create_wan_subnet,
            },
        },
    },
    subnets::service::SubnetService,
};
use anyhow::Result;
use async_trait::async_trait;
use std::sync::Arc;
use uuid::Uuid;

pub struct NetworkService {
    network_storage: Arc<GenericPostgresStorage<Network>>,
    host_service: Arc<HostService>,
    subnet_service: Arc<SubnetService>,
    event_bus: Arc<EventBus>,
}

impl EventBusService<Network> for NetworkService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, _entity: &Network) -> Option<Uuid> {
        None
    }
    fn get_organization_id(&self, entity: &Network) -> Option<Uuid> {
        Some(entity.base.organization_id)
    }
}

#[async_trait]
impl CrudService<Network> for NetworkService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Network>> {
        &self.network_storage
    }
}

impl NetworkService {
    pub fn new(
        network_storage: Arc<GenericPostgresStorage<Network>>,
        host_service: Arc<HostService>,
        subnet_service: Arc<SubnetService>,
        event_bus: Arc<EventBus>,
    ) -> Self {
        Self {
            network_storage,
            host_service,
            subnet_service,
            event_bus,
        }
    }

    pub async fn seed_default_data(
        &self,
        network_id: Uuid,
        authenticated: AuthenticatedEntity,
    ) -> Result<()> {
        tracing::info!("Seeding default data...");

        let wan_subnet = create_wan_subnet(network_id);
        let remote_subnet = create_remote_subnet(network_id);
        let (dns_host, dns_interfaces, dns_ports, dns_service) =
            create_public_dns_host(&wan_subnet, network_id);
        let (web_host, web_interfaces, web_ports, web_service) =
            create_internet_connectivity_host(&wan_subnet, network_id);
        let (remote_host, remote_interfaces, remote_ports, client_service) =
            create_remote_host(&remote_subnet, network_id);

        self.subnet_service
            .create(wan_subnet, authenticated.clone())
            .await?;
        self.subnet_service
            .create(remote_subnet, authenticated.clone())
            .await?;
        self.host_service
            .discover_host(
                dns_host,
                dns_interfaces,
                dns_ports,
                vec![dns_service],
                authenticated.clone(),
            )
            .await?;
        self.host_service
            .discover_host(
                web_host,
                web_interfaces,
                web_ports,
                vec![web_service],
                authenticated.clone(),
            )
            .await?;
        self.host_service
            .discover_host(
                remote_host,
                remote_interfaces,
                remote_ports,
                vec![client_service],
                authenticated.clone(),
            )
            .await?;

        Ok(())
    }
}
