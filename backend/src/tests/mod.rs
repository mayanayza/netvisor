use crate::server::{
    config::{AppState, ServerConfig},
    daemons::r#impl::{
        api::DaemonCapabilities,
        base::{Daemon, DaemonBase, DaemonMode},
    },
    groups::r#impl::{
        base::{Group, GroupBase},
        types::GroupType,
    },
    hosts::r#impl::base::{Host, HostBase},
    interfaces::r#impl::base::{Interface, InterfaceBase},
    networks::r#impl::{Network, NetworkBase},
    organizations::r#impl::base::{Organization, OrganizationBase},
    ports::r#impl::base::{Port, PortBase, PortType},
    services::{
        definitions::ServiceDefinitionRegistry,
        r#impl::base::{Service, ServiceBase},
    },
    shared::{
        services::factory::ServiceFactory,
        storage::{factory::StorageFactory, traits::StorableEntity},
        types::entities::EntitySource,
    },
    subnets::r#impl::{
        base::{Subnet, SubnetBase},
        types::SubnetType,
    },
    topology::types::edges::EdgeStyle,
    users::r#impl::base::{User, UserBase},
};
use axum::Router;
use chrono::Utc;
use cidr::IpCidr;
use cidr::Ipv4Cidr;
use mac_address::MacAddress;
use sqlx::PgPool;
use std::net::IpAddr;
use std::net::Ipv4Addr;
use std::sync::Arc;
use testcontainers::{ContainerAsync, GenericImage, ImageExt, core::WaitFor, runners::AsyncRunner};
use uuid::Uuid;

pub mod dependencies;

pub const DAEMON_CONFIG_FIXTURE: &str = "src/tests/daemon_config.json";
pub const SERVER_DB_FIXTURE: &str = "src/tests/scanopy.sql";

pub async fn setup_test_db() -> (PgPool, String, ContainerAsync<GenericImage>) {
    let postgres_image = GenericImage::new("postgres", "17-alpine")
        .with_wait_for(WaitFor::message_on_stderr(
            "database system is ready to accept connections",
        ))
        .with_env_var("POSTGRES_PASSWORD", "password")
        .with_env_var("POSTGRES_DB", "scanopy_test");

    let container = postgres_image.start().await.unwrap();

    let port = container.get_host_port_ipv4(5432).await.unwrap();

    let database_url = format!(
        "postgresql://postgres:password@localhost:{}/scanopy_test",
        port
    );

    let pool = PgPool::connect(&database_url).await.unwrap();
    (pool, database_url, container)
}

pub async fn test_storage() -> (StorageFactory, ContainerAsync<GenericImage>) {
    let (pool, database_url, _container) = setup_test_db().await;
    pool.close().await;
    let factory = StorageFactory::new(&database_url, false).await.unwrap();
    (factory, _container)
}

pub fn organization() -> Organization {
    Organization::new(OrganizationBase::default())
}

pub fn user(organization_id: &Uuid) -> User {
    let mut user = User::new(UserBase::default());
    user.base.organization_id = *organization_id;
    user
}

pub fn network(organization_id: &Uuid) -> Network {
    Network::new(NetworkBase::new(*organization_id))
}

pub fn host(network_id: &Uuid) -> Host {
    Host::new(HostBase {
        name: "Test Host".to_string(),
        hostname: Some("test.local".to_string()),
        network_id: *network_id,
        description: None,
        source: EntitySource::System,
        virtualization: None,
        hidden: false,
        tags: Vec::new(),
    })
}

pub fn interface(network_id: &Uuid, subnet_id: &Uuid) -> Interface {
    let random_mac: [u8; 6] = std::array::from_fn(|_| fastrand::u8(1..=255));
    Interface::new(InterfaceBase {
        network_id: *network_id,
        subnet_id: *subnet_id,
        ip_address: IpAddr::V4(Ipv4Addr::new(192, 168, 1, 100)),
        mac_address: Some(MacAddress::new(random_mac)),
        name: Some("eth0".to_string()),
        host_id: Uuid::nil(), // Placeholder - tests will set correct host_id
    })
}

pub fn port(network_id: &Uuid, host_id: &Uuid) -> Port {
    Port::new(PortBase {
        port_type: PortType::default(),
        host_id: *host_id,
        network_id: *network_id,
    })
}

pub fn subnet(network_id: &Uuid) -> Subnet {
    Subnet::new(SubnetBase {
        name: "Test Subnet".to_string(),
        description: None,
        network_id: *network_id,
        cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(192, 168, 1, 0), 24).unwrap()),
        subnet_type: SubnetType::Lan,
        source: EntitySource::System,
        tags: Vec::new(),
    })
}

pub fn service(network_id: &Uuid, host_id: &Uuid) -> Service {
    let service_def = ServiceDefinitionRegistry::find_by_id("Dns Server")
        .unwrap_or_else(|| ServiceDefinitionRegistry::all_service_definitions()[0].clone());

    Service::new(ServiceBase {
        name: "Test Service".to_string(),
        host_id: *host_id,
        bindings: vec![],
        network_id: *network_id,
        service_definition: service_def,
        virtualization: None,
        source: EntitySource::System,
        tags: Vec::new(),
    })
}

pub fn group(network_id: &Uuid) -> Group {
    Group::new(GroupBase {
        name: "Test Group".to_string(),
        description: None,
        network_id: *network_id,
        color: "".to_string(),
        group_type: GroupType::RequestPath,
        binding_ids: vec![],
        source: EntitySource::System,
        edge_style: EdgeStyle::Bezier,
        tags: Vec::new(),
    })
}

pub fn daemon(network_id: &Uuid, host_id: &Uuid) -> Daemon {
    Daemon::new(DaemonBase {
        host_id: *host_id,
        network_id: *network_id,
        tags: Vec::new(),
        name: "daemon".to_string(),
        url: "http://192.168.1.50:60073".to_string(),
        last_seen: Utc::now(),
        mode: DaemonMode::Push,
        capabilities: DaemonCapabilities {
            has_docker_socket: false,
            interfaced_subnet_ids: Vec::new(),
        },
    })
}

pub async fn test_services() -> (StorageFactory, ServiceFactory, ContainerAsync<GenericImage>) {
    let (storage, _container) = test_storage().await;
    let services = ServiceFactory::new(&storage, None).await.unwrap();
    (storage, services, _container)
}
pub async fn setup_test_app() -> Router<Arc<AppState>> {
    let config = ServerConfig::default();

    let state = AppState::new(config).await.unwrap();

    let (router, _openapi) = crate::server::shared::handlers::factory::create_router(state.clone());
    router.with_state(state)
}
