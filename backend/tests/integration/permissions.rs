//! Permission and access control tests.
//!
//! Tests that users cannot access resources on networks/organizations they don't have access to.

use crate::infra::{TestContext, exec_sql};
use cidr::{IpCidr, Ipv4Cidr};
use reqwest::StatusCode;
use scanopy::server::hosts::r#impl::api::CreateHostRequest;
use scanopy::server::shared::storage::traits::StorableEntity;
use scanopy::server::shared::types::entities::EntitySource;
use scanopy::server::subnets::r#impl::base::{Subnet, SubnetBase};
use scanopy::server::subnets::r#impl::types::SubnetType;
use std::net::Ipv4Addr;
use uuid::Uuid;

pub async fn run_permission_tests(ctx: &TestContext) -> Result<(), String> {
    println!("\n=== Testing Permissions & Access Control ===\n");

    // Create a second network that the user doesn't have access to
    let other_network_id = create_inaccessible_network(ctx).await?;

    test_cannot_read_host_on_other_network(ctx, other_network_id).await?;
    test_cannot_create_host_on_other_network(ctx, other_network_id).await?;
    test_cannot_create_subnet_on_other_network(ctx, other_network_id).await?;

    // Clean up
    cleanup_inaccessible_network(other_network_id)?;

    println!("\n✅ All permission tests passed!");
    Ok(())
}

/// Creates a network in the same organization that the user doesn't have access to
async fn create_inaccessible_network(ctx: &TestContext) -> Result<Uuid, String> {
    let network_id = Uuid::new_v4();

    // Insert network directly into database (bypassing API which would grant access)
    let sql = format!(
        "INSERT INTO networks (id, name, organization_id, created_at, updated_at) \
         VALUES ('{}', 'Inaccessible Network', '{}', NOW(), NOW());",
        network_id, ctx.organization_id
    );
    exec_sql(&sql)?;

    println!("  Created inaccessible network: {}", network_id);
    Ok(network_id)
}

fn cleanup_inaccessible_network(network_id: Uuid) -> Result<(), String> {
    // Clean up in reverse order of dependencies
    let _ = exec_sql(&format!(
        "DELETE FROM subnets WHERE network_id = '{}';",
        network_id
    ));
    let _ = exec_sql(&format!(
        "DELETE FROM hosts WHERE network_id = '{}';",
        network_id
    ));
    let _ = exec_sql(&format!(
        "DELETE FROM networks WHERE id = '{}';",
        network_id
    ));
    Ok(())
}

/// Test that user cannot read hosts on a network they don't have access to
async fn test_cannot_read_host_on_other_network(
    ctx: &TestContext,
    other_network_id: Uuid,
) -> Result<(), String> {
    println!("Testing: Cannot read hosts on inaccessible network...");

    // Create a host directly in the database on the other network
    let host_id = Uuid::new_v4();
    let sql = format!(
        "INSERT INTO hosts (id, name, network_id, source, hidden, tags, created_at, updated_at) \
         VALUES ('{}', 'Secret Host', '{}', '\"System\"', false, '[]', NOW(), NOW());",
        host_id, other_network_id
    );
    exec_sql(&sql)?;

    // Try to read this host - should fail
    let result = ctx
        .client
        .get_expect_status(&format!("/api/hosts/{}", host_id), StatusCode::NOT_FOUND)
        .await;

    // Clean up
    let _ = exec_sql(&format!("DELETE FROM hosts WHERE id = '{}';", host_id));

    assert!(
        result.is_ok(),
        "Should not be able to read host on inaccessible network: {:?}",
        result.err()
    );
    println!("  ✓ Cannot read host on inaccessible network (returns 404)");

    Ok(())
}

/// Test that user cannot create hosts on a network they don't have access to
async fn test_cannot_create_host_on_other_network(
    ctx: &TestContext,
    other_network_id: Uuid,
) -> Result<(), String> {
    println!("Testing: Cannot create host on inaccessible network...");

    let host_request = CreateHostRequest {
        name: "Unauthorized Host".to_string(),
        hostname: None,
        network_id: other_network_id, // Network user doesn't have access to
        description: None,
        virtualization: None,
        hidden: false,
        tags: Vec::new(),
        interfaces: vec![],
        ports: vec![],
    };

    // Should get 401 Unauthorized (or 403 Forbidden)
    let result = ctx
        .client
        .post_expect_status("/api/hosts", &host_request, StatusCode::UNAUTHORIZED)
        .await;

    assert!(
        result.is_ok(),
        "Should not be able to create host on inaccessible network: {:?}",
        result.err()
    );
    println!("  ✓ Cannot create host on inaccessible network (returns 401)");

    Ok(())
}

/// Test that user cannot create subnets on a network they don't have access to
async fn test_cannot_create_subnet_on_other_network(
    ctx: &TestContext,
    other_network_id: Uuid,
) -> Result<(), String> {
    println!("Testing: Cannot create subnet on inaccessible network...");

    let subnet = Subnet::new(SubnetBase {
        name: "Unauthorized Subnet".to_string(),
        description: None,
        network_id: other_network_id, // Network user doesn't have access to
        cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(10, 0, 0, 0), 24).unwrap()),
        subnet_type: SubnetType::Lan,
        source: EntitySource::System,
        tags: Vec::new(),
    });

    // Should get 401 Unauthorized
    let result = ctx
        .client
        .post_expect_status("/api/subnets", &subnet, StatusCode::UNAUTHORIZED)
        .await;

    assert!(
        result.is_ok(),
        "Should not be able to create subnet on inaccessible network: {:?}",
        result.err()
    );
    println!("  ✓ Cannot create subnet on inaccessible network (returns 401)");

    Ok(())
}
