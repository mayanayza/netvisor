use crate::server::auth::middleware::billing::require_billing_for_users;
use crate::server::config::{__path_get_public_config, get_public_config};
use crate::server::github::handlers::{__path_get_stars, get_stars};
use crate::server::openapi::create_docs_router;
use crate::server::shared::types::metadata::{__path_get_metadata_registry, get_metadata_registry};
use crate::server::{
    api_keys::handlers as api_key_handlers, auth::handlers as auth_handlers,
    billing::handlers as billing_handlers, bindings::handlers as binding_handlers,
    config::AppState, daemons::handlers as daemon_handlers,
    discovery::handlers as discovery_handlers, groups::handlers as group_handlers,
    hosts::handlers as host_handlers, interfaces::handlers as interface_handlers,
    invites::handlers as invite_handlers, networks::handlers as network_handlers,
    organizations::handlers as organization_handlers, ports::handlers as port_handlers,
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

/// Creates the OpenApiRouter with all documented API routes.
/// This is the single source of truth for route definitions.
/// Used by both the server and OpenAPI spec generation.
pub fn create_openapi_routes() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .nest("/api/hosts", host_handlers::create_router())
        .nest("/api/interfaces", interface_handlers::create_router())
        .nest("/api/subnets", subnet_handlers::create_router())
        .nest("/api/networks", network_handlers::create_router())
        .nest("/api/groups", group_handlers::create_router())
        .nest("/api/daemons", daemon_handlers::create_router())
        .nest("/api/discovery", discovery_handlers::create_router())
        .nest("/api/services", service_handlers::create_router())
        .nest("/api/users", user_handlers::create_router())
        .nest("/api/organizations", organization_handlers::create_router())
        .nest("/api/invites", invite_handlers::create_router())
        .nest("/api/tags", tag_handlers::create_router())
        .nest("/api/ports", port_handlers::create_router())
        .nest("/api/bindings", binding_handlers::create_router())
        .nest("/api/auth/keys", api_key_handlers::create_router())
        // Topology endpoints (tagged as internal - hidden from public docs)
        .nest("/api/topology", topology_handlers::create_router())
}

/// Creates the application router and returns both the router and OpenAPI spec.
/// The OpenAPI spec is built from annotated handlers using utoipa-axum.
pub fn create_router(state: Arc<AppState>) -> (Router<Arc<AppState>>, OpenApi) {
    // Routes that require billing for user requests (daemons exempt via middleware check)
    let billed_routes = create_openapi_routes();

    // Extract OpenAPI spec and convert to regular Router for middleware application
    let (billed_router, mut openapi) = billed_routes.split_for_parts();
    let billed_router = billed_router.layer(middleware::from_fn_with_state(
        state,
        require_billing_for_users,
    ));

    // Extract OpenAPI from billing, shares, and auth routes (exempt from billing middleware but need types)
    let (billing_router, billing_openapi) = OpenApiRouter::new()
        .nest("/api/billing", billing_handlers::create_router())
        .split_for_parts();
    let (shares_router, shares_openapi) = OpenApiRouter::new()
        .nest("/api/shares", share_handlers::create_router())
        .split_for_parts();
    let (auth_router, auth_openapi) = OpenApiRouter::new()
        .nest("/api/auth", auth_handlers::create_router())
        .split_for_parts();

    // Merge OpenAPI specs into main spec
    openapi.merge(billing_openapi);
    openapi.merge(shares_openapi);
    openapi.merge(auth_openapi);

    // Routes exempt from billing checks
    let exempt_routes = Router::new()
        .merge(billing_router)
        .merge(shares_router)
        .merge(auth_router)
        .route("/api/health", get(get_health));

    // Cacheable routes with OpenAPI documentation (also exempt from billing)
    let (cacheable_router, cacheable_openapi) = OpenApiRouter::new()
        .routes(utoipa_axum::routes!(get_metadata_registry))
        .routes(utoipa_axum::routes!(get_public_config))
        .routes(utoipa_axum::routes!(get_stars))
        .split_for_parts();
    let cacheable_routes = cacheable_router.layer(SetResponseHeaderLayer::if_not_present(
        header::CACHE_CONTROL,
        HeaderValue::from_static("max-age=3600, must-revalidate"),
    ));
    openapi.merge(cacheable_openapi);

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
