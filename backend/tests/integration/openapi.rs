//! OpenAPI spec generation test
//!
//! This test generates the OpenAPI spec without requiring Docker containers.
//! Run with: cargo test generate_openapi_spec -- --ignored --nocapture

use scanopy::server::config::AppState;
use scanopy::server::groups::handlers as group_handlers;
use scanopy::server::hosts::handlers as host_handlers;
use scanopy::server::interfaces::handlers as interface_handlers;
use scanopy::server::networks::handlers as network_handlers;
use scanopy::server::openapi::ApiDoc;
use scanopy::server::subnets::handlers as subnet_handlers;
use std::sync::Arc;
use utoipa::OpenApi;
use utoipa_axum::router::OpenApiRouter;

/// Generate the OpenAPI spec and save to ui/static/openapi.json
///
/// This test is ignored by default - run explicitly with:
/// cargo test generate_openapi_spec -- --ignored --nocapture
#[tokio::test]
#[ignore]
async fn generate_openapi_spec() {
    // Collect paths from all OpenApiRouter handlers
    // The type parameter is just for type checking - we don't actually use state
    let routes: OpenApiRouter<Arc<AppState>> = OpenApiRouter::new()
        .nest("/api/hosts", host_handlers::create_router())
        .nest("/api/interfaces", interface_handlers::create_router())
        .nest("/api/subnets", subnet_handlers::create_router())
        .nest("/api/networks", network_handlers::create_router())
        .nest("/api/groups", group_handlers::create_router());

    let (_, paths_spec) = routes.split_for_parts();

    // Get base schema with all component definitions
    let mut spec = ApiDoc::openapi();

    // Merge paths from handlers
    spec.paths.paths.extend(paths_spec.paths.paths);

    // Merge any additional components from handlers
    if let Some(handler_components) = paths_spec.components {
        if let Some(ref mut base_components) = spec.components {
            base_components.schemas.extend(handler_components.schemas);
        } else {
            spec.components = Some(handler_components);
        }
    }

    let json_string = spec
        .to_pretty_json()
        .expect("Failed to serialize OpenAPI spec");

    let path = std::path::Path::new("../ui/static/openapi.json");
    tokio::fs::write(path, &json_string)
        .await
        .expect("Failed to write openapi.json");

    println!("✅ Generated openapi.json ({} bytes)", json_string.len());
    println!("   Path count: {}", spec.paths.paths.len());
    if let Some(components) = &spec.components {
        println!("   Schema count: {}", components.schemas.len());
    }
}
