use anyhow::Result;
use sqlx::{PgPool, Pool, Postgres};
use std::sync::Arc;
use tower_sessions::{Expiry, SessionManagerLayer};
use tower_sessions_sqlx_store::PostgresStore;

use crate::server::{
    daemons::storage::{DaemonStorage, PostgresDaemonStorage},
    discovery::storage::{DiscoveryStorage, PostgresDiscoveryStorage},
    groups::storage::{GroupStorage, PostgresGroupStorage},
    hosts::storage::{HostStorage, PostgresHostStorage},
    networks::storage::{NetworkStorage, PostgresNetworkStorage},
    services::storage::{PostgresServiceStorage, ServiceStorage},
    subnets::storage::{PostgresSubnetStorage, SubnetStorage},
    users::storage::{PostgresUserStorage, UserStorage},
};

pub struct StorageFactory {
    pub sessions: SessionManagerLayer<PostgresStore>,
    pub users: Arc<dyn UserStorage>,
    pub networks: Arc<dyn NetworkStorage>,
    pub hosts: Arc<dyn HostStorage>,
    pub host_groups: Arc<dyn GroupStorage>,
    pub daemons: Arc<dyn DaemonStorage>,
    pub subnets: Arc<dyn SubnetStorage>,
    pub services: Arc<dyn ServiceStorage>,
    pub discovery: Arc<dyn DiscoveryStorage>,
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
            sessions,
            discovery: Arc::new(PostgresDiscoveryStorage::new(pool.clone())),
            users: Arc::new(PostgresUserStorage::new(pool.clone())),
            networks: Arc::new(PostgresNetworkStorage::new(pool.clone())),
            hosts: Arc::new(PostgresHostStorage::new(pool.clone())),
            host_groups: Arc::new(PostgresGroupStorage::new(pool.clone())),
            daemons: Arc::new(PostgresDaemonStorage::new(pool.clone())),
            subnets: Arc::new(PostgresSubnetStorage::new(pool.clone())),
            services: Arc::new(PostgresServiceStorage::new(pool.clone())),
        })
    }
}
