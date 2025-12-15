use scanopy::server::services::definitions::ServiceDefinitionRegistry;
use scanopy::server::services::r#impl::definitions::{ServiceDefinition, ServiceDefinitionExt};
use scanopy::server::shared::types::metadata::EntityMetadataProvider;

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

    generate_services_markdown()
        .await
        .expect("Failed to generate services markdown");

    generate_billing_plans_json()
        .await
        .expect("Failed to generate billing and features json");

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

async fn generate_services_markdown() -> Result<(), Box<dyn std::error::Error>> {
    use std::collections::HashMap;

    let services = ServiceDefinitionRegistry::all_service_definitions();

    let mut by_category: HashMap<String, Vec<&Box<dyn ServiceDefinition>>> = HashMap::new();
    for service in &services {
        let category = service.category().to_string();
        by_category.entry(category).or_default().push(service);
    }

    let mut categories: Vec<String> = by_category.keys().cloned().collect();
    categories.sort();

    let mut markdown = String::from("# Scanopy Service Definitions\n\n");
    markdown.push_str(
        "This document lists all services that Scanopy can automatically discover and identify.\n\n",
    );

    for category in categories {
        let services = by_category.get(&category).unwrap();

        markdown.push_str(&format!("## {}\n\n", category));
        markdown.push_str(
            "<table style=\"background-color: #1a1d29; border-collapse: collapse; width: 100%;\">\n",
        );
        markdown.push_str("<thead>\n");
        markdown.push_str(
            "<tr style=\"background-color: #1f2937; border-bottom: 2px solid #374151;\">\n",
        );
        markdown.push_str("<th width=\"60\" style=\"padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;\">Logo</th>\n");
        markdown.push_str("<th width=\"200\" style=\"padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;\">Name</th>\n");
        markdown.push_str("<th width=\"300\" style=\"padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;\">Description</th>\n");
        markdown.push_str("<th style=\"padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;\">Discovery Pattern</th>\n");
        markdown.push_str("</tr>\n");
        markdown.push_str("</thead>\n");
        markdown.push_str("<tbody>\n");

        let mut sorted_services = services.clone();
        sorted_services.sort_by_key(|s| s.name());

        for service in sorted_services {
            let logo_url = service.logo_url();
            let name = service.name();
            let description = service.description();
            let pattern = service.discovery_pattern().to_string();

            let logo = if !logo_url.is_empty() {
                format!(
                    "<img src=\"{}\" alt=\"{}\" width=\"32\" height=\"32\" />",
                    logo_url, name
                )
            } else {
                "—".to_string()
            };

            markdown.push_str("<tr style=\"border-bottom: 1px solid #374151;\">\n");
            markdown.push_str(&format!(
                "<td align=\"center\" style=\"padding: 12px; color: #d1d5db;\">{}</td>\n",
                logo
            ));
            markdown.push_str(&format!(
                "<td style=\"padding: 12px; color: #f3f4f6; font-weight: 500;\">{}</td>\n",
                name
            ));
            markdown.push_str(&format!(
                "<td style=\"padding: 12px; color: #d1d5db;\">{}</td>\n",
                description
            ));
            markdown.push_str(&format!("<td style=\"padding: 12px;\"><code style=\"background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;\">{}</code></td>\n", pattern));
            markdown.push_str("</tr>\n");
        }

        markdown.push_str("</tbody>\n");
        markdown.push_str("</table>\n\n");
    }

    let md_path = std::path::Path::new("../docs/SERVICES-NEXT.md");
    tokio::fs::write(md_path, markdown).await?;

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
