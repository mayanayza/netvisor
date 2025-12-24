//! OpenAPI documentation configuration
//!
//! Uses utoipa-axum for automatic route documentation and utoipa-scalar for the UI.
//! Routes and schemas are collected automatically from handlers via OpenApiRouter.

use axum::{Extension, Json, Router};
use std::sync::Arc;
use utoipa::openapi::security::{ApiKey, ApiKeyValue, SecurityScheme};
use utoipa::openapi::{Components, OpenApi};
use utoipa::OpenApi as OpenApiDerive;
use utoipa_scalar::{Scalar, Servable};

use crate::server::config::AppState;

/// OpenAPI base configuration
///
/// Paths, schemas, and tags are collected automatically from handler annotations by utoipa-axum.
/// Only API metadata and security schemes need to be defined here.
#[derive(OpenApiDerive)]
#[openapi(
    info(
        title = "Scanopy API",
        version = "0.12.5",
        description = "Network topology discovery and visualization API",
        license(name = "Dual (AGPL3.0, Commercial License Available)")
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
        "session".to_string(),
        SecurityScheme::ApiKey(ApiKey::Cookie(ApiKeyValue::new("session"))),
    );

    // API key authentication (used by daemons)
    components.security_schemes.insert(
        "api_key".to_string(),
        SecurityScheme::ApiKey(ApiKey::Header(ApiKeyValue::with_description(
            "X-API-Key",
            "API key for daemon authentication. Generate keys in the web UI under Settings > API Keys.",
        ))),
    );
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
