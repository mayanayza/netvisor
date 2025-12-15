//! Discovery and integration flow tests.

use crate::infra::{BASE_URL, TestClient, retry};
use scanopy::server::daemons::r#impl::api::DiscoveryUpdatePayload;
use scanopy::server::discovery::r#impl::types::DiscoveryType;
use scanopy::server::groups::r#impl::base::{Group, GroupBase};
use scanopy::server::services::definitions::home_assistant::HomeAssistant;
use scanopy::server::services::r#impl::base::Service;
use scanopy::server::shared::storage::traits::StorableEntity;
use scanopy::server::shared::types::metadata::HasId;
use scanopy::server::tags::r#impl::base::{Tag, TagBase};
use uuid::Uuid;

pub async fn run_discovery(client: &TestClient) -> Result<(), String> {
    println!("🔌 Connecting to SSE stream...");

    let mut event_source = client
        .client
        .get(format!("{}/api/discovery/stream", BASE_URL))
        .send()
        .await
        .map_err(|e| format!("Failed to connect to SSE: {}", e))?;

    let timeout = tokio::time::sleep(tokio::time::Duration::from_secs(300));
    tokio::pin!(timeout);

    loop {
        tokio::select! {
            _ = &mut timeout => {
                return Err("Discovery timed out after 5 minutes".to_string());
            }
            chunk = event_source.chunk() => {
                match chunk {
                    Ok(Some(bytes)) => {
                        let text = String::from_utf8_lossy(&bytes);

                        for line in text.lines() {
                            if let Some(data) = line.strip_prefix("data: ") {
                                if let Ok(update) = serde_json::from_str::<DiscoveryUpdatePayload>(data) {
                                    if !matches!(update.discovery_type, DiscoveryType::Network { .. }) {
                                        continue;
                                    }

                                    println!(
                                        "📊 Discovery: {} - {}%",
                                        update.phase,
                                        update.progress,
                                    );

                                    if update.finished_at.is_some() {
                                        if let Some(error) = &update.error {
                                            return Err(format!("Discovery failed: {}", error));
                                        }
                                        println!("✅ Discovery completed!");
                                        return Ok(());
                                    }
                                }
                            }
                        }
                    }
                    Ok(None) => return Err("SSE stream ended unexpectedly".to_string()),
                    Err(e) => return Err(format!("Error reading SSE: {}", e)),
                }
            }
        }
    }
}

pub async fn verify_home_assistant_discovered(client: &TestClient) -> Result<Service, String> {
    println!("\n=== Verifying Home Assistant Discovery ===");

    retry("find Home Assistant service", 10, 2, || async {
        let services: Vec<Service> = client.get("/api/services").await?;

        if services.is_empty() {
            return Err("No services found yet".to_string());
        }

        println!("✅ Found {} service(s):", services.len());
        for service in &services {
            println!(
                "   - {} ({})",
                service.base.name,
                service.base.service_definition.id()
            );
        }

        services
            .into_iter()
            .find(|s| s.base.service_definition.id() == HomeAssistant.id())
            .ok_or_else(|| "Home Assistant service not found".to_string())
    })
    .await
}

pub async fn create_group(client: &TestClient, network_id: Uuid) -> Result<Group, String> {
    println!("\n=== Creating Group ===");

    let mut group = Group::new(GroupBase::default());
    group.base.network_id = network_id;

    retry("create Group", 10, 3, || async {
        let created_group: Group = client.post("/api/groups", &group).await?;
        println!("✅ Created group");
        Ok(created_group)
    })
    .await
}

pub async fn create_tag(client: &TestClient, organization_id: Uuid) -> Result<Tag, String> {
    println!("\n=== Creating Tag ===");

    let mut tag = Tag::new(TagBase::default());
    tag.base.organization_id = organization_id;

    retry("create Tag", 10, 3, || async {
        let created_tag: Tag = client.post("/api/tags", &tag).await?;
        println!("✅ Created Tag");
        Ok(created_tag)
    })
    .await
}
