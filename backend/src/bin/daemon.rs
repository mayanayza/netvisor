use axum::{Router, http::Method};
use clap::Parser;
use netvisor::daemon::{
    runtime::types::DaemonAppState,
    shared::{
        handlers::create_router,
        storage::{AppConfig, CliArgs, ConfigStore},
    },
    utils::base::{DaemonUtils, PlatformDaemonUtils},
};
use std::sync::Arc;
use tower::ServiceBuilder;
use tower_http::{
    cors::{Any, CorsLayer},
    trace::TraceLayer,
};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};
use uuid::Uuid;

#[derive(Parser)]
#[command(name = "netvisor-daemon")]
#[command(about = "NetVisor network discovery and test execution daemon")]
struct Cli {
    /// Server target (IP or hostname)
    #[arg(long)]
    server_target: Option<String>,

    /// Server port
    #[arg(long)]
    server_port: Option<u16>,

    /// Network ID to join
    #[arg(long)]
    network_id: Option<String>,

    /// Daemon listen port
    #[arg(short, long)]
    daemon_port: Option<u16>,

    /// Daemon listen host
    #[arg(long)]
    host: Option<String>,

    /// Daemon name
    #[arg(long)]
    name: Option<String>,

    /// Log level
    #[arg(long)]
    log_level: Option<String>,

    /// Heartbeat interval in seconds
    #[arg(long)]
    heartbeat_interval: Option<u64>,

    /// Daemon bind address
    #[arg(long)]
    bind_address: Option<String>,

    /// Concurrent scans for discovery
    #[arg(long)]
    concurrent_scans: Option<usize>,

    /// API key
    #[arg(long)]
    daemon_api_key: Option<String>,

    /// Docker socket proxy
    #[arg(long)]
    docker_proxy: Option<String>,
}

impl From<Cli> for CliArgs {
    fn from(cli: Cli) -> Self {
        Self {
            server_target: cli.server_target,
            server_port: cli.server_port,
            daemon_port: cli.daemon_port,
            name: cli.name,
            bind_address: cli.bind_address,
            network_id: cli.network_id.and_then(|s| Uuid::parse_str(&s).ok()),
            log_level: cli.log_level,
            heartbeat_interval: cli.heartbeat_interval,
            concurrent_scans: cli.concurrent_scans,
            daemon_api_key: cli.daemon_api_key,
            docker_proxy: cli.docker_proxy,
        }
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Parse CLI and load config
    let cli = Cli::parse();
    let cli_args = CliArgs::from(cli);
    let config = AppConfig::load(cli_args)?;

    // Initialize tracing
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::new(format!(
            "netvisor={},daemon={}",
            config.log_level, config.log_level
        )))
        .with(tracing_subscriber::fmt::layer())
        .init();

    tracing::info!("🤖 NetVisor daemon starting");

    let (_, path) = AppConfig::get_config_path()?;
    let path_str = path
        .to_str()
        .unwrap_or("Config path could not be converted to string");

    // Initialize unified storage with full config
    let config_store = Arc::new(ConfigStore::new(path.clone(), config.clone()));
    let utils = PlatformDaemonUtils::new();

    let server_addr = &config_store.get_server_endpoint().await?;
    let network_id = &config_store.get_network_id().await?;
    let api_key = &config_store.get_api_key().await?;

    let state = DaemonAppState::new(config_store, utils).await?;
    let runtime_service = state.services.runtime_service.clone();

    // Create HTTP server with config values
    let api_router = create_router().with_state(state);

    let app = Router::new().merge(api_router).layer(
        ServiceBuilder::new()
            .layer(TraceLayer::new_for_http())
            .layer(
                CorsLayer::new()
                    .allow_origin(Any)
                    .allow_methods([Method::GET, Method::POST, Method::PUT, Method::DELETE])
                    .allow_headers(Any),
            ),
    );

    let bind_addr = format!("{}:{}", config.bind_address, config.daemon_port);
    let listener = tokio::net::TcpListener::bind(&bind_addr).await?;

    // Spawn server in background
    tokio::spawn(async move {
        axum::serve(listener, app).await.unwrap();
    });

    tracing::info!("🌐 Listening on: {}", bind_addr);
    tracing::info!("📁 Config file: {:?}", path_str);
    tracing::info!("🔗 Server at {}", server_addr);

    if let Some(network_id) = network_id {
        tracing::info!("Network ID available: {}", network_id);
        if let Some(api_key) = api_key {
            tracing::info!("API key available: [redacted]");
            runtime_service
                .initialize_services(*network_id, api_key.clone())
                .await?;
        } else {
            tracing::warn!(
                "Daemon is missing an API key. Go to discovery tab in UI to generate an API key."
            );
        }
    } else {
        tracing::info!("Missing network ID - waiting for server to hit /api/initialize...");
    }

    // Spawn heartbeat task in background
    tokio::spawn(async move {
        if let Err(e) = runtime_service.heartbeat().await {
            tracing::warn!("Failed to update heartbeat timestamp: {}", e);
        }
    });

    // 7. Keep process alive
    tokio::signal::ctrl_c().await?;
    Ok(())
}
