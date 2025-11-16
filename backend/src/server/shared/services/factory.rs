use crate::server::{
    api_keys::service::ApiKeyService,
    auth::{oidc::OidcService, service::AuthService},
    billing::service::BillingService,
    config::ServerConfig,
    daemons::service::DaemonService,
    discovery::service::DiscoveryService,
    groups::service::GroupService,
    hosts::service::HostService,
    networks::service::NetworkService,
    organizations::service::OrganizationService,
    services::service::ServiceService,
    shared::storage::factory::StorageFactory,
    subnets::service::SubnetService,
    topology::service::main::TopologyService,
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
    pub discovery_service: Arc<DiscoveryService>,
    pub api_key_service: Arc<ApiKeyService>,
    pub organization_service: Arc<OrganizationService>,
    pub oidc_service: Option<Arc<OidcService>>,
    pub billing_service: Option<Arc<BillingService>>,
}

impl ServiceFactory {
    pub async fn new(storage: &StorageFactory, config: Option<ServerConfig>) -> Result<Self> {
        let api_key_service = Arc::new(ApiKeyService::new(storage.api_keys.clone()));
        let daemon_service = Arc::new(DaemonService::new(storage.daemons.clone()));
        let group_service = Arc::new(GroupService::new(storage.groups.clone()));
        let organization_service =
            Arc::new(OrganizationService::new(storage.organizations.clone()));

        // Already implements Arc internally due to scheduler + sessions
        let discovery_service =
            DiscoveryService::new(storage.discovery.clone(), daemon_service.clone()).await?;

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
        let user_service = Arc::new(UserService::new(storage.users.clone()));
        let auth_service = Arc::new(AuthService::new(
            user_service.clone(),
            organization_service.clone(),
        ));

        let (oidc_service, billing_service) = if let Some(config) = config {
            let oidc_service = if let (
                Some(issuer_url),
                Some(redirect_url),
                Some(client_id),
                Some(client_secret),
                Some(provider_name),
            ) = (
                &config.oidc_issuer_url,
                &config.oidc_redirect_url,
                &config.oidc_client_id,
                &config.oidc_client_secret,
                &config.oidc_provider_name,
            ) {
                Some(Arc::new(OidcService::new(
                    issuer_url.to_owned(),
                    client_id.to_owned(),
                    client_secret.to_owned(),
                    redirect_url.to_owned(),
                    provider_name.to_owned(),
                    auth_service.clone(),
                )))
            } else {
                None
            };

            let billing_service = config.stripe_secret.map(|s| {
                Arc::new(BillingService::new(
                    s,
                    organization_service.clone(),
                    user_service.clone(),
                ))
            });

            (oidc_service, billing_service)
        } else {
            (None, None)
        };

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
            discovery_service,
            api_key_service,
            organization_service,
            oidc_service,
            billing_service,
        })
    }
}
