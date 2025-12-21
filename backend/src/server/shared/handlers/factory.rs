use crate::server::auth::middleware::billing::require_billing_for_users;
use crate::server::config::get_public_config;
use crate::server::github::handlers::get_stars;
use crate::server::shared::types::metadata::get_metadata_registry;
use crate::server::{
    auth::handlers as auth_handlers, billing::handlers as billing_handlers, config::AppState,
    daemons::handlers as daemon_handlers, discovery::handlers as discovery_handlers,
    groups::handlers as group_handlers, hosts::handlers as host_handlers,
    invites::handlers as invite_handlers, networks::handlers as network_handlers,
    organizations::handlers as organization_handlers, services::handlers as service_handlers,
    shared::types::api::ApiResponse, shares::handlers as share_handlers,
    subnets::handlers as subnet_handlers, tags::handlers as tag_handlers,
    topology::handlers as topology_handlers, users::handlers as user_handlers,
};
use axum::http::HeaderValue;
use axum::middleware;
use axum::{Json, Router, routing::get};
use reqwest::header;
use std::sync::Arc;
use tower_http::set_header::SetResponseHeaderLayer;

pub fn create_router(state: Arc<AppState>) -> Router<Arc<AppState>> {
    // Routes that require billing for user requests (daemons exempt via middleware check)
    let billed_routes = Router::new()
        .nest("/api/hosts", host_handlers::create_router())
        .nest("/api/groups", group_handlers::create_router())
        .nest("/api/daemons", daemon_handlers::create_router())
        .nest("/api/discovery", discovery_handlers::create_router())
        .nest("/api/subnets", subnet_handlers::create_router())
        .nest("/api/topology", topology_handlers::create_router())
        .nest("/api/services", service_handlers::create_router())
        .nest("/api/networks", network_handlers::create_router())
        .nest("/api/users", user_handlers::create_router())
        .nest("/api/organizations", organization_handlers::create_router())
        .nest("/api/invites", invite_handlers::create_router())
        .nest("/api/tags", tag_handlers::create_router())
        .layer(middleware::from_fn_with_state(
            state,
            require_billing_for_users,
        ));

    // Routes exempt from billing checks (includes shares which has public endpoints)
    let exempt_routes = Router::new()
        .nest("/api/billing", billing_handlers::create_router())
        .nest("/api/auth", auth_handlers::create_router())
        .nest("/api/shares", share_handlers::create_router())
        .route("/api/health", get(get_health));

    // Cacheable routes (also exempt from billing)
    let cacheable_routes = Router::new()
        .route("/api/metadata", get(get_metadata_registry))
        .route("/api/config", get(get_public_config))
        .route("/api/github-stars", get(get_stars))
        .layer(SetResponseHeaderLayer::if_not_present(
            header::CACHE_CONTROL,
            HeaderValue::from_static("max-age=3600, must-revalidate"),
        ));

    Router::new()
        .merge(billed_routes)
        .merge(exempt_routes)
        .merge(cacheable_routes)
}

async fn get_health() -> Json<ApiResponse<String>> {
    Json(ApiResponse::success(format!(
        "Scanopy Server {}",
        env!("CARGO_PKG_VERSION")
    )))
}
