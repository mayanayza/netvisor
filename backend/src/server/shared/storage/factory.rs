use anyhow::Result;
use sqlx::{PgPool, Pool, Postgres};
use std::sync::Arc;
use tower_sessions::{Expiry, SessionManagerLayer};
use tower_sessions_sqlx_store::PostgresStore;

use crate::server::{
    api_keys::r#impl::base::ApiKey, bindings::r#impl::base::Binding, daemons::r#impl::base::Daemon,
    discovery::r#impl::base::Discovery, groups::r#impl::base::Group, hosts::r#impl::base::Host,
    interfaces::r#impl::base::Interface, invites::r#impl::base::Invite, networks::r#impl::Network,
    organizations::r#impl::base::Organization, ports::r#impl::base::Port,
    services::r#impl::base::Service, shared::storage::generic::GenericPostgresStorage,
    shares::r#impl::base::Share, subnets::r#impl::base::Subnet, tags::r#impl::base::Tag,
    topology::types::base::Topology, users::r#impl::base::User,
};

pub struct StorageFactory {
    pub pool: PgPool,
    pub sessions: SessionManagerLayer<PostgresStore>,
    pub api_keys: Arc<GenericPostgresStorage<ApiKey>>,
    pub users: Arc<GenericPostgresStorage<User>>,
    pub networks: Arc<GenericPostgresStorage<Network>>,
    pub hosts: Arc<GenericPostgresStorage<Host>>,
    pub interfaces: Arc<GenericPostgresStorage<Interface>>,
    pub groups: Arc<GenericPostgresStorage<Group>>,
    pub daemons: Arc<GenericPostgresStorage<Daemon>>,
    pub subnets: Arc<GenericPostgresStorage<Subnet>>,
    pub services: Arc<GenericPostgresStorage<Service>>,
    pub organizations: Arc<GenericPostgresStorage<Organization>>,
    pub invites: Arc<GenericPostgresStorage<Invite>>,
    pub shares: Arc<GenericPostgresStorage<Share>>,
    pub discovery: Arc<GenericPostgresStorage<Discovery>>,
    pub topologies: Arc<GenericPostgresStorage<Topology>>,
    pub tags: Arc<GenericPostgresStorage<Tag>>,
    pub ports: Arc<GenericPostgresStorage<Port>>,
    pub bindings: Arc<GenericPostgresStorage<Binding>>,
}

pub async fn create_session_store(
    db_pool: Pool<Postgres>,
    use_secure: bool,
) -> Result<SessionManagerLayer<PostgresStore>> {
    let session_store = PostgresStore::new(db_pool.clone());

    session_store.migrate().await?;

    Ok(SessionManagerLayer::new(session_store)
        .with_expiry(Expiry::OnInactivity(time::Duration::days(30))) // 30 days
        .with_name("session_id")
        .with_secure(use_secure)
        .with_http_only(true)
        .with_same_site(tower_sessions::cookie::SameSite::Lax))
}

impl StorageFactory {
    pub async fn new(database_url: &str, use_secure_session_cookies: bool) -> Result<Self> {
        let pool = PgPool::connect(database_url).await?;

        sqlx::migrate!("./migrations").run(&pool).await?;

        let sessions = create_session_store(pool.clone(), use_secure_session_cookies).await?;

        Ok(Self {
            pool: pool.clone(),
            sessions,
            discovery: Arc::new(GenericPostgresStorage::new(pool.clone())),
            organizations: Arc::new(GenericPostgresStorage::new(pool.clone())),
            invites: Arc::new(GenericPostgresStorage::new(pool.clone())),
            shares: Arc::new(GenericPostgresStorage::new(pool.clone())),
            api_keys: Arc::new(GenericPostgresStorage::new(pool.clone())),
            users: Arc::new(GenericPostgresStorage::new(pool.clone())),
            networks: Arc::new(GenericPostgresStorage::new(pool.clone())),
            hosts: Arc::new(GenericPostgresStorage::new(pool.clone())),
            interfaces: Arc::new(GenericPostgresStorage::new(pool.clone())),
            groups: Arc::new(GenericPostgresStorage::new(pool.clone())),
            daemons: Arc::new(GenericPostgresStorage::new(pool.clone())),
            subnets: Arc::new(GenericPostgresStorage::new(pool.clone())),
            services: Arc::new(GenericPostgresStorage::new(pool.clone())),
            topologies: Arc::new(GenericPostgresStorage::new(pool.clone())),
            tags: Arc::new(GenericPostgresStorage::new(pool.clone())),
            ports: Arc::new(GenericPostgresStorage::new(pool.clone())),
            bindings: Arc::new(GenericPostgresStorage::new(pool.clone())),
        })
    }
}
