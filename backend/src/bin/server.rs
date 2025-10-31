use std::time::Duration;

use anyhow::Error;
use axum::{Router, http::Method};
use clap::Parser;
use netvisor::{
    daemon::runtime::types::InitializeDaemonRequest,
    server::{
        config::{AppState, CliArgs, ServerConfig},
        discovery::manager::DiscoverySessionManager,
        shared::handlers::create_router,
        users::types::base::{User, UserBase},
    },
};
use tower::ServiceBuilder;
use tower_http::{
    cors::{Any, CorsLayer},
    services::ServeDir,
    trace::TraceLayer,
};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};
use uuid::Uuid;

#[derive(Parser)]
#[command(name = "netvisor-server")]
#[command(about = "NetVisor server")]
struct Cli {
    /// Override server port
    #[arg(long)]
    server_port: Option<u16>,

    /// Override log level
    #[arg(long)]
    log_level: Option<String>,

    /// Override rust system log level
    #[arg(long)]
    rust_log: Option<String>,

    /// Override database path
    #[arg(long)]
    database_url: Option<String>,

    /// Override integrated daemon url
    #[arg(long)]
    integrated_daemon_url: Option<String>,
}

impl From<Cli> for CliArgs {
    fn from(cli: Cli) -> Self {
        Self {
            server_port: cli.server_port,
            log_level: cli.log_level,
            rust_log: cli.rust_log,
            database_url: cli.database_url,
            integrated_daemon_url: cli.integrated_daemon_url,
        }
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let _ = dotenv::dotenv();

    let cli = Cli::parse();
    let cli_args = CliArgs::from(cli);

    // Load configuration using figment
    let config = ServerConfig::load(cli_args)?;
    let listen_addr = format!("0.0.0.0:{}", &config.server_port);
    let web_external_path = config.web_external_path.clone();
    let integrated_daemon_url = config
        .integrated_daemon_url
        .clone()
        .unwrap_or("http://daemon:60073".to_string());

    // Initialize tracing
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::new(format!(
            "netvisor={},server={}",
            config.log_level, config.log_level
        )))
        .with(tracing_subscriber::fmt::layer())
        .init();

    // Create app state
    let state = AppState::new(config, DiscoverySessionManager::new()).await?;
    let user_service = state.services.user_service.clone();
    let daemon_service = state.services.daemon_service.clone();

    // Create discovery cleanup task
    let discovery_cleanup_state = state.clone();
    tokio::spawn(async move {
        let mut interval = tokio::time::interval(tokio::time::Duration::from_secs(300));
        loop {
            interval.tick().await;

            // Check for timeouts (fail sessions running > 10 minutes)
            // discovery_cleanup_state.discovery_manager.check_timeouts(10).await;

            // Clean up old sessions (remove completed sessions > 24 hours old)
            discovery_cleanup_state
                .discovery_manager
                .cleanup_old_sessions(24)
                .await;
        }
    });

    // Create auth session cleanup task
    let auth_cleanup_state = state.clone();
    tokio::spawn(async move {
        let mut interval = tokio::time::interval(Duration::from_secs(15 * 60)); // 15 minutes
        loop {
            interval.tick().await;
            auth_cleanup_state
                .services
                .auth_service
                .cleanup_old_login_attempts()
                .await;
        }
    });

    let session_store = state.storage.sessions.clone();

    // Create router
    let api_router = if let Some(static_path) = &web_external_path {
        Router::new()
            .fallback_service(ServeDir::new(static_path))
            .merge(create_router())
            .layer(session_store)
            .with_state(state)
    } else {
        tracing::info!("Server is not serving web assets due to no web_external_path");
        create_router().layer(session_store).with_state(state)
    };

    // Create main app
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

    let listener = tokio::net::TcpListener::bind(&listen_addr).await?;
    let actual_port = listener.local_addr()?.port();

    tracing::info!("🚀 NetVisor server started successfully");
    if web_external_path.is_some() {
        tracing::info!("📊 Web UI: http://<your-ip>:{}", actual_port);
    }
    tracing::info!("🔧 API: http://<your-ip>:{}/api", actual_port);

    // Spawn server in background
    tokio::spawn(async move {
        axum::serve(listener, app).await.unwrap();
    });

    let all_users = user_service.get_all_users().await?;

    // First load - populate seed data
    if all_users.is_empty() {
        tracing::info!("Populating seed data...");
        let (_, network) = user_service
            .create_user(User::new(UserBase::new_seed()))
            .await?;

        let api_key = daemon_service.generate_api_key();
        daemon_service
            .create_pending_api_key(network.id, api_key.clone())
            .await?;

        initialize_local_daemon(integrated_daemon_url, network.id, api_key).await?;
    } else {
        tracing::debug!("Server already has data, skipping seed data");
    }

    tokio::signal::ctrl_c().await?;

    Ok(())
}

pub async fn initialize_local_daemon(
    daemon_url: String,
    network_id: Uuid,
    api_key: String,
) -> Result<(), Error> {
    let client = reqwest::Client::new();

    match client
        .post(format!("{}/api/initialize", daemon_url))
        .json(&InitializeDaemonRequest {
            network_id,
            api_key,
        })
        .send()
        .await
    {
        Ok(resp) => {
            let status = resp.status();

            if status.is_success() {
                tracing::info!("Successfully initialized daemon");
            } else {
                let body = resp
                    .text()
                    .await
                    .unwrap_or_else(|_| "Could not read body".to_string());
                tracing::warn!("Daemon returned error. Status: {}, Body: {}", status, body);
            }
        }
        Err(e) => {
            tracing::warn!("Failed to reach daemon: {:?}", e);
        }
    }

    Ok(())
}
