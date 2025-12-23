use scanopy::server::services::definitions::ServiceDefinitionRegistry;
use scanopy::server::services::r#impl::definitions::{ServiceDefinition, ServiceDefinitionExt};
use scanopy::server::shared::types::metadata::EntityMetadataProvider;

/// Generate all fixtures (requires Docker containers to be running)
pub async fn generate_fixtures() {
    generate_db_fixture()
        .await
        .expect("Failed to generate db fixture");

    generate_daemon_config_fixture()
        .await
        .expect("Failed to generate daemon config fixture");

    generate_services_json()
        .await
        .expect("Failed to generate services json");

    generate_billing_plans_json()
        .await
        .expect("Failed to generate billing and features json");

    // Note: OpenAPI spec is generated separately via:
    // cargo test generate_openapi_spec -- --ignored --nocapture

    println!("✅ Generated test fixtures");
}

async fn generate_db_fixture() -> Result<(), Box<dyn std::error::Error>> {
    let output = std::process::Command::new("docker")
        .args([
            "exec",
            "scanopy-postgres-dev-1",
            "pg_dump",
            "-U",
            "postgres",
            "-d",
            "scanopy",
            "--clean",
            "--if-exists",
        ])
        .output()?;

    if !output.status.success() {
        return Err(format!(
            "pg_dump failed: {}",
            String::from_utf8_lossy(&output.stderr)
        )
        .into());
    }

    let fixture_path =
        std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("src/tests/scanopy-next.sql");
    std::fs::write(&fixture_path, output.stdout)?;

    println!("✅ Generated scanopy-next.sql from test data");
    Ok(())
}

async fn generate_daemon_config_fixture() -> Result<(), Box<dyn std::error::Error>> {
    let find_output = std::process::Command::new("docker")
        .args([
            "exec",
            "scanopy-daemon-1",
            "find",
            "/root/.config",
            "-name",
            "config.json",
            "-type",
            "f",
        ])
        .output()?;

    if !find_output.status.success() {
        return Err(format!(
            "Failed to find daemon config: {}",
            String::from_utf8_lossy(&find_output.stderr)
        )
        .into());
    }

    let config_path = String::from_utf8_lossy(&find_output.stdout)
        .trim()
        .to_string();

    if config_path.is_empty() {
        return Err("No config.json found in container".into());
    }

    println!("Found daemon config at: {}", config_path);

    let output = std::process::Command::new("docker")
        .args(["exec", "scanopy-daemon-1", "cat", &config_path])
        .output()?;

    if !output.status.success() {
        return Err(format!(
            "Failed to read daemon config: {}",
            String::from_utf8_lossy(&output.stderr)
        )
        .into());
    }

    let fixture_path =
        std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("src/tests/daemon_config-next.json");
    std::fs::write(&fixture_path, output.stdout)?;

    println!("✅ Generated daemon_config-next.json from test daemon");
    Ok(())
}

async fn generate_services_json() -> Result<(), Box<dyn std::error::Error>> {
    let services: Vec<serde_json::Value> = ServiceDefinitionRegistry::all_service_definitions()
        .iter()
        .filter_map(|s| {
            if s.can_be_manually_added() {
                Some(serde_json::json!({
                    "logo_url": s.logo_url(),
                    "name": s.name(),
                    "description": s.description(),
                    "discovery_pattern": s.discovery_pattern().to_string(),
                    "category": s.category(),
                    "color": s.color(),
                    "logo_needs_white_background": s.logo_needs_white_background()
                }))
            } else {
                None
            }
        })
        .collect();

    let json_string = serde_json::to_string_pretty(&services)?;
    let json_path = std::path::Path::new("../ui/static/services-next.json");
    tokio::fs::write(json_path, json_string).await?;

    Ok(())
}

async fn generate_billing_plans_json() -> Result<(), Box<dyn std::error::Error>> {
    use scanopy::server::billing::plans::get_website_fixture_plans;
    use scanopy::server::billing::types::features::Feature;
    use scanopy::server::shared::types::metadata::{MetadataProvider, TypeMetadata};
    use strum::IntoEnumIterator;

    let plans = get_website_fixture_plans();
    let plan_metadata: Vec<TypeMetadata> = plans.iter().map(|p| p.to_metadata()).collect();
    let feature_metadata: Vec<TypeMetadata> = Feature::iter().map(|f| f.to_metadata()).collect();

    let json_string = serde_json::to_string_pretty(&plan_metadata)?;
    let path = std::path::Path::new("../ui/static/billing-plans-next.json");
    tokio::fs::write(path, json_string).await?;

    let json_string = serde_json::to_string_pretty(&feature_metadata)?;
    let path = std::path::Path::new("../ui/static/features-next.json");
    tokio::fs::write(path, json_string).await?;

    println!("✅ Generated billing-plans-next.json and features-next.json");
    Ok(())
}
