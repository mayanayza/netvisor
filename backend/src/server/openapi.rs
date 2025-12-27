//! OpenAPI documentation configuration
//!
//! Uses utoipa-axum for automatic route documentation and utoipa-scalar for the UI.
//! Routes and schemas are collected automatically from handlers via OpenApiRouter.
//!
//! Endpoints tagged with "internal" are included in the full spec (for client generation)
//! but filtered out of the public Scalar documentation.

use axum::{Extension, Json, Router};
use std::sync::Arc;
use utoipa::OpenApi as OpenApiDerive;
use utoipa::openapi::security::{ApiKey, ApiKeyValue, SecurityScheme};
use utoipa::openapi::{Components, OpenApi, PathItem};
use utoipa_scalar::{Scalar, Servable};

use crate::server::config::AppState;

/// Tag used to mark endpoints that should be hidden from public documentation
/// but included in the full OpenAPI spec for client generation.
const INTERNAL_TAG: &str = "internal";

/// OpenAPI base configuration
///
/// Paths, schemas, and tags are collected automatically from handler annotations by utoipa-axum.
/// Only API metadata and security schemes need to be defined here.
#[derive(OpenApiDerive)]
#[openapi(
    info(
        title = "Scanopy API",
        version = env!("CARGO_PKG_VERSION"),
        description = "Network topology discovery and visualization API",
        license(name = "Dual (AGPL3.0, Commercial License Available)")
    ),
    tags(
        (name = "api_keys", description = "API keys for daemon authentication. Create and manage keys that allow daemons to communicate with the server."),
        (name = "auth", description = "Authentication and session management. Handle user login, logout, and session state."),
        (name = "config", description = "Server configuration. Public configuration settings for client applications."),
        (name = "discoveries", description = "Network discovery operations. Trigger and monitor scans that detect hosts, services, and network topology."),
        (name = "github", description = "GitHub integration endpoints."),
        (name = "ports", description = "Ports that have been scanned and found open on a host"),
        (name = "bindings", description = "
            ## Binding Types
            - **Interface binding**: Service is present at an interface (IP address) without a specific port.
              Used for non-port-bound services like gateways.
            - **Port binding (specific interface)**: Service listens on a specific port on a specific interface.
            - **Port binding (all interfaces)**: Service listens on a specific port on all interfaces
              (`interface_id: null`).

            ## Validation and Deduplication Rules
            - **Conflict detection**: Interface bindings conflict with port bindings on the same interface.
              A port binding on all interfaces conflicts with any interface binding for the same service.
            - **All-interfaces precedence**: When creating a port binding with `interface_id: null`,
              any existing specific-interface bindings for the same port are automatically removed,
              as they are superseded by the all-interfaces binding.
        "),
        (name = "groups", description = "Logical groupings of hosts. Organize hosts into groups for easier management and visualization."),
        (name = "hosts", description = "Network hosts (devices). Manage discovered or manually created hosts on your network."),
        (name = "interfaces", description = "Network interfaces on hosts. Each host can have multiple interfaces with different IP addresses."),
        (name = "internal", description = "Internal endpoints for system operations. Not part of the public API."),
        (name = "invites", description = "Organization invitations. Invite users to join your organization."),
        (name = "metadata", description = "Entity metadata registry. Schema information for all entity types in the system."),
        (name = "networks", description = "Network containers. Top-level organizational unit that contains subnets, hosts, and other entities."),
        (name = "organizations", description = "Manage organization settings."),
        (name = "services", description = "Services running on hosts. Detected or manually added services like databases, web servers, etc."),
        (name = "shares", description = "Shared network views. Create read-only shareable links to your network topology."),
        (name = "subnets", description = "IP subnets within networks. Define address ranges and organize hosts by subnet."),
        (name = "tags", description = "Custom tags for categorization. Apply labels to entities for filtering and organization."),
        (name = "users", description = "User account management. Manage user profiles and permissions within organizations."),
    )
)]
pub struct ApiDoc;

/// Merge the base configuration with paths/schemas/tags collected from handlers
pub fn build_openapi(paths_from_handlers: OpenApi) -> OpenApi {
    let mut base = ApiDoc::openapi();

    // Merge paths from handlers
    base.paths.paths.extend(paths_from_handlers.paths.paths);

    // Merge schemas from handlers
    if let Some(handler_components) = paths_from_handlers.components {
        if let Some(ref mut base_components) = base.components {
            base_components.schemas.extend(handler_components.schemas);
        } else {
            base.components = Some(handler_components);
        }
    }

    // Merge tags from handlers
    if let Some(handler_tags) = paths_from_handlers.tags {
        if let Some(ref mut base_tags) = base.tags {
            base_tags.extend(handler_tags);
        } else {
            base.tags = Some(handler_tags);
        }
    }

    // Add security schemes
    add_security_schemes(&mut base);

    base
}

/// Add security scheme definitions to the OpenAPI spec
fn add_security_schemes(spec: &mut OpenApi) {
    let components = spec.components.get_or_insert_with(Components::default);

    // Session cookie authentication (used by web UI)
    components.security_schemes.insert(
        "session_id".to_string(),
        SecurityScheme::ApiKey(ApiKey::Cookie(ApiKeyValue::new("session_id"))),
    );

    // API key authentication (used by daemons)
    components.security_schemes.insert(
        "api_key".to_string(),
        SecurityScheme::ApiKey(ApiKey::Header(ApiKeyValue::with_description(
            "Authorization: Bearer",
            "API key for daemon authentication. Generate keys in the web UI under Settings > API Keys.",
        ))),
    );
}

/// Check if a path item has any operations tagged with "internal"
fn has_internal_tag(path_item: &PathItem) -> bool {
    let operations = [
        path_item.get.as_ref(),
        path_item.post.as_ref(),
        path_item.put.as_ref(),
        path_item.delete.as_ref(),
        path_item.patch.as_ref(),
        path_item.head.as_ref(),
        path_item.options.as_ref(),
        path_item.trace.as_ref(),
    ];

    // If any operation is tagged with "internal", hide the path
    operations.iter().flatten().any(|op| {
        op.tags
            .as_ref()
            .is_some_and(|tags| tags.contains(&INTERNAL_TAG.to_string()))
    })
}

/// Filter out paths tagged with "internal" from the OpenAPI spec.
/// Used to create a public documentation version while keeping the full spec
/// for client generation.
///
/// Endpoints can have multiple tags (e.g., `tags = ["billing", "internal"]`).
/// Any endpoint with "internal" as one of its tags will be filtered out.
pub fn filter_internal_paths(spec: &OpenApi) -> OpenApi {
    let mut filtered = spec.clone();

    // Remove paths that have any "internal" tag
    filtered
        .paths
        .paths
        .retain(|_path, item| !has_internal_tag(item));

    // Remove the "internal" tag from the tags list
    if let Some(ref mut tags) = filtered.tags {
        tags.retain(|tag| tag.name != INTERNAL_TAG);
    }

    filtered
}

/// Create the OpenAPI documentation router
/// Takes the OpenAPI spec collected from handlers and merges it with schema definitions.
///
/// The full spec (including internal endpoints) is served at `/api/openapi.json` for client generation.
/// The filtered spec (excluding internal endpoints) is served at `/api/docs` for public documentation.
pub fn create_docs_router(paths_from_handlers: OpenApi) -> Router<Arc<AppState>> {
    let full_openapi = Arc::new(build_openapi(paths_from_handlers));
    let public_openapi = filter_internal_paths(&full_openapi);

    Router::new()
        // Scalar docs show only public endpoints
        .merge(Scalar::with_url("/api/docs", public_openapi))
        // Full spec for client generation (includes internal endpoints)
        .route("/api/openapi.json", axum::routing::get(get_openapi_json))
        .layer(Extension(full_openapi))
}

/// Returns the OpenAPI specification as JSON
async fn get_openapi_json(Extension(openapi): Extension<Arc<OpenApi>>) -> Json<OpenApi> {
    Json((*openapi).clone())
}

/// Export the OpenAPI spec to a file for client generation.
/// This is used by the fixture generator to create the spec without running the server.
pub fn export_openapi_spec_to_file(
    openapi: OpenApi,
    path: &std::path::Path,
) -> std::io::Result<()> {
    let full_openapi = build_openapi(openapi);
    let json = serde_json::to_string_pretty(&full_openapi).map_err(std::io::Error::other)?;
    std::fs::write(path, json)
}
