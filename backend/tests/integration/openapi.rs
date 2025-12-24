//! OpenAPI spec generation test
//!
//! This test generates the OpenAPI spec without requiring Docker containers.
//! Run with: cargo test generate_openapi_spec -- --ignored --nocapture

use scanopy::server::openapi::build_openapi;
use scanopy::server::shared::handlers::factory::create_openapi_routes;

/// Generate the OpenAPI spec and save to ui/static/openapi.json
///
/// This test is ignored by default - run explicitly with:
/// cargo test generate_openapi_spec -- --ignored --nocapture
#[tokio::test]
#[ignore]
async fn generate_openapi_spec() {
    // Use the same route definitions as the server (single source of truth)
    let routes = create_openapi_routes();
    let (_, paths_spec) = routes.split_for_parts();

    // Build spec with security schemes, path filtering, and sorting
    let spec = build_openapi(paths_spec);

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
