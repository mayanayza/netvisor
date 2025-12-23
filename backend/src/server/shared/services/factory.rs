use crate::server::{
    api_keys::service::ApiKeyService,
    auth::{oidc::OidcService, service::AuthService},
    billing::service::{BillingService, BillingServiceParams},
    bindings::{r#impl::base::Binding, service::BindingService},
    config::ServerConfig,
    daemons::service::DaemonService,
    discovery::service::DiscoveryService,
    email::{plunk::PlunkEmailProvider, smtp::SmtpEmailProvider, traits::EmailService},
    group_bindings::GroupBindingStorage,
    groups::service::GroupService,
    hosts::service::HostService,
    interfaces::service::InterfaceService,
    invites::service::InviteService,
    logging::service::LoggingService,
    networks::service::NetworkService,
    organizations::service::OrganizationService,
    ports::service::PortService,
    services::service::ServiceService,
    shared::{
        events::bus::EventBus,
        storage::{child::GenericChildStorage, factory::StorageFactory},
    },
    shares::service::ShareService,
    subnets::service::SubnetService,
    tags::service::TagService,
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
    pub interface_service: Arc<InterfaceService>,
    pub group_service: Arc<GroupService>,
    pub subnet_service: Arc<SubnetService>,
    pub daemon_service: Arc<DaemonService>,
    pub topology_service: Arc<TopologyService>,
    pub service_service: Arc<ServiceService>,
    pub discovery_service: Arc<DiscoveryService>,
    pub api_key_service: Arc<ApiKeyService>,
    pub organization_service: Arc<OrganizationService>,
    pub invite_service: Arc<InviteService>,
    pub share_service: Arc<ShareService>,
    pub oidc_service: Option<Arc<OidcService>>,
    pub billing_service: Option<Arc<BillingService>>,
    pub email_service: Option<Arc<EmailService>>,
    pub event_bus: Arc<EventBus>,
    pub logging_service: Arc<LoggingService>,
    pub tag_service: Arc<TagService>,
    pub port_service: Arc<PortService>,
    pub binding_service: Arc<BindingService>,
}

impl ServiceFactory {
    pub async fn new(storage: &StorageFactory, config: Option<ServerConfig>) -> Result<Self> {
        let event_bus = Arc::new(EventBus::new());

        let logging_service = Arc::new(LoggingService::new());

        let api_key_service = Arc::new(ApiKeyService::new(
            storage.api_keys.clone(),
            event_bus.clone(),
        ));
        let daemon_service = Arc::new(DaemonService::new(
            storage.daemons.clone(),
            event_bus.clone(),
        ));
        let group_binding_storage = Arc::new(GroupBindingStorage::new(storage.pool.clone()));
        let group_service = Arc::new(GroupService::new(
            storage.groups.clone(),
            group_binding_storage,
            event_bus.clone(),
        ));
        let organization_service = Arc::new(OrganizationService::new(
            storage.organizations.clone(),
            event_bus.clone(),
        ));
        let invite_service = Arc::new(InviteService::new(
            storage.invites.clone(),
            event_bus.clone(),
        ));

        let share_service = Arc::new(ShareService::new(storage.shares.clone(), event_bus.clone()));

        let tag_service = Arc::new(TagService::new(storage.tags.clone(), event_bus.clone()));

        let port_service = Arc::new(PortService::new(storage.ports.clone(), event_bus.clone()));
        let binding_service = Arc::new(BindingService::new(
            storage.bindings.clone(),
            event_bus.clone(),
        ));

        // Already implements Arc internally due to scheduler + sessions
        let discovery_service = DiscoveryService::new(
            storage.discovery.clone(),
            daemon_service.clone(),
            event_bus.clone(),
        )
        .await?;

        let binding_storage = Arc::new(GenericChildStorage::<Binding>::new(storage.pool.clone()));

        let service_service = Arc::new(ServiceService::new(
            storage.services.clone(),
            binding_storage,
            group_service.clone(),
            event_bus.clone(),
        ));

        // InterfaceService must be created before HostService
        let interface_service = Arc::new(InterfaceService::new(
            storage.interfaces.clone(),
            event_bus.clone(),
        ));

        let host_service = Arc::new(HostService::new(
            storage.hosts.clone(),
            interface_service.clone(),
            port_service.clone(),
            service_service.clone(),
            daemon_service.clone(),
            event_bus.clone(),
        ));

        let subnet_service = Arc::new(SubnetService::new(
            storage.subnets.clone(),
            event_bus.clone(),
        ));

        // ServiceService needs HostService for circular reference
        let _ = service_service.set_host_service(host_service.clone());

        let topology_service = Arc::new(TopologyService::new(
            host_service.clone(),
            interface_service.clone(),
            subnet_service.clone(),
            group_service.clone(),
            service_service.clone(),
            storage.topologies.clone(),
            event_bus.clone(),
        ));

        let network_service = Arc::new(NetworkService::new(
            storage.networks.clone(),
            host_service.clone(),
            subnet_service.clone(),
            event_bus.clone(),
        ));

        let user_service = Arc::new(UserService::new(
            storage.users.clone(),
            event_bus.clone(),
            storage.pool.clone(),
        ));

        let email_service = config.clone().and_then(|c| {
            // Prefer Plunk if API key is provided
            if let Some(plunk_secret) = c.plunk_secret
                && let Some(plunk_key) = c.plunk_key
            {
                let provider = Box::new(PlunkEmailProvider::new(plunk_secret, plunk_key));
                return Some(Arc::new(EmailService::new(provider, user_service.clone())));
            }

            // Fall back to SMTP
            if let (Some(smtp_username), Some(smtp_password), Some(smtp_email), Some(smtp_relay)) =
                (c.smtp_username, c.smtp_password, c.smtp_email, c.smtp_relay)
            {
                let provider =
                    SmtpEmailProvider::new(smtp_username, smtp_password, smtp_email, smtp_relay)
                        .ok()?;
                return Some(Arc::new(EmailService::new(
                    Box::new(provider),
                    user_service.clone(),
                )));
            }

            None
        });

        let billing_service = config.clone().and_then(|c| {
            if let Some(stripe_secret) = c.stripe_secret
                && let Some(webhook_secret) = c.stripe_webhook_secret
            {
                return Some(Arc::new(BillingService::new(BillingServiceParams {
                    stripe_secret,
                    webhook_secret,
                    organization_service: organization_service.clone(),
                    invite_service: invite_service.clone(),
                    user_service: user_service.clone(),
                    network_service: network_service.clone(),
                    share_service: share_service.clone(),
                    event_bus: event_bus.clone(),
                })));
            }
            None
        });

        let auth_service = Arc::new(AuthService::new(
            user_service.clone(),
            organization_service.clone(),
            email_service.clone(),
            event_bus.clone(),
        ));

        let oidc_service = config.and_then(|c| {
            if let Some(oidc_providers) = c.oidc_providers {
                return Some(Arc::new(OidcService::new(
                    oidc_providers,
                    &c.public_url,
                    auth_service.clone(),
                    user_service.clone(),
                    event_bus.clone(),
                )));
            }
            None
        });

        // Register services that implement event bus subscriber
        event_bus
            .register_subscriber(topology_service.clone())
            .await;

        event_bus.register_subscriber(logging_service.clone()).await;
        event_bus
            .register_subscriber(organization_service.clone())
            .await;

        if let Some(billing_service) = billing_service.clone() {
            event_bus.register_subscriber(billing_service).await;
        }

        if let Some(email_service) = email_service.clone() {
            event_bus.register_subscriber(email_service).await;
        }

        Ok(Self {
            user_service,
            auth_service,
            network_service,
            host_service,
            interface_service,
            group_service,
            subnet_service,
            daemon_service,
            topology_service,
            service_service,
            discovery_service,
            api_key_service,
            organization_service,
            invite_service,
            share_service,
            oidc_service,
            billing_service,
            email_service,
            event_bus,
            logging_service,
            tag_service,
            port_service,
            binding_service,
        })
    }
}
