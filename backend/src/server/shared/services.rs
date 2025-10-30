use crate::server::{
    auth::service::AuthService, daemons::service::DaemonService, groups::service::GroupService,
    hosts::service::HostService, networks::service::NetworkService,
    services::service::ServiceService, shared::types::storage::StorageFactory,
    subnets::service::SubnetService, topology::service::main::TopologyService,
    users::service::UserService,
};
use anyhow::Result;
use std::sync::Arc;

pub struct ServiceFactory {
    pub user_service: Arc<UserService>,
    pub auth_service: Arc<AuthService>,
    pub network_service: Arc<NetworkService>,
    pub host_service: Arc<HostService>,
    pub group_service: Arc<GroupService>,
    pub subnet_service: Arc<SubnetService>,
    pub daemon_service: Arc<DaemonService>,
    pub topology_service: Arc<TopologyService>,
    pub service_service: Arc<ServiceService>,
}

impl ServiceFactory {
    pub async fn new(storage: &StorageFactory) -> Result<Self> {
        let daemon_service = Arc::new(DaemonService::new(storage.daemons.clone()));
        let group_service = Arc::new(GroupService::new(storage.host_groups.clone()));

        let service_service = Arc::new(ServiceService::new(
            storage.services.clone(),
            group_service.clone(),
        ));

        let host_service = Arc::new(HostService::new(
            storage.hosts.clone(),
            service_service.clone(),
            daemon_service.clone(),
        ));

        let subnet_service = Arc::new(SubnetService::new(
            storage.subnets.clone(),
            host_service.clone(),
        ));

        let _ = service_service.set_host_service(host_service.clone());

        let topology_service = Arc::new(TopologyService::new(
            host_service.clone(),
            subnet_service.clone(),
            group_service.clone(),
            service_service.clone(),
        ));

        let network_service = Arc::new(NetworkService::new(
            storage.networks.clone(),
            host_service.clone(),
            subnet_service.clone(),
        ));
        let user_service = Arc::new(UserService::new(
            storage.users.clone(),
            network_service.clone(),
        ));
        let auth_service = Arc::new(AuthService::new(user_service.clone()));

        Ok(Self {
            user_service,
            auth_service,
            network_service,
            host_service,
            group_service,
            subnet_service,
            daemon_service,
            topology_service,
            service_service,
        })
    }
}
