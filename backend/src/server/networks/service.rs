use crate::server::{
    hosts::service::HostService,
    networks::r#impl::Network,
    shared::{
        services::traits::CrudService,
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
    ) -> Self {
        Self {
            network_storage,
            host_service,
            subnet_service,
        }
    }

    pub async fn seed_default_data(&self, network_id: Uuid) -> Result<()> {
        tracing::info!("Seeding default data...");

        let wan_subnet = create_wan_subnet(network_id);
        let remote_subnet = create_remote_subnet(network_id);
        let (dns_host, dns_service) = create_public_dns_host(&wan_subnet, network_id);
        let (web_host, web_service) = create_internet_connectivity_host(&wan_subnet, network_id);
        let (remote_host, client_service) = create_remote_host(&remote_subnet, network_id);

        self.subnet_service.create(wan_subnet).await?;
        self.subnet_service.create(remote_subnet).await?;
        self.host_service
            .create_host_with_services(dns_host, vec![dns_service])
            .await?;
        self.host_service
            .create_host_with_services(web_host, vec![web_service])
            .await?;
        self.host_service
            .create_host_with_services(remote_host, vec![client_service])
            .await?;

        tracing::info!("Default data seeded successfully");

        Ok(())
    }
}
