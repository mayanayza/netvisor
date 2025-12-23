//! Integration test suite for Scanopy.
//!
//! This module runs all integration tests in a single test function to share
//! Docker containers across test categories, significantly reducing test time.
//!
//! Test categories:
//! - Full integration flow (auth, discovery, entity creation)
//! - CRUD endpoint tests
//! - Billing middleware tests
//! - Handler validation tests

mod billing;
mod crud;
mod discovery;
#[cfg(feature = "generate-fixtures")]
mod fixtures;
mod infra;
mod openapi;
mod validations;

use infra::{
    ContainerManager, TestClient, TestContext, setup_authenticated_user, wait_for_daemon,
    wait_for_network, wait_for_organization,
};

/// Single integration test that runs all test categories with shared containers.
///
/// This avoids spinning up/down containers for each test category, which saves
/// significant time (each container cycle takes ~30-60 seconds).
#[tokio::test]
async fn integration_tests() {
    let mut container_manager = ContainerManager::new();

    // Start containers once
    container_manager
        .start()
        .expect("Failed to start containers");

    let client = TestClient::new();

    // =========================================================================
    // Phase 1: Full Integration Flow
    // =========================================================================
    println!("\n============================================================");
    println!("Phase 1: Full Integration Flow");
    println!("============================================================\n");

    let user = setup_authenticated_user(&client)
        .await
        .expect("Failed to authenticate user");
    println!("✅ Authenticated as: {}", user.base.email);

    println!("\n=== Waiting for Organization ===");
    let organization = wait_for_organization(&client)
        .await
        .expect("Failed to find organization");
    println!("✅ Organization: {}", organization.base.name);

    println!("\n=== Waiting for Network ===");
    let network = wait_for_network(&client)
        .await
        .expect("Failed to find network");
    println!("✅ Network: {}", network.base.name);

    println!("\n=== Waiting for Daemon ===");
    let daemon = wait_for_daemon(&client)
        .await
        .expect("Failed to find daemon");
    println!("✅ Daemon registered: {}", daemon.id);

    // Run discovery
    discovery::run_discovery(&client)
        .await
        .expect("Discovery failed");

    // Verify service discovered
    let _service = discovery::verify_home_assistant_discovered(&client)
        .await
        .expect("Failed to find Home Assistant");

    let _group = discovery::create_group(&client, network.id)
        .await
        .expect("Failed to create group");
    let _tag = discovery::create_tag(&client, organization.id)
        .await
        .expect("Failed to create tag");

    println!("\n✅ Full integration flow completed!");

    // =========================================================================
    // Phase 2: CRUD Endpoint Tests
    // =========================================================================
    println!("\n============================================================");
    println!("Phase 2: CRUD Endpoint Tests");
    println!("============================================================");

    let ctx = TestContext {
        client: TestClient::new(),
        network_id: network.id,
        organization_id: organization.id,
    };

    // Re-authenticate for CRUD tests
    let _ = setup_authenticated_user(&ctx.client)
        .await
        .expect("Failed to re-authenticate");

    crud::run_crud_tests(&ctx).await.expect("CRUD tests failed");

    // =========================================================================
    // Phase 3: Billing Middleware Tests
    // =========================================================================
    println!("\n============================================================");
    println!("Phase 3: Billing Middleware Tests");
    println!("============================================================");

    billing::run_billing_tests(&ctx)
        .await
        .expect("Billing tests failed");

    // =========================================================================
    // Phase 4: Handler Validation Tests
    // =========================================================================
    println!("\n============================================================");
    println!("Phase 4: Handler Validation Tests");
    println!("============================================================");

    validations::run_validation_tests(&ctx)
        .await
        .expect("Validation tests failed");

    // =========================================================================
    // Phase 5: Generate Fixtures (optional)
    // =========================================================================
    #[cfg(feature = "generate-fixtures")]
    {
        println!("\n============================================================");
        println!("Phase 5: Generating Fixtures");
        println!("============================================================");

        fixtures::generate_fixtures().await;
    }

    // =========================================================================
    // Summary
    // =========================================================================
    println!("\n============================================================");
    println!("ALL INTEGRATION TESTS PASSED!");
    println!("============================================================");
    println!("   - Full integration flow");
    println!("   - CRUD endpoint tests");
    println!("   - Billing middleware tests");
    println!("   - Handler validation tests");
    #[cfg(feature = "generate-fixtures")]
    println!("   - Fixture generation");
}
