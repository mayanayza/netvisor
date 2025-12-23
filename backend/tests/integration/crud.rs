//! CRUD endpoint tests for all entity types.

use crate::infra::TestContext;
use cidr::{IpCidr, Ipv4Cidr};
use reqwest::StatusCode;
use scanopy::server::api_keys::r#impl::base::{ApiKey, ApiKeyBase};
use scanopy::server::groups::r#impl::base::{Group, GroupBase};
use scanopy::server::groups::r#impl::types::GroupType;
use scanopy::server::hosts::r#impl::api::{CreateHostRequest, HostResponse, UpdateHostRequest};
use scanopy::server::services::definitions::ServiceDefinitionRegistry;
use scanopy::server::services::r#impl::base::{Service, ServiceBase};
use scanopy::server::shared::storage::traits::StorableEntity;
use scanopy::server::shared::types::entities::EntitySource;
use scanopy::server::subnets::r#impl::base::{Subnet, SubnetBase};
use scanopy::server::subnets::r#impl::types::SubnetType;
use scanopy::server::tags::r#impl::base::{Tag, TagBase};
use scanopy::server::topology::types::edges::EdgeStyle;
use std::net::Ipv4Addr;
use uuid::Uuid;

pub async fn run_crud_tests(ctx: &TestContext) -> Result<(), String> {
    println!("\n=== Testing CRUD Endpoints ===\n");

    test_subnet_crud(ctx).await?;
    test_host_crud(ctx).await?;
    test_service_crud(ctx).await?;
    test_group_crud(ctx).await?;
    test_tag_crud(ctx).await?;
    test_api_key_crud(ctx).await?;

    println!("\n✅ All CRUD endpoint tests passed!");
    Ok(())
}

async fn test_subnet_crud(ctx: &TestContext) -> Result<(), String> {
    println!("Testing Subnet CRUD...");

    let subnet = Subnet::new(SubnetBase {
        name: "Test Subnet".to_string(),
        description: Some("Test description".to_string()),
        network_id: ctx.network_id,
        cidr: IpCidr::V4(Ipv4Cidr::new(Ipv4Addr::new(10, 0, 0, 0), 24).unwrap()),
        subnet_type: SubnetType::Lan,
        source: EntitySource::System,
        tags: Vec::new(),
    });

    let created: Subnet = ctx.client.post("/api/subnets", &subnet).await?;
    assert!(!created.id.is_nil(), "Created subnet should have an ID");
    assert_eq!(created.base.name, "Test Subnet");
    println!("  ✓ Create subnet");

    let fetched: Subnet = ctx
        .client
        .get(&format!("/api/subnets/{}", created.id))
        .await?;
    assert_eq!(fetched.id, created.id);
    println!("  ✓ Read subnet");

    let mut updated = fetched.clone();
    updated.base.name = "Updated Subnet".to_string();
    let updated: Subnet = ctx
        .client
        .put(&format!("/api/subnets/{}", updated.id), &updated)
        .await?;
    assert_eq!(updated.base.name, "Updated Subnet");
    println!("  ✓ Update subnet");

    let subnets: Vec<Subnet> = ctx.client.get("/api/subnets").await?;
    assert!(subnets.iter().any(|s| s.id == created.id));
    println!("  ✓ List subnets");

    ctx.client
        .delete_no_content(&format!("/api/subnets/{}", created.id))
        .await?;
    println!("  ✓ Delete subnet");

    let result = ctx
        .client
        .get_expect_status(
            &format!("/api/subnets/{}", created.id),
            StatusCode::NOT_FOUND,
        )
        .await;
    assert!(result.is_ok(), "Deleted subnet should return 404");
    println!("  ✓ Verify deletion");

    println!("✅ Subnet CRUD passed");
    Ok(())
}

async fn test_host_crud(ctx: &TestContext) -> Result<(), String> {
    println!("Testing Host CRUD...");

    let request = CreateHostRequest {
        name: "Test Host".to_string(),
        hostname: Some("test.local".to_string()),
        network_id: ctx.network_id,
        description: None,
        virtualization: None,
        hidden: false,
        tags: Vec::new(),
        interfaces: vec![],
        ports: vec![],
        services: vec![],
    };

    let created: HostResponse = ctx.client.post("/api/hosts", &request).await?;
    assert!(!created.id.is_nil(), "Created host should have an ID");
    assert_eq!(created.name, "Test Host");
    println!("  ✓ Create host");

    let fetched: HostResponse = ctx
        .client
        .get(&format!("/api/hosts/{}", created.id))
        .await?;
    assert_eq!(fetched.id, created.id);
    println!("  ✓ Read host");

    let update_request = UpdateHostRequest {
        id: created.id,
        name: "Updated Host".to_string(),
        hostname: fetched.hostname.clone(),
        description: fetched.description.clone(),
        virtualization: fetched.virtualization.clone(),
        hidden: fetched.hidden,
        tags: fetched.tags.clone(),
    };
    let updated: HostResponse = ctx
        .client
        .put(&format!("/api/hosts/{}", created.id), &update_request)
        .await?;
    assert_eq!(updated.name, "Updated Host");
    println!("  ✓ Update host");

    let hosts: Vec<HostResponse> = ctx.client.get("/api/hosts").await?;
    assert!(hosts.iter().any(|h| h.id == created.id));
    println!("  ✓ List hosts");

    ctx.client
        .delete_no_content(&format!("/api/hosts/{}", created.id))
        .await?;
    println!("  ✓ Delete host");

    println!("✅ Host CRUD passed");
    Ok(())
}

async fn test_service_crud(ctx: &TestContext) -> Result<(), String> {
    println!("Testing Service CRUD...");

    let host_request = CreateHostRequest {
        name: "Service Test Host".to_string(),
        hostname: Some("service-test.local".to_string()),
        network_id: ctx.network_id,
        description: None,
        virtualization: None,
        hidden: false,
        tags: Vec::new(),
        interfaces: vec![],
        ports: vec![],
        services: vec![],
    };
    let created_host: HostResponse = ctx.client.post("/api/hosts", &host_request).await?;

    let service_def = ServiceDefinitionRegistry::find_by_id("Dns Server")
        .unwrap_or_else(|| ServiceDefinitionRegistry::all_service_definitions()[0].clone());

    let service = Service::new(ServiceBase {
        name: "Test Service".to_string(),
        host_id: created_host.id,
        bindings: vec![],
        network_id: ctx.network_id,
        service_definition: service_def,
        virtualization: None,
        source: EntitySource::System,
        tags: Vec::new(),
    });

    let created: Service = ctx.client.post("/api/services", &service).await?;
    assert!(!created.id.is_nil());
    assert_eq!(created.base.name, "Test Service");
    println!("  ✓ Create service");

    let fetched: Service = ctx
        .client
        .get(&format!("/api/services/{}", created.id))
        .await?;
    assert_eq!(fetched.id, created.id);
    println!("  ✓ Read service");

    let mut updated = fetched.clone();
    updated.base.name = "Updated Service".to_string();
    let updated: Service = ctx
        .client
        .put(&format!("/api/services/{}", updated.id), &updated)
        .await?;
    assert_eq!(updated.base.name, "Updated Service");
    println!("  ✓ Update service");

    let services: Vec<Service> = ctx.client.get("/api/services").await?;
    assert!(services.iter().any(|s| s.id == created.id));
    println!("  ✓ List services");

    ctx.client
        .delete_no_content(&format!("/api/services/{}", created.id))
        .await?;
    println!("  ✓ Delete service");

    ctx.client
        .delete_no_content(&format!("/api/hosts/{}", created_host.id))
        .await?;

    println!("✅ Service CRUD passed");
    Ok(())
}

async fn test_group_crud(ctx: &TestContext) -> Result<(), String> {
    println!("Testing Group CRUD...");

    let group = Group::new(GroupBase {
        name: "Test Group".to_string(),
        description: Some("Test description".to_string()),
        network_id: ctx.network_id,
        color: "#FF0000".to_string(),
        group_type: GroupType::RequestPath,
        binding_ids: vec![],
        source: EntitySource::System,
        edge_style: EdgeStyle::Bezier,
        tags: Vec::new(),
    });

    let created: Group = ctx.client.post("/api/groups", &group).await?;
    assert!(!created.id.is_nil());
    assert_eq!(created.base.name, "Test Group");
    println!("  ✓ Create group");

    let fetched: Group = ctx
        .client
        .get(&format!("/api/groups/{}", created.id))
        .await?;
    assert_eq!(fetched.id, created.id);
    println!("  ✓ Read group");

    let mut updated = fetched.clone();
    updated.base.name = "Updated Group".to_string();
    let updated: Group = ctx
        .client
        .put(&format!("/api/groups/{}", updated.id), &updated)
        .await?;
    assert_eq!(updated.base.name, "Updated Group");
    println!("  ✓ Update group");

    let groups: Vec<Group> = ctx.client.get("/api/groups").await?;
    assert!(groups.iter().any(|g| g.id == created.id));
    println!("  ✓ List groups");

    ctx.client
        .delete_no_content(&format!("/api/groups/{}", created.id))
        .await?;
    println!("  ✓ Delete group");

    println!("✅ Group CRUD passed");
    Ok(())
}

async fn test_tag_crud(ctx: &TestContext) -> Result<(), String> {
    println!("Testing Tag CRUD...");

    let mut tag = Tag::new(TagBase::default());
    tag.base.organization_id = ctx.organization_id;
    tag.base.name = "Test Tag".to_string();

    let created: Tag = ctx.client.post("/api/tags", &tag).await?;
    assert!(!created.id.is_nil());
    assert_eq!(created.base.name, "Test Tag");
    println!("  ✓ Create tag");

    let fetched: Tag = ctx.client.get(&format!("/api/tags/{}", created.id)).await?;
    assert_eq!(fetched.id, created.id);
    println!("  ✓ Read tag");

    let mut updated = fetched.clone();
    updated.base.name = "Updated Tag".to_string();
    let updated: Tag = ctx
        .client
        .put(&format!("/api/tags/{}", updated.id), &updated)
        .await?;
    assert_eq!(updated.base.name, "Updated Tag");
    println!("  ✓ Update tag");

    let tags: Vec<Tag> = ctx.client.get("/api/tags").await?;
    assert!(tags.iter().any(|t| t.id == created.id));
    println!("  ✓ List tags");

    ctx.client
        .delete_no_content(&format!("/api/tags/{}", created.id))
        .await?;
    println!("  ✓ Delete tag");

    println!("✅ Tag CRUD passed");
    Ok(())
}

async fn test_api_key_crud(ctx: &TestContext) -> Result<(), String> {
    println!("Testing API Key CRUD...");

    let api_key = ApiKey::new(ApiKeyBase {
        key: String::new(),
        name: "Test API Key".to_string(),
        last_used: None,
        expires_at: None,
        network_id: ctx.network_id,
        is_enabled: true,
        tags: Vec::new(),
    });

    let created: serde_json::Value = ctx.client.post("/api/auth/keys", &api_key).await?;
    let created_key = created["api_key"].clone();
    let key_id = created_key["id"]
        .as_str()
        .and_then(|s| Uuid::parse_str(s).ok())
        .expect("Should have key ID");
    assert!(
        created["key"].as_str().is_some(),
        "Should return plaintext key"
    );
    println!("  ✓ Create API key (received plaintext key)");

    let fetched: ApiKey = ctx
        .client
        .get(&format!("/api/auth/keys/{}", key_id))
        .await?;
    assert_eq!(fetched.id, key_id);
    println!("  ✓ Read API key");

    let mut updated = fetched.clone();
    updated.base.name = "Updated API Key".to_string();
    let updated: ApiKey = ctx
        .client
        .put(&format!("/api/auth/keys/{}", updated.id), &updated)
        .await?;
    assert_eq!(updated.base.name, "Updated API Key");
    assert_eq!(
        updated.base.key, fetched.base.key,
        "Key hash should be preserved"
    );
    println!("  ✓ Update API key (key hash preserved)");

    let keys: Vec<ApiKey> = ctx.client.get("/api/auth/keys").await?;
    assert!(keys.iter().any(|k| k.id == key_id));
    println!("  ✓ List API keys");

    ctx.client
        .delete_no_content(&format!("/api/auth/keys/{}", key_id))
        .await?;
    println!("  ✓ Delete API key");

    println!("✅ API Key CRUD passed");
    Ok(())
}
