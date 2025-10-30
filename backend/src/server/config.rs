use anyhow::{Error, Result};
use figment::{
    Figment,
    providers::{Env, Serialized},
};
use serde::{Deserialize, Serialize};
use std::{path::PathBuf, sync::Arc};

use crate::server::discovery::manager::DiscoverySessionManager;
use crate::server::shared::{services::ServiceFactory, types::storage::StorageFactory};

/// CLI arguments structure (for figment integration)
#[derive(Debug)]
pub struct CliArgs {
    pub server_port: Option<u16>,
    pub log_level: Option<String>,
    pub rust_log: Option<String>,
    pub database_url: Option<String>,
    pub integrated_daemon_url: Option<String>,
    pub use_secure_session_cookies: Option<bool>,
}

/// Flattened server configuration struct
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServerConfig {
    // Server settings
    /// What port the server should listen on
    pub server_port: u16,

    /// Level of logs to show
    pub log_level: String,

    /// Rust log level
    pub rust_log: String,

    /// Where database should be located
    pub database_url: String,

    /// Where static web assets are located for serving
    pub web_external_path: Option<PathBuf>,

    /// URL for daemon running in same docker stack or in other local context
    pub integrated_daemon_url: Option<String>,

    /// URL for daemon running in same docker stack or in other local context
    pub use_secure_session_cookies: bool,
}

impl Default for ServerConfig {
    fn default() -> Self {
        Self {
            server_port: 60072,
            log_level: "info".to_string(),
            rust_log: "".to_string(),
            database_url: "postgresql://postgres:password@localhost:5432/netvisor".to_string(),
            web_external_path: None,
            use_secure_session_cookies: false,
            integrated_daemon_url: None,
        }
    }
}

impl ServerConfig {
    pub fn load(cli_args: CliArgs) -> anyhow::Result<Self> {
        // Standard configuration layering: Defaults → Env → CLI (highest priority)
        let mut figment = Figment::from(Serialized::defaults(ServerConfig::default()));

        // Add environment variables with NETVISOR_ prefix
        figment = figment.merge(Env::prefixed("NETVISOR_"));

        // Add CLI overrides (highest priority) - only if explicitly provided
        if let Some(server_port) = cli_args.server_port {
            figment = figment.merge(("server_port", server_port));
        }
        if let Some(log_level) = cli_args.log_level {
            figment = figment.merge(("log_level", log_level));
        }
        if let Some(rust_log) = cli_args.rust_log {
            figment = figment.merge(("rust_log", rust_log));
        }
        if let Some(database_url) = cli_args.database_url {
            figment = figment.merge(("database_url", database_url));
        }
        if let Some(integrated_daemon_url) = cli_args.integrated_daemon_url {
            figment = figment.merge(("integrated_daemon_url", integrated_daemon_url));
        }
        if let Some(use_secure_session_cookies) = cli_args.use_secure_session_cookies {
            figment = figment.merge(("use_secure_session_cookies", use_secure_session_cookies));
        }

        let config: ServerConfig = figment
            .extract()
            .map_err(|e| Error::msg(format!("Configuration error: {}", e)))?;

        Ok(config)
    }

    pub fn database_url(&self) -> String {
        self.database_url.to_string()
    }
}

pub struct AppState {
    pub config: ServerConfig,
    pub storage: StorageFactory,
    pub services: ServiceFactory,
    pub discovery_manager: DiscoverySessionManager,
}

impl AppState {
    pub async fn new(
        config: ServerConfig,
        discovery_manager: DiscoverySessionManager,
    ) -> Result<Arc<Self>, Error> {
        let storage =
            StorageFactory::new(&config.database_url(), config.use_secure_session_cookies).await?;
        let services = ServiceFactory::new(&storage).await?;

        Ok(Arc::new(Self {
            config,
            storage,
            services,
            discovery_manager,
        }))
    }
}
