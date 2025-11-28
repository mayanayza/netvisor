use std::{net::SocketAddr, str::FromStr, sync::Arc, time::Duration};

use axum::{
    Extension, Router,
    http::{HeaderValue, Method},
    middleware,
};
use axum_client_ip::ClientIpSource;
use clap::Parser;
use netvisor::server::{
    auth::middleware::{
        auth::AuthenticatedEntity, logging::request_logging_middleware,
        rate_limit::rate_limit_middleware,
    },
    billing::types::base::{BillingPlan, BillingRate, PlanConfig},
    config::{AppState, ServerCli, ServerConfig},
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
    set_header::SetResponseHeaderLayer,
    trace::TraceLayer,
};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let _ = dotenv::dotenv();

    let cli = ServerCli::parse();

    // Load configuration using figment
    let config = ServerConfig::load(cli)?;
    let listen_addr = format!("0.0.0.0:{}", &config.server_port);
    let web_external_path = config.web_external_path.clone();
    let client_ip_source = config.client_ip_source.clone();

    // Initialize tracing
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::new(format!(
            "netvisor={},server={},request_log={}",
            config.log_level, config.log_level, config.log_level
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

    // Create stalled discovery cleanup task
    let stalled_discovery_cleanup = discovery_service.clone();
    tokio::spawn(async move {
        let mut interval = tokio::time::interval(tokio::time::Duration::from_secs(60)); // Every minute
        loop {
            interval.tick().await;
            stalled_discovery_cleanup.cleanup_stalled_sessions().await;
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

    let base_router = create_router().with_state(state.clone());

    let api_router = if let Some(static_path) = &web_external_path {
        base_router.fallback_service(
            ServeDir::new(static_path)
                .append_index_html_on_directories(true)
                .fallback(ServeFile::new(format!(
                    "{}/index.html",
                    static_path.display()
                ))),
        )
    } else {
        tracing::info!("Server is not serving web assets due to no web_external_path");
        base_router
    };

    let session_store = state.storage.sessions.clone();

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

    let client_ip_source = client_ip_source
        .map(|s| ClientIpSource::from_str(&s))
        .unwrap_or(Ok(ClientIpSource::ConnectInfo))?;

    let cache_headers = SetResponseHeaderLayer::if_not_present(
        header::CACHE_CONTROL,
        HeaderValue::from_static("no-store, no-cache, must-revalidate, private"),
    );

    let app_cache = Arc::new(AppCache::new());

    // Create main app
    let app = Router::new().merge(api_router).layer(
        ServiceBuilder::new()
            .layer(TraceLayer::new_for_http())
            .layer(cors)
            .layer(client_ip_source.into_extension())
            .layer(session_store)
            .layer(middleware::from_fn_with_state(
                state.clone(),
                request_logging_middleware,
            ))
            .layer(middleware::from_fn_with_state(
                state.clone(),
                rate_limit_middleware,
            ))
            .layer(Extension(app_cache))
            .layer(cache_headers),
    );
    let listener = tokio::net::TcpListener::bind(&listen_addr).await?;
    let actual_port = listener.local_addr()?.port();

    tracing::info!("🚀 NetVisor Server v{}", env!("CARGO_PKG_VERSION"));
    if web_external_path.is_some() {
        tracing::info!("📊 Web UI: http://<your-ip>:{}", actual_port);
    }
    tracing::info!("🔧 API: http://<your-ip>:{}/api", actual_port);

    // Spawn server in background
    tokio::spawn(async move {
        axum::serve(
            listener,
            app.into_make_service_with_connect_info::<SocketAddr>(),
        )
        .await
        .unwrap();
    });

    // Start cron for discovery scheduler
    discovery_service.start_scheduler().await?;

    let all_users = user_service.get_all(EntityFilter::unfiltered()).await?;

    if let Some(billing_service) = billing_service {
        billing_service
            .initialize_products(vec![
                BillingPlan::Starter(PlanConfig {
                    base_cents: 1499,
                    rate: BillingRate::Month,
                    trial_days: 0,
                    seat_cents: None,
                    network_cents: None,
                    included_seats: Some(1),
                    included_networks: Some(1),
                }),
                BillingPlan::Pro(PlanConfig {
                    base_cents: 2499,
                    rate: BillingRate::Month,
                    trial_days: 7,
                    seat_cents: None,
                    network_cents: None,
                    included_seats: Some(1),
                    included_networks: Some(3),
                }),
                BillingPlan::Team(PlanConfig {
                    base_cents: 7999,
                    rate: BillingRate::Month,
                    trial_days: 7,
                    seat_cents: Some(1000),
                    network_cents: Some(800),
                    included_seats: Some(5),
                    included_networks: Some(5),
                }),
                BillingPlan::Business(PlanConfig {
                    base_cents: 14999,
                    rate: BillingRate::Month,
                    trial_days: 14,
                    seat_cents: Some(800),
                    network_cents: Some(500),
                    included_seats: Some(10),
                    included_networks: Some(25),
                }),
            ])
            .await?;
    }

    // First load - populate user and org
    if all_users.is_empty() {
        let organization = organization_service
            .create(
                Organization::new(OrganizationBase {
                    stripe_customer_id: None,
                    plan: None,
                    plan_status: None,
                    name: "My Organization".to_string(),
                    onboarding: vec![],
                }),
                AuthenticatedEntity::System,
            )
            .await?;

        user_service
            .create(
                User::new(UserBase::new_seed(organization.id)),
                AuthenticatedEntity::System,
            )
            .await?;
    }

    tokio::signal::ctrl_c().await?;

    Ok(())
}
