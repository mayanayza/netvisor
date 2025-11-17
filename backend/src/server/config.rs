use crate::server::shared::services::factory::ServiceFactory;
use anyhow::{Error, Result};
use figment::{
    Figment,
    providers::{Env, Serialized},
};
use serde::{Deserialize, Serialize};
use std::{path::PathBuf, sync::Arc};

use crate::server::shared::storage::factory::StorageFactory;

/// CLI arguments structure (for figment integration)
#[derive(Debug)]
pub struct CliArgs {
    pub server_port: Option<u16>,
    pub log_level: Option<String>,
    pub rust_log: Option<String>,
    pub database_url: Option<String>,
    pub integrated_daemon_url: Option<String>,
    pub use_secure_session_cookies: Option<bool>,
    pub disable_registration: bool,
    pub oidc_issuer_url: Option<String>,
    pub oidc_client_id: Option<String>,
    pub oidc_client_secret: Option<String>,
    pub oidc_redirect_url: Option<String>,
    pub oidc_provider_name: Option<String>,
    pub stripe_secret: Option<String>,
    pub stripe_webhook_secret: Option<String>,
    pub smtp_username: Option<String>,
    pub smtp_password: Option<String>,
    pub smtp_relay: Option<String>,
    pub smtp_email: Option<String>,
    pub public_url: Option<String>,
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

    /// Public URL for server for email links, webhooks, etc
    pub public_url: String,

    /// URL for daemon running in same docker stack or in other local context
    pub integrated_daemon_url: Option<String>,

    /// Use secure with issued session cookies
    pub use_secure_session_cookies: bool,

    /// Disable user registration endpoint
    pub disable_registration: bool,

    /// OIDC issuer URL
    pub oidc_issuer_url: Option<String>,

    /// OIDC client ID
    pub oidc_client_id: Option<String>,

    /// OIDC client secret
    pub oidc_client_secret: Option<String>,

    /// OIDC redirect url
    pub oidc_redirect_url: Option<String>,

    /// OIDC redirect url
    pub oidc_provider_name: Option<String>,

    /// Stripe key
    pub stripe_key: Option<String>,

    /// Stripe Secret
    pub stripe_secret: Option<String>,

    pub stripe_webhook_secret: Option<String>,

    pub smtp_username: Option<String>,

    pub smtp_password: Option<String>,

    pub smtp_relay: Option<String>,

    pub smtp_email: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct PublicConfigResponse {
    pub server_port: u16,
    pub disable_registration: bool,
    pub oidc_enabled: bool,
    pub oidc_provider_name: String,
    pub billing_enabled: bool,
    pub has_integrated_daemon: bool,
    pub has_email_service: bool,
    pub public_url: String,
}

impl Default for ServerConfig {
    fn default() -> Self {
        Self {
            server_port: 60072,
            log_level: "info".to_string(),
            rust_log: "".to_string(),
            database_url: "postgresql://postgres:password@localhost:5432/netvisor".to_string(),
            public_url: "http://localhost:60072".to_string(),
            web_external_path: None,
            use_secure_session_cookies: false,
            integrated_daemon_url: None,
            disable_registration: false,
            oidc_client_id: None,
            oidc_client_secret: None,
            oidc_issuer_url: None,
            oidc_redirect_url: None,
            oidc_provider_name: None,
            stripe_key: None,
            stripe_secret: None,
            stripe_webhook_secret: None,
            smtp_username: None,
            smtp_password: None,
            smtp_email: None,
            smtp_relay: None,
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
        if let Some(oidc_issuer_url) = cli_args.oidc_issuer_url {
            figment = figment.merge(("oidc_issuer_url", oidc_issuer_url));
        }
        if let Some(oidc_client_id) = cli_args.oidc_client_id {
            figment = figment.merge(("oidc_client_id", oidc_client_id));
        }
        if let Some(oidc_client_secret) = cli_args.oidc_client_secret {
            figment = figment.merge(("oidc_client_secret", oidc_client_secret));
        }
        if let Some(oidc_redirect_url) = cli_args.oidc_redirect_url {
            figment = figment.merge(("oidc_redirect_url", oidc_redirect_url));
        }
        if let Some(oidc_provider_name) = cli_args.oidc_provider_name {
            figment = figment.merge(("oidc_provider_name", oidc_provider_name));
        }
        if let Some(stripe_secret) = cli_args.stripe_secret {
            figment = figment.merge(("stripe_secret", stripe_secret));
        }
        if let Some(stripe_webhook_secret) = cli_args.stripe_webhook_secret {
            figment = figment.merge(("stripe_webhook_secret", stripe_webhook_secret));
        }
        if let Some(smtp_username) = cli_args.smtp_username {
            figment = figment.merge(("smtp_username", smtp_username));
        }
        if let Some(smtp_password) = cli_args.smtp_password {
            figment = figment.merge(("smtp_password", smtp_password));
        }
        if let Some(smtp_relay) = cli_args.smtp_relay {
            figment = figment.merge(("smtp_relay", smtp_relay));
        }
        if let Some(smtp_email) = cli_args.smtp_email {
            figment = figment.merge(("smtp_email", smtp_email));
        }
        if let Some(public_url) = cli_args.public_url {
            figment = figment.merge(("public_url", public_url));
        }

        figment = figment.merge(("disable_registration", cli_args.disable_registration));

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
}

impl AppState {
    pub async fn new(config: ServerConfig) -> Result<Arc<Self>, Error> {
        let storage =
            StorageFactory::new(&config.database_url(), config.use_secure_session_cookies).await?;
        let services = ServiceFactory::new(&storage, Some(config.clone())).await?;

        Ok(Arc::new(Self {
            config,
            storage,
            services,
        }))
    }
}
