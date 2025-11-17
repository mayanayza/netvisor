use anyhow::{Context, Error, Result};
use async_fs;
use directories_next::ProjectDirs;
use figment::{
    Figment,
    providers::{Env, Format, Json, Serialized},
};
use serde::{Deserialize, Serialize};
use std::{path::PathBuf, sync::Arc};
use tokio::sync::RwLock;
use uuid::Uuid;

/// CLI arguments structure (for figment integration)
#[derive(Debug)]
pub struct CliArgs {
    pub server_target: Option<String>,
    pub server_port: Option<u16>,
    pub network_id: Option<Uuid>,
    pub daemon_port: Option<u16>,
    pub name: Option<String>,
    pub bind_address: Option<String>,
    pub log_level: Option<String>,
    pub heartbeat_interval: Option<u64>,
    pub concurrent_scans: Option<usize>,
    pub daemon_api_key: Option<String>,
    pub docker_proxy: Option<String>,
    pub allow_self_signed_certs: Option<bool>,
}

/// Unified configuration struct that handles both startup and runtime config
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct AppConfig {
    // Server connection
    pub server_target: Option<String>,
    pub network_id: Option<Uuid>,
    pub server_port: u16,

    // Daemon settings
    pub daemon_port: u16,
    pub name: String,
    pub log_level: String,
    pub heartbeat_interval: u64,
    pub bind_address: String,
    pub concurrent_scans: usize,

    // Runtime state
    pub id: Uuid,
    pub last_heartbeat: Option<chrono::DateTime<chrono::Utc>>,
    pub host_id: Option<Uuid>,
    pub daemon_api_key: Option<String>,
    pub docker_proxy: Option<String>,
    pub allow_self_signed_certs: Option<bool>,
}

impl Default for AppConfig {
    fn default() -> Self {
        Self {
            server_target: None,
            network_id: None,
            server_port: 60072,
            daemon_port: 60073,
            bind_address: "0.0.0.0".to_string(),
            name: "netvisor-daemon".to_string(),
            log_level: "info".to_string(),
            heartbeat_interval: 30,
            id: Uuid::new_v4(),
            last_heartbeat: None,
            host_id: None,
            daemon_api_key: None,
            concurrent_scans: 15,
            docker_proxy: None,
            allow_self_signed_certs: None,
        }
    }
}

impl AppConfig {
    pub fn get_config_path() -> Result<(bool, PathBuf)> {
        let proj_dirs = ProjectDirs::from("com", "netvisor", "daemon")
            .ok_or_else(|| anyhow::anyhow!("Unable to determine config directory"))?;

        let config_path = proj_dirs.config_dir().join("config.json");
        Ok((config_path.exists(), config_path))
    }
    pub fn load(cli_args: CliArgs) -> anyhow::Result<Self> {
        let (config_exists, config_path) = AppConfig::get_config_path()?;

        // Standard configuration layering: Defaults → Config file → Env → CLI (highest priority)
        let mut figment = Figment::from(Serialized::defaults(AppConfig::default()));

        // Add config file if it exists
        if config_exists {
            figment = figment.merge(Json::file(&config_path));
        }

        // Add environment variables
        figment = figment.merge(Env::prefixed("NETVISOR_"));

        // Add CLI overrides (highest priority) - only if explicitly provided
        if let Some(server_target) = cli_args.server_target {
            figment = figment.merge(("server_target", server_target));
        }
        if let Some(network_id) = cli_args.network_id {
            figment = figment.merge(("network_id", network_id));
        }
        if let Some(server_port) = cli_args.server_port {
            figment = figment.merge(("server_port", server_port));
        }
        if let Some(daemon_port) = cli_args.daemon_port {
            figment = figment.merge(("daemon_port", daemon_port));
        }
        if let Some(name) = cli_args.name {
            figment = figment.merge(("name", name));
        }
        if let Some(log_level) = cli_args.log_level {
            figment = figment.merge(("log_level", log_level));
        }
        if let Some(heartbeat_interval) = cli_args.heartbeat_interval {
            figment = figment.merge(("heartbeat_interval", heartbeat_interval));
        }
        if let Some(bind_address) = cli_args.bind_address {
            figment = figment.merge(("bind_address", bind_address));
        }
        if let Some(concurrent_scans) = cli_args.concurrent_scans {
            figment = figment.merge(("concurrent_scans", concurrent_scans));
        }
        if let Some(daemon_api_key) = cli_args.daemon_api_key {
            figment = figment.merge(("daemon_api_key", daemon_api_key));
        }
        if let Some(docker_proxy) = cli_args.docker_proxy {
            figment = figment.merge(("docker_proxy", docker_proxy));
        }
        if let Some(allow_self_signed_certs) = cli_args.allow_self_signed_certs {
            figment = figment.merge(("allow_self_signed_certs", allow_self_signed_certs));
        }

        let config: AppConfig = figment
            .extract()
            .map_err(|e| Error::msg(format!("Configuration error: {}", e)))?;

        Ok(config)
    }
}

pub struct ConfigStore {
    path: PathBuf,
    config: Arc<RwLock<AppConfig>>,
}

impl ConfigStore {
    pub fn new(path: PathBuf, initial_config: AppConfig) -> Self {
        Self {
            path,
            config: Arc::new(RwLock::new(initial_config)),
        }
    }

    pub async fn initialize(&self) -> Result<()> {
        // Ensure parent directory exists
        if let Some(parent) = self.path.parent() {
            async_fs::create_dir_all(parent)
                .await
                .context("Failed to create config directory")?;
        }

        // Load existing config if it exists and merge with current config
        if self.path.exists() {
            self.load().await?;
        } else {
            tracing::info!("No existing runtime config found, will create new on first save");
        }

        Ok(())
    }

    async fn load(&self) -> Result<()> {
        let content = async_fs::read_to_string(&self.path)
            .await
            .context("Failed to read config file")?;

        let loaded_config: AppConfig =
            serde_json::from_str(&content).context("Failed to parse config file")?;

        // Merge loaded runtime state with current config
        let mut config = self.config.write().await;
        config.id = loaded_config.id;
        config.last_heartbeat = loaded_config.last_heartbeat;

        tracing::info!("Loaded daemon runtime state from {}", self.path.display());
        Ok(())
    }

    async fn save(&self, config: &AppConfig) -> Result<()> {
        let json = serde_json::to_string_pretty(config).context("Failed to serialize config")?;

        // Atomic write: write to temp file then rename
        let temp_path = self.path.with_extension("tmp");

        async_fs::write(&temp_path, json)
            .await
            .context("Failed to write temp config file")?;

        async_fs::rename(&temp_path, &self.path)
            .await
            .context("Failed to move temp config to final location")?;

        Ok(())
    }

    pub async fn get_id(&self) -> Result<Uuid> {
        let config = self.config.read().await;
        Ok(config.id)
    }

    pub async fn set_id(&self, id: Uuid) -> Result<()> {
        let mut config = self.config.write().await;
        config.id = id;
        self.save(&config.clone()).await
    }

    pub async fn get_api_key(&self) -> Result<Option<String>> {
        let config = self.config.read().await;
        Ok(config.daemon_api_key.clone())
    }

    pub async fn set_api_key(&self, api_key: String) -> Result<()> {
        let mut config = self.config.write().await;
        config.daemon_api_key = Some(api_key);
        self.save(&config.clone()).await
    }

    pub async fn get_host_id(&self) -> Result<Option<Uuid>> {
        let config = self.config.read().await;
        Ok(config.host_id)
    }

    pub async fn set_host_id(&self, host_id: Uuid) -> Result<()> {
        let mut config = self.config.write().await;
        config.host_id = Some(host_id);
        self.save(&config.clone()).await
    }

    pub async fn get_port(&self) -> Result<u16> {
        let config = self.config.read().await;
        Ok(config.daemon_port)
    }

    pub async fn set_port(&self, port: u16) -> Result<()> {
        let mut config = self.config.write().await;
        config.daemon_port = port;
        self.save(&config.clone()).await
    }

    pub async fn get_bind_address(&self) -> Result<String> {
        let config = self.config.read().await;
        Ok(config.bind_address.clone())
    }

    pub async fn set_network_id(&self, network_id: Uuid) -> Result<()> {
        let mut config = self.config.write().await;
        config.network_id = Some(network_id);
        self.save(&config.clone()).await
    }

    pub async fn get_network_id(&self) -> Result<Option<Uuid>> {
        let config = self.config.read().await;

        Ok(config.network_id)
    }

    pub async fn get_server_endpoint(&self) -> Result<String> {
        let config = self.config.read().await;

        if let Some(ip) = &config.server_target {
            Ok(format!("{}:{}", ip, config.server_port))
        } else {
            Err(Error::msg("No IP configured for server"))
        }
    }

    pub async fn get_concurrent_scans(&self) -> Result<usize> {
        let config = self.config.read().await;
        Ok(config.concurrent_scans)
    }

    pub async fn get_docker_proxy(&self) -> Result<Option<String>> {
        let config = self.config.read().await;
        Ok(config.docker_proxy.clone())
    }

    pub fn get_allow_self_signed_certs(&self) -> Result<Option<bool>> {
        let config = self.config.try_read()?;
        Ok(config.allow_self_signed_certs)
    }

    pub async fn get_heartbeat_interval(&self) -> Result<u64> {
        let config = self.config.read().await;
        Ok(config.heartbeat_interval)
    }

    pub async fn update_heartbeat(&self) -> Result<()> {
        let mut config = self.config.write().await;
        config.last_heartbeat = Some(chrono::Utc::now());
        self.save(&config.clone()).await
    }

    pub async fn get_config(&self) -> AppConfig {
        let config = self.config.read().await;
        config.clone()
    }
}

#[cfg(test)]
mod tests {
    use std::path::Path;

    use serial_test::serial;

    use crate::{daemon::shared::storage::AppConfig, tests::DAEMON_CONFIG_FIXTURE};

    #[test]
    #[serial]
    fn test_daemon_config_backward_compatibility() {
        // Try to load config from fixture (from latest release)
        let config_path = Path::new(DAEMON_CONFIG_FIXTURE);

        if config_path.exists() {
            println!("Testing backward compatibility with fixture from latest release");
            let config_json =
                std::fs::read_to_string(config_path).expect("Failed to read daemon config fixture");

            let loaded: Result<AppConfig, _> = serde_json::from_str(&config_json);

            assert!(
                loaded.is_ok(),
                "Failed to load daemon config from latest release: {:?}",
                loaded.err()
            );

            let config = loaded.unwrap();

            // Verify required fields exist
            assert!(!config.name.is_empty(), "Config name is empty");
            assert!(config.daemon_port > 0, "Config port is invalid");
        } else {
            println!(
                "⚠️  No daemon config fixture found at {}",
                DAEMON_CONFIG_FIXTURE
            );
            println!("   Run release workflow to generate fixtures");

            assert!(false, "Failed to load config fixture");
        }
    }
}
