use std::{sync::Arc, time::Duration};

use axum::{
    Extension, Router,
    http::{HeaderValue, Method},
};
use clap::Parser;
use netvisor::server::{
    billing::types::base::{BillingPlan, BillingRate, Price},
    config::{AppState, CliArgs, ServerConfig},
    organizations::r#impl::base::{Organization, OrganizationBase},
    shared::{
        handlers::{cache::AppCache, factory::create_router},
        services::traits::CrudService,
        storage::{filter::EntityFilter, traits::StorableEntity},
    },
    users::r#impl::base::{User, UserBase},
};
use reqwest::header;
use tower::ServiceBuilder;
use tower_http::{
    cors::CorsLayer,
    services::{ServeDir, ServeFile},
    trace::TraceLayer,
};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

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

    /// Use secure session cookies (if serving UI behind HTTPS)
    #[arg(long)]
    use_secure_session_cookies: Option<bool>,

    /// Enable or disable registration flow
    #[arg(long)]
    disable_registration: bool,

    /// OIDC client ID
    #[arg(long)]
    oidc_client_id: Option<String>,

    /// OIDC client secret
    #[arg(long)]
    oidc_client_secret: Option<String>,

    /// OIDC issuer url
    #[arg(long)]
    oidc_issuer_url: Option<String>,

    /// OIDC issuer url
    #[arg(long)]
    oidc_provider_name: Option<String>,

    /// OIDC redirect url
    #[arg(long)]
    oidc_redirect_url: Option<String>,

    /// OIDC redirect url
    #[arg(long)]
    stripe_secret: Option<String>,

    /// OIDC redirect url
    #[arg(long)]
    stripe_webhook_secret: Option<String>,

    #[arg(long)]
    smtp_username: Option<String>,

    #[arg(long)]
    smtp_password: Option<String>,

    /// Email used as to/from in emails send by NetVisor
    #[arg(long)]
    smtp_email: Option<String>,

    #[arg(long)]
    smtp_relay: Option<String>,

    #[arg(long)]
    smtp_port: Option<String>,

    /// Server URL used in features like password reset and invite links
    #[arg(long)]
    public_url: Option<String>,
}

impl From<Cli> for CliArgs {
    fn from(cli: Cli) -> Self {
        Self {
            server_port: cli.server_port,
            log_level: cli.log_level,
            rust_log: cli.rust_log,
            database_url: cli.database_url,
            integrated_daemon_url: cli.integrated_daemon_url,
            use_secure_session_cookies: cli.use_secure_session_cookies,
            disable_registration: cli.disable_registration,
            oidc_client_id: cli.oidc_client_id,
            oidc_client_secret: cli.oidc_client_secret,
            oidc_issuer_url: cli.oidc_issuer_url,
            oidc_provider_name: cli.oidc_provider_name,
            oidc_redirect_url: cli.oidc_redirect_url,
            stripe_secret: cli.stripe_secret,
            stripe_webhook_secret: cli.stripe_webhook_secret,
            smtp_email: cli.smtp_email,
            smtp_password: cli.smtp_password,
            smtp_relay: cli.smtp_relay,
            smtp_username: cli.smtp_username,
            public_url: cli.public_url,
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

    // Initialize tracing
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::new(format!(
            "netvisor={},server={}",
            config.log_level, config.log_level
        )))
        .with(tracing_subscriber::fmt::layer())
        .init();

    // Create app state
    let state = AppState::new(config).await?;
    let user_service = state.services.user_service.clone();
    let discovery_service = state.services.discovery_service.clone();
    let organization_service = state.services.organization_service.clone();
    let billing_service = state.services.billing_service.clone();

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
                .services
                .discovery_service
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

    // Create invite link cleanup task
    let organization_service_invite_cleanup = organization_service.clone();
    tokio::spawn(async move {
        let mut interval = tokio::time::interval(Duration::from_secs(15 * 60)); // 15 minutes
        loop {
            interval.tick().await;
            organization_service_invite_cleanup.cleanup_expired().await;
        }
    });

    let session_store = state.storage.sessions.clone();

    let api_router = if let Some(static_path) = &web_external_path {
        // First create the API router
        let router = create_router().layer(session_store).with_state(state);

        // Then add static file serving with SPA fallback
        router.fallback_service(
            ServeDir::new(static_path)
                .append_index_html_on_directories(true)
                .fallback(ServeFile::new(format!(
                    "{}/index.html",
                    static_path.display()
                ))),
        )
    } else {
        tracing::info!("Server is not serving web assets due to no web_external_path");
        create_router().layer(session_store).with_state(state)
    };

    let cors = if cfg!(debug_assertions) {
        // Development: Allow localhost with credentials
        CorsLayer::new()
            .allow_origin([
                "http://localhost:5173".parse::<HeaderValue>().unwrap(),
                "http://localhost:60072".parse::<HeaderValue>().unwrap(),
                "http://localhost:60073".parse::<HeaderValue>().unwrap(),
            ])
            .allow_methods([
                Method::GET,
                Method::POST,
                Method::PUT,
                Method::DELETE,
                Method::OPTIONS,
            ])
            .allow_headers([header::CONTENT_TYPE, header::AUTHORIZATION, header::ACCEPT])
            .allow_credentials(true)
    } else {
        // Production: Same-origin, no CORS needed but keep it permissive for future flexibility
        CorsLayer::permissive()
    };

    let app_cache = Arc::new(AppCache::new());

    // Create main app
    let app = Router::new().merge(api_router).layer(
        ServiceBuilder::new()
            .layer(TraceLayer::new_for_http())
            .layer(cors)
            .layer(Extension(app_cache)),
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

    // Start cron for discovery scheduler
    discovery_service.start_scheduler().await?;

    let all_users = user_service.get_all(EntityFilter::unfiltered()).await?;

    if let Some(billing_service) = billing_service {
        billing_service
            .initialize_products(vec![
                BillingPlan::Starter {
                    price: Price {
                        cents: 1499,
                        rate: BillingRate::Month,
                    },
                    trial_days: 0,
                },
                BillingPlan::Pro {
                    price: Price {
                        cents: 2499,
                        rate: BillingRate::Month,
                    },
                    trial_days: 7,
                },
                BillingPlan::Team {
                    price: Price {
                        cents: 9999,
                        rate: BillingRate::Month,
                    },
                    trial_days: 7,
                },
            ])
            .await?;
    }

    // First load - populate user and org
    if all_users.is_empty() {
        let organization = organization_service
            .create(Organization::new(OrganizationBase {
                stripe_customer_id: None,
                plan: None,
                plan_status: None,
                name: "My Organization".to_string(),
                is_onboarded: false,
            }))
            .await?;

        user_service
            .create_user(User::new(UserBase::new_seed(organization.id)))
            .await?;
    } else {
        tracing::debug!("Server already has data, skipping seed data");
    }

    tokio::signal::ctrl_c().await?;

    Ok(())
}
