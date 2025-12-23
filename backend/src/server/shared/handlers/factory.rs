use crate::server::auth::middleware::billing::require_billing_for_users;
use crate::server::bindings::r#impl::base::Binding;
use crate::server::config::get_public_config;
use crate::server::github::handlers::get_stars;
use crate::server::openapi::create_docs_router;
use crate::server::ports::r#impl::base::Port;
use crate::server::shared::handlers::traits::create_child_crud_router;
use crate::server::shared::types::metadata::get_metadata_registry;
use crate::server::{
    auth::handlers as auth_handlers, billing::handlers as billing_handlers, config::AppState,
    daemons::handlers as daemon_handlers, discovery::handlers as discovery_handlers,
    groups::handlers as group_handlers, hosts::handlers as host_handlers,
    interfaces::handlers as interface_handlers, invites::handlers as invite_handlers,
    networks::handlers as network_handlers, organizations::handlers as organization_handlers,
    services::handlers as service_handlers, shared::types::api::ApiResponse,
    shares::handlers as share_handlers, subnets::handlers as subnet_handlers,
    tags::handlers as tag_handlers, topology::handlers as topology_handlers,
    users::handlers as user_handlers,
};
use axum::http::HeaderValue;
use axum::middleware;
use axum::{Json, Router, routing::get};
use reqwest::header;
use std::sync::Arc;
use tower_http::set_header::SetResponseHeaderLayer;
use utoipa::openapi::OpenApi;
use utoipa_axum::router::OpenApiRouter;

/// Creates the application router and returns both the router and OpenAPI spec.
/// The OpenAPI spec is built from annotated handlers using utoipa-axum.
pub fn create_router(state: Arc<AppState>) -> (Router<Arc<AppState>>, OpenApi) {
    // Routes that require billing for user requests (daemons exempt via middleware check)
    // Using OpenApiRouter to collect OpenAPI documentation from handlers
    let billed_routes = OpenApiRouter::new()
        .nest("/api/hosts", host_handlers::create_router())
        .nest("/api/interfaces", interface_handlers::create_router())
        .nest("/api/subnets", subnet_handlers::create_router())
        .nest("/api/networks", network_handlers::create_router())
        .nest("/api/groups", group_handlers::create_router())
        // TODO: Migrate remaining handlers to OpenApiRouter
        .nest("/api/daemons", OpenApiRouter::from(daemon_handlers::create_router()))
        .nest("/api/discovery", OpenApiRouter::from(discovery_handlers::create_router()))
        .nest("/api/topology", OpenApiRouter::from(topology_handlers::create_router()))
        .nest("/api/services", OpenApiRouter::from(service_handlers::create_router()))
        .nest("/api/users", OpenApiRouter::from(user_handlers::create_router()))
        .nest("/api/organizations", OpenApiRouter::from(organization_handlers::create_router()))
        .nest("/api/invites", OpenApiRouter::from(invite_handlers::create_router()))
        .nest("/api/tags", OpenApiRouter::from(tag_handlers::create_router()))
        .nest("/api/ports", OpenApiRouter::from(create_child_crud_router::<Port>()))
        .nest("/api/bindings", OpenApiRouter::from(create_child_crud_router::<Binding>()));

    // Extract OpenAPI spec and convert to regular Router for middleware application
    let (billed_router, openapi) = billed_routes.split_for_parts();
    let billed_router = billed_router.layer(middleware::from_fn_with_state(
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

    let router = Router::new()
        .merge(billed_router)
        .merge(exempt_routes)
        .merge(cacheable_routes)
        .merge(create_docs_router(openapi.clone()));

    (router, openapi)
}

async fn get_health() -> Json<ApiResponse<String>> {
    Json(ApiResponse::success(format!(
        "Scanopy Server {}",
        env!("CARGO_PKG_VERSION")
    )))
}
