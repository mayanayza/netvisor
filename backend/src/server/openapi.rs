//! OpenAPI documentation configuration
//!
//! Uses utoipa-axum for automatic route documentation and utoipa-scalar for the UI.
//! Routes are collected from handlers via OpenApiRouter, then merged with schema definitions.

use axum::{Extension, Json, Router};
use std::sync::Arc;
use utoipa::openapi::OpenApi;
use utoipa::OpenApi as OpenApiDerive;
use utoipa_scalar::{Scalar, Servable};

use crate::server::config::AppState;
use crate::server::shared::types::ts_exports;

/// OpenAPI schema definitions
///
/// Types are registered from ts_exports for schema generation.
/// Paths are collected automatically by utoipa-axum's OpenApiRouter from handler annotations.
#[derive(OpenApiDerive)]
#[openapi(
    info(
        title = "Scanopy API",
        version = "0.12.5",
        description = "Network topology discovery and visualization API",
        license(name = "MIT")
    ),
    components(schemas(
        // Core entities
        ts_exports::HostResponse,
        ts_exports::Service,
        ts_exports::Interface,
        ts_exports::Port,
        ts_exports::Binding,
        ts_exports::Subnet,
        ts_exports::Network,
        ts_exports::Group,
        ts_exports::Tag,
        ts_exports::ApiKey,
        ts_exports::Daemon,
        ts_exports::User,
        ts_exports::Organization,
        ts_exports::Discovery,
        // Supporting types
        ts_exports::EntitySource,
        ts_exports::DiscoveryMetadata,
        ts_exports::DiscoveryType,
        ts_exports::HostNamingFallback,
        ts_exports::MatchDetails,
        ts_exports::MatchConfidence,
        ts_exports::HostVirtualization,
        ts_exports::ProxmoxVirtualization,
        ts_exports::ServiceVirtualization,
        ts_exports::DockerVirtualization,
        ts_exports::GroupType,
        ts_exports::EdgeStyle,
        ts_exports::SubnetType,
        ts_exports::TransportProtocol,
        ts_exports::DaemonMode,
        ts_exports::DaemonCapabilities,
        ts_exports::DiscoveryStatus,
        ts_exports::DiscoveryRunType,
        ts_exports::UserPermissions,
        ts_exports::ApiResponse<String>,
    )),
    tags(
        (name = "hosts", description = "Host management"),
        (name = "services", description = "Service management"),
        (name = "interfaces", description = "Network interface management"),
        (name = "ports", description = "Port management"),
        (name = "bindings", description = "Service binding management"),
        (name = "subnets", description = "Subnet management"),
        (name = "networks", description = "Network management"),
        (name = "groups", description = "Group management"),
        (name = "tags", description = "Tag management"),
        (name = "daemons", description = "Daemon management"),
        (name = "discovery", description = "Network discovery"),
        (name = "topology", description = "Topology visualization"),
        (name = "auth", description = "Authentication"),
        (name = "users", description = "User management"),
        (name = "organizations", description = "Organization management"),
    )
)]
pub struct ApiDoc;

/// Merge the base schema with paths collected from handlers
pub fn build_openapi(paths_from_handlers: OpenApi) -> OpenApi {
    let mut base = ApiDoc::openapi();

    // Merge paths from handlers into base spec
    base.paths.paths.extend(paths_from_handlers.paths.paths);

    // Merge any additional components from handlers
    if let Some(handler_components) = paths_from_handlers.components {
        if let Some(ref mut base_components) = base.components {
            base_components.schemas.extend(handler_components.schemas);
        } else {
            base.components = Some(handler_components);
        }
    }

    base
}

/// Create the OpenAPI documentation router
/// Takes the OpenAPI spec collected from handlers and merges it with schema definitions.
pub fn create_docs_router(paths_from_handlers: OpenApi) -> Router<Arc<AppState>> {
    let openapi = Arc::new(build_openapi(paths_from_handlers));

    Router::new()
        .merge(Scalar::with_url("/api/docs", (*openapi).clone()))
        .route("/api/openapi.json", axum::routing::get(get_openapi_json))
        .layer(Extension(openapi))
}

/// Returns the OpenAPI specification as JSON
async fn get_openapi_json(
    Extension(openapi): Extension<Arc<OpenApi>>,
) -> Json<OpenApi> {
    Json((*openapi).clone())
}
