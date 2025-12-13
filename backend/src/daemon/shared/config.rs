use anyhow::{Context, Error, Result};
use async_fs;
use clap::{Parser, arg, command};
use directories_next::ProjectDirs;
use figment::{
    Figment,
    providers::{Env, Format, Json, Serialized},
};
use serde::{Deserialize, Serialize};
use std::{path::PathBuf, sync::Arc};
use tokio::sync::RwLock;
use uuid::Uuid;

use crate::server::daemons::r#impl::base::DaemonMode;

#[derive(Parser)]
#[command(name = "netvisor-daemon")]
#[command(about = "NetVisor network discovery and test execution daemon")]
pub struct DaemonCli {
    /// Complete Server URL
    #[arg(long)]
    server_url: Option<String>,

    /// Network ID to join
    #[arg(long)]
    network_id: Option<String>,

    /// Port for daemon to listen on
    #[arg(short, long)]
    daemon_port: Option<u16>,

    /// Name for this daemon
    #[arg(long)]
    name: Option<String>,

    /// Logging verbosity
    #[arg(long)]
    log_level: Option<String>,

    /// Seconds between heartbeat updates / work requests (for daemons in pull mode) to server
    #[arg(long)]
    heartbeat_interval: Option<u64>,

    /// IP address to bind daemon to
    #[arg(long)]
    bind_address: Option<String>,

    /// Maximum parallel host scans
    #[arg(long)]
    concurrent_scans: Option<usize>,

    /// API key
    #[arg(long)]
    daemon_api_key: Option<String>,

    /// Optional proxy for Docker API. Can use both non-SSL and SSL proxy; SSL proxy requires additional SSL config vars
    #[arg(long)]
    docker_proxy: Option<String>,

    /// Path to SSL certificate if using a docker proxy with SSL
    #[arg(long)]
    docker_proxy_ssl_cert: Option<String>,

    /// Path to SSL private key if using a docker proxy with SSL
    #[arg(long)]
    docker_proxy_ssl_key: Option<String>,

    /// Path to SSL chain if using a docker proxy with SSL
    #[arg(long)]
    docker_proxy_ssl_chain: Option<String>,

    /// Select whether the daemon will Pull work from the server or have work Pushed to it. If set to Push, you will need to ensure that network you are deploying the daemon on can be reached by the server by opening/forwarding the port to the daemon. If set to Pull, no port opening/forwarding is needed
    #[arg(long)]
    mode: Option<DaemonMode>,

    /// Allow self-signed certs for daemon -> server connections
    #[arg(long)]
    allow_self_signed_certs: Option<bool>,

    /// Public URL where server can reach daemon. Defaults to auto-detected IP + Daemon Port if not set.
    #[arg(long)]
    daemon_url: Option<String>,
}

/// Unified configuration struct that handles both startup and runtime config
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct AppConfig {
    // Server connection
    pub server_url: Option<String>,
    pub network_id: Option<Uuid>,

    // Legacy server connection
    pub server_target: Option<String>,
    pub server_port: Option<u16>,

    // Daemon settings
    pub daemon_port: u16,
    pub name: String,
    pub log_level: String,
    pub heartbeat_interval: u64,
    pub bind_address: String,
    pub concurrent_scans: usize,

    // Runtime state
    pub id: Uuid,
    #[serde(default)]
    pub last_heartbeat: Option<chrono::DateTime<chrono::Utc>>,
    #[serde(default)]
    pub host_id: Option<Uuid>,
    #[serde(default, alias = "daemon_api_key")]
    pub daemon_api_key: Option<String>,
    #[serde(default)]
    pub docker_proxy: Option<String>,
    #[serde(default)]
    pub mode: DaemonMode,
    #[serde(default)]
    allow_self_signed_certs: bool,
    daemon_url: Option<String>,
    #[serde(default)]
    docker_proxy_ssl_cert: Option<String>,
    #[serde(default)]
    docker_proxy_ssl_key: Option<String>,
    #[serde(default)]
    docker_proxy_ssl_chain: Option<String>,
}

impl Default for AppConfig {
    fn default() -> Self {
        Self {
            server_url: None,
            network_id: None,
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
            mode: DaemonMode::Push,
            server_port: None,
            server_target: None,
            allow_self_signed_certs: false,
            daemon_url: None,
            docker_proxy_ssl_cert: None,
            docker_proxy_ssl_chain: None,
            docker_proxy_ssl_key: None,
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
    pub fn load(cli_args: DaemonCli) -> anyhow::Result<Self> {
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
        if let Some(server_url) = cli_args.server_url {
            figment = figment.merge(("server_url", server_url));
        }
        if let Some(network_id) = cli_args.network_id {
            figment = figment.merge(("network_id", network_id));
        }
        if let Some(port) = cli_args.daemon_port {
            figment = figment.merge(("daemon_port", port));
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
        if let Some(api_key) = cli_args.daemon_api_key {
            figment = figment.merge(("daemon_api_key", api_key));
        }
        if let Some(docker_proxy) = cli_args.docker_proxy {
            figment = figment.merge(("docker_proxy", docker_proxy));
        }
        if let Some(docker_proxy_ssl_key) = cli_args.docker_proxy_ssl_key {
            figment = figment.merge(("docker_proxy_ssl_key", docker_proxy_ssl_key));
        }
        if let Some(docker_proxy_ssl_cert) = cli_args.docker_proxy_ssl_cert {
            figment = figment.merge(("docker_proxy_ssl_cert", docker_proxy_ssl_cert));
        }
        if let Some(docker_proxy_ssl_chain) = cli_args.docker_proxy_ssl_chain {
            figment = figment.merge(("docker_proxy_ssl_chain", docker_proxy_ssl_chain));
        }
        if let Some(mode) = cli_args.mode {
            figment = figment.merge(("mode", mode));
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

    pub async fn get_name(&self) -> Result<String> {
        let config = self.config.read().await;
        Ok(config.name.clone())
    }

    pub async fn set_id(&self, id: Uuid) -> Result<()> {
        let mut config = self.config.write().await;
        config.id = id;
        self.save(&config.clone()).await
    }

    pub async fn get_allow_self_signed_certs(&self) -> Result<bool> {
        let config = self.config.read().await;
        Ok(config.allow_self_signed_certs)
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

    pub async fn get_mode(&self) -> Result<DaemonMode> {
        let config = self.config.read().await;
        Ok(config.mode)
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

    pub async fn get_daemon_url(&self) -> Result<Option<String>> {
        let config = self.config.read().await;

        Ok(config.daemon_url.clone())
    }

    pub async fn get_server_url(&self) -> Result<String> {
        let config = self.config.read().await;

        if let Some(server_port) = config.server_port
            && let Some(server_target) = &config.server_target
        {
            Ok(format!("{}:{}", server_target, server_port))
        } else if let Some(server_url) = config.server_url.clone() {
            Ok(server_url)
        } else {
            Err(anyhow::anyhow!("Server URL is not configured"))
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

    pub async fn get_docker_proxy_ssl_info(&self) -> Result<Option<(String, String, String)>> {
        let config = self.config.read().await;

        if let (Some(ssl_cert), Some(ssl_key), Some(ssl_chain)) = (
            config.docker_proxy_ssl_cert.clone(),
            config.docker_proxy_ssl_key.clone(),
            config.docker_proxy_ssl_chain.clone(),
        ) {
            Ok(Some((ssl_cert, ssl_key, ssl_chain)))
        } else {
            Ok(None)
        }
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

    use crate::daemon::shared::config::DaemonCli;
    use crate::{daemon::shared::config::AppConfig, tests::DAEMON_CONFIG_FIXTURE};
    use clap::CommandFactory;
    use comrak::nodes::NodeValue;
    use comrak::{Arena, Options, parse_document};
    use std::collections::HashMap;

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

    #[derive(Debug)]
    struct FieldInfo {
        cli_flag: String,
        env_var: Option<String>,
        help_text: String,
        config_key: String,
    }

    const EXCLUDED_FIELDS: [&str; 5] = [
        "daemon_api_key",
        "network_id",
        "server_url",
        // Legacy fields not exposed in UI
        "server_target",
        "server_port",
    ];

    #[test]
    fn config_fields_are_in_sync() {
        let rust_fields = extract_rust_fields();
        let frontend_fields = extract_frontend_fields();
        let markdown_fields = extract_markdown_fields();

        let mut errors = Vec::new();

        // Check all Rust fields exist in frontend and markdown
        for (id, rust_info) in &rust_fields {
            // Check frontend
            match frontend_fields.get(id) {
                None => errors.push(format!("Field '{}' missing from frontend", id)),
                Some(fe_info) => {
                    if fe_info.cli_flag != rust_info.cli_flag {
                        errors.push(format!(
                            "Field '{}' CLI flag mismatch: rust='{}', frontend='{}'",
                            id, rust_info.cli_flag, fe_info.cli_flag
                        ));
                    }
                    if fe_info.env_var != rust_info.env_var {
                        errors.push(format!(
                            "Field '{}' env var mismatch: rust={:?}, frontend={:?}",
                            id, rust_info.env_var, fe_info.env_var
                        ));
                    }
                    // Normalize whitespace for description comparison
                    let rust_desc = normalize_text(&rust_info.help_text);
                    let fe_desc = normalize_text(&fe_info.help_text);
                    if rust_desc != fe_desc {
                        errors.push(format!(
                            "Field '{}' help text mismatch:\n  rust: '{}'\n  frontend: '{}'",
                            id, rust_desc, fe_desc
                        ));
                    }
                }
            }

            // Check markdown
            match markdown_fields.get(id) {
                None => errors.push(format!("Field '{}' missing from markdown docs", id)),
                Some(md_info) => {
                    if md_info.cli_flag != rust_info.cli_flag {
                        errors.push(format!(
                            "Field '{}' CLI flag mismatch: rust='{}', markdown='{}'",
                            id, rust_info.cli_flag, md_info.cli_flag
                        ));
                    }
                    if md_info.env_var != rust_info.env_var {
                        errors.push(format!(
                            "Field '{}' env var mismatch: rust={:?}, markdown={:?}",
                            id, rust_info.env_var, md_info.env_var
                        ));
                    }

                    let rust_desc = normalize_text(&rust_info.help_text);
                    let md_desc = normalize_text(&md_info.help_text);
                    if rust_desc != md_desc {
                        errors.push(format!(
                            "Field '{}' help text mismatch:\n  rust: '{}'\n  markdown: '{}'",
                            id, rust_desc, md_desc
                        ));
                    }

                    if md_info.config_key != rust_info.config_key {
                        errors.push(format!(
                            "Field '{}' config key mismatch: rust='{}', markdown='{}'",
                            id, rust_info.config_key, md_info.config_key
                        ));
                    }
                }
            }
        }

        // Check for fields in frontend/markdown that aren't in Rust
        for id in frontend_fields.keys() {
            if !rust_fields.contains_key(id) {
                errors.push(format!("Field '{}' in frontend but not in Rust", id));
            }
        }
        for id in markdown_fields.keys() {
            if !rust_fields.contains_key(id) {
                errors.push(format!("Field '{}' in markdown but not in Rust", id));
            }
        }

        assert!(
            errors.is_empty(),
            "Config sync errors:\n{}",
            errors.join("\n")
        );
    }

    fn extract_rust_fields() -> HashMap<String, FieldInfo> {
        let cmd = DaemonCli::command();
        cmd.get_arguments()
            .filter(|a| {
                let id = a.get_id().to_string();
                id != "help" && id != "version" && !EXCLUDED_FIELDS.contains(&id.as_str())
            })
            .map(|a| {
                let id = a.get_id().to_string();

                // Derive env var from field ID using same conversion as Figment
                let env_var = format!("NETVISOR_{}", id.to_uppercase());
                let config_key = cli_id_to_config_key(&id);

                let info = FieldInfo {
                    cli_flag: a.get_long().map(|l| format!("--{}", l)).unwrap_or_default(),
                    env_var: Some(env_var),
                    help_text: a.get_help().map(|h| h.to_string()).unwrap_or_default(),
                    config_key,
                };
                (id, info)
            })
            .collect()
    }

    fn extract_frontend_fields() -> HashMap<String, FieldInfo> {
        let json = include_str!("../../tests/daemon-config-frontend-fields.json");
        let fields: Vec<serde_json::Value> = serde_json::from_str(json).unwrap();

        fields
            .into_iter()
            .filter_map(|v| {
                let id = v.get("id")?.as_str()?.to_string(); // Already snake_case
                let info = FieldInfo {
                    cli_flag: v.get("cliFlag")?.as_str()?.to_string(),
                    env_var: v.get("envVar").and_then(|e| e.as_str()).map(String::from),
                    help_text: v.get("helpText")?.as_str()?.to_string(),
                    config_key: cli_id_to_config_key(&id),
                };
                Some((id, info))
            })
            .collect()
    }

    fn extract_markdown_fields() -> HashMap<String, FieldInfo> {
        let content = include_str!("../../../../docs/CONFIGURATION.md");

        // Extract content between markers
        let start_marker = "<!-- DAEMON_CONFIG_TABLE_START -->";
        let end_marker = "<!-- DAEMON_CONFIG_TABLE_END -->";

        let table_content = content
            .split(start_marker)
            .nth(1)
            .and_then(|s| s.split(end_marker).next())
            .expect("Could not find DAEMON_CONFIG_TABLE markers in docs/config.md");

        let arena = Arena::new();
        let mut options = Options::default();
        options.extension.table = true;

        let root = parse_document(&arena, table_content, &options);

        let mut fields = HashMap::new();

        // Walk the AST to find table rows
        for node in root.descendants() {
            if let NodeValue::Table(_) = node.data.borrow().value {
                let mut is_header = true;
                for row in node.children() {
                    if let NodeValue::TableRow(_) = row.data.borrow().value {
                        if is_header {
                            is_header = false;
                            continue;
                        }

                        let cells: Vec<String> = row
                            .children()
                            .filter_map(|cell| {
                                if let NodeValue::TableCell = cell.data.borrow().value {
                                    Some(extract_text_content(cell))
                                } else {
                                    None
                                }
                            })
                            .collect();

                        // Expected columns: Parameter | CLI Flag | Env Var | Config Key | Default | Description
                        if cells.len() >= 6 {
                            let cli_flag = extract_code_content(&cells[1]);
                            let env_var = extract_code_content(&cells[2]);
                            let config_key = extract_code_content(&cells[3]);
                            let description = cells[5].clone();

                            // Convert CLI flag to field ID: --server-url -> server_url
                            if let Some(id) = cli_flag
                                .strip_prefix("--")
                                .map(|s| s.split(" or ").next().unwrap_or(s))
                                .map(|s| s.replace('-', "_"))
                            {
                                if EXCLUDED_FIELDS.contains(&id.as_str()) {
                                    continue;
                                }

                                fields.insert(
                                    id,
                                    FieldInfo {
                                        cli_flag: format!(
                                            "--{}",
                                            cli_flag
                                                .strip_prefix("--")
                                                .unwrap_or(&cli_flag)
                                                .split(" or ")
                                                .next()
                                                .unwrap_or(&cli_flag)
                                        ),
                                        env_var: if env_var.is_empty() {
                                            None
                                        } else {
                                            Some(env_var)
                                        },
                                        help_text: description,
                                        config_key,
                                    },
                                );
                            }
                        }
                    }
                }
            }
        }

        fields
    }

    // Maps clap arg ID to the actual serde field name in AppConfig
    fn cli_id_to_config_key(cli_id: &str) -> String {
        match cli_id {
            "daemon_port" => "port".to_string(),
            "daemon_api_key" => "api_key".to_string(),
            other => other.to_string(),
        }
    }

    fn extract_text_content<'a>(
        node: &'a comrak::arena_tree::Node<'a, std::cell::RefCell<comrak::nodes::Ast>>,
    ) -> String {
        let mut text = String::new();
        for child in node.descendants() {
            if let NodeValue::Text(t) = &child.data.borrow().value {
                text.push_str(t);
            } else if let NodeValue::Code(c) = &child.data.borrow().value {
                text.push_str(&c.literal);
            }
        }
        text.trim().to_string()
    }

    fn extract_code_content(s: &str) -> String {
        // Extract content from backticks if present
        if s.starts_with('`') && s.ends_with('`') {
            s[1..s.len() - 1].to_string()
        } else {
            s.to_string()
        }
    }

    fn normalize_text(s: &str) -> String {
        s.split_whitespace().collect::<Vec<_>>().join(" ")
    }
}
