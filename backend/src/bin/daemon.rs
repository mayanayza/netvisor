use axum::{Router, http::Method};
use clap::Parser;
use scanopy::{
    daemon::{
        runtime::types::DaemonAppState,
        shared::{
            config::{AppConfig, ConfigStore, DaemonCli},
            handlers::create_router,
        },
        utils::base::{DaemonUtils, PlatformDaemonUtils},
    },
    server::daemons::r#impl::base::DaemonMode,
};
use std::{sync::Arc, time::Duration};
use tower::ServiceBuilder;
use tower_http::{
    cors::{Any, CorsLayer},
    trace::TraceLayer,
};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

fn main() -> anyhow::Result<()> {
    let runtime = tokio::runtime::Builder::new_multi_thread()
        .thread_stack_size(4 * 1024 * 1024) // 4MB stack for deep async scanning
        .enable_all()
        .build()?;

    runtime.block_on(async_main())
}

async fn async_main() -> anyhow::Result<()> {
    // Parse CLI and load config
    let cli = DaemonCli::parse();
    let config = AppConfig::load(cli)?;

    // Initialize tracing
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::new(format!(
            "scanopy={},daemon={}",
            config.log_level, config.log_level
        )))
        .with(tracing_subscriber::fmt::layer())
        .init();

    tracing::info!("🤖 Scanopy Daemon v{}", env!("CARGO_PKG_VERSION"));

    let (_, path) = AppConfig::get_config_path()?;
    let path_str = path
        .to_str()
        .unwrap_or("Config path could not be converted to string");

    // Initialize unified storage with full config
    let config_store = Arc::new(ConfigStore::new(path.clone(), config.clone()));
    let utils = PlatformDaemonUtils::new();

    let server_addr = &config_store.get_server_url().await?;
    let network_id = &config_store.get_network_id().await?;
    let api_key = &config_store.get_api_key().await?;
    let mode = &config_store.get_mode().await?;
    let interval = Duration::from_secs(config_store.get_heartbeat_interval().await?);

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

    if *mode == DaemonMode::Push {
        tracing::info!("Daemon running in Push mode");
        tokio::spawn(async move {
            loop {
                if let Err(e) = runtime_service.heartbeat().await {
                    tracing::warn!("Heartbeat task failed: {}, retrying in 30s...", e);
                    tokio::time::sleep(interval).await;
                }
            }
        });
    } else {
        tracing::info!("Daemon running in Pull mode");
        tokio::spawn(async move {
            loop {
                if let Err(e) = runtime_service.request_work().await {
                    tracing::warn!("Work request task failed: {}, retrying in 30s...", e);
                    tokio::time::sleep(interval).await;
                }
            }
        });
    }

    // 7. Keep process alive
    tokio::signal::ctrl_c().await?;
    Ok(())
}
