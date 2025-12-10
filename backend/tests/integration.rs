use email_address::EmailAddress;
use netvisor::server::auth::r#impl::api::{LoginRequest, RegisterRequest};
use netvisor::server::daemons::r#impl::api::DiscoveryUpdatePayload;
use netvisor::server::daemons::r#impl::base::Daemon;
use netvisor::server::discovery::r#impl::types::DiscoveryType;
use netvisor::server::networks::r#impl::Network;
use netvisor::server::organizations::r#impl::base::Organization;

use netvisor::server::services::definitions::home_assistant::HomeAssistant;
use netvisor::server::services::r#impl::base::Service;
use netvisor::server::shared::handlers::factory::OnboardingRequest;
use netvisor::server::shared::types::api::ApiResponse;
use netvisor::server::shared::types::metadata::HasId;
use netvisor::server::users::r#impl::base::User;
use std::process::{Child, Command};

const BASE_URL: &str = "http://localhost:60072";
const TEST_PASSWORD: &str = "TestPassword123!";

struct ContainerManager {
    container_process: Option<Child>,
}

impl ContainerManager {
    fn new() -> Self {
        Self {
            container_process: None,
        }
    }

    fn start(&mut self) -> Result<(), String> {
        println!("Starting containers with docker compose...");

        let status = Command::new("docker")
            .args([
                "compose",
                "-f",
                "docker-compose.dev.yml",
                "up",
                "--build",
                "--force-recreate",
                "--wait",
            ])
            .current_dir("..")
            .status()
            .map_err(|e| format!("Failed to start containers: {}", e))?;

        if !status.success() {
            return Err("Failed to start containers".to_string());
        }

        println!("✅ Server and daemon are healthy!");
        Ok(())
    }

    fn cleanup(&mut self) {
        println!("\nCleaning up containers...");

        if let Some(mut process) = self.container_process.take() {
            let _ = process.kill();
            let _ = process.wait();
        }

        let _ = Command::new("make")
            .arg("dev-down")
            .current_dir("..")
            .output();

        // Stop and remove containers/volumes, but keep third-party images
        let _ = Command::new("docker")
            .args([
                "compose",
                "-f",
                "docker-compose.dev.yml",
                "down",
                "-v",
                "--rmi",
                "local", // Only remove locally built images (netvisor-*), not pulled images
                "--remove-orphans",
            ])
            .current_dir("..")
            .output();

        println!("✅ All containers cleaned up successfully");
    }
}

impl Drop for ContainerManager {
    fn drop(&mut self) {
        if std::env::var("CI").is_ok() && std::thread::panicking() {
            println!("\n⚠️  Test failed in CI - leaving containers running for log inspection");
            return;
        }

        self.cleanup();
    }
}

/// Test client with authentication
struct TestClient {
    client: reqwest::Client,
}

impl TestClient {
    fn new() -> Self {
        Self {
            client: reqwest::Client::builder()
                .cookie_store(true)
                .build()
                .unwrap(),
        }
    }

    /// Register a new user and automatically login
    async fn register(&self, email: &EmailAddress, password: &str) -> Result<User, String> {
        let register_request = RegisterRequest {
            email: email.clone(),
            password: password.to_string(),
            subscribed: false,
            terms_accepted: false,
        };

        let response = self
            .client
            .post(format!("{}/api/auth/register", BASE_URL))
            .json(&register_request)
            .send()
            .await
            .map_err(|e| format!("Registration request failed: {}", e))?;

        self.parse_response(response, "register user").await
    }

    /// Login with existing credentials
    async fn login(&self, email: &EmailAddress, password: &str) -> Result<User, String> {
        let login_request = LoginRequest {
            email: email.clone(),
            password: password.to_string(),
        };

        let response = self
            .client
            .post(format!("{}/api/auth/login", BASE_URL))
            .json(&login_request)
            .send()
            .await
            .map_err(|e| format!("Login request failed: {}", e))?;

        self.parse_response(response, "login").await
    }

    /// Generic GET request
    async fn get<T: serde::de::DeserializeOwned>(&self, path: &str) -> Result<T, String> {
        let response = self
            .client
            .get(format!("{}{}", BASE_URL, path))
            .send()
            .await
            .map_err(|e| format!("GET {} failed: {}", path, e))?;

        self.parse_response(response, &format!("GET {}", path))
            .await
    }

    /// Onboarding request
    async fn onboard_request(&self) -> Result<Organization, String> {
        let response = self
            .client
            .post(format!("{}/api/onboarding", BASE_URL))
            .json(&OnboardingRequest {
                organization_name: "My Organization".to_string(),
                network_name: "My Network".to_string(),
                populate_seed_data: true,
            })
            .send()
            .await
            .map_err(|e| format!("POST /onboarding failed: {}", e))?;

        self.parse_response(response, "POST /onboarding").await
    }

    /// Parse API response
    async fn parse_response<T: serde::de::DeserializeOwned>(
        &self,
        response: reqwest::Response,
        operation: &str,
    ) -> Result<T, String> {
        let status = response.status();

        if !status.is_success() {
            let body = response
                .text()
                .await
                .unwrap_or_else(|_| "Could not read body".to_string());
            return Err(format!(
                "{} failed with status {}: {}",
                operation, status, body
            ));
        }

        let api_response = response
            .json::<ApiResponse<T>>()
            .await
            .map_err(|e| format!("Failed to parse {} response: {}", operation, e))?;

        if !api_response.success {
            let error = api_response
                .error
                .unwrap_or_else(|| "Unknown error".to_string());
            return Err(format!("{} returned error: {}", operation, error));
        }

        api_response
            .data
            .ok_or_else(|| format!("No data in {} response", operation))
    }
}

/// Generic retry helper with exponential backoff
async fn retry<T, F, Fut>(
    description: &str,
    max_retries: u32,
    delay_secs: u64,
    operation: F,
) -> Result<T, String>
where
    F: Fn() -> Fut,
    Fut: std::future::Future<Output = Result<T, String>>,
{
    let mut last_error = String::new();

    for attempt in 1..=max_retries {
        match operation().await {
            Ok(result) => {
                println!("✅ {}", description);
                return Ok(result);
            }
            Err(e) => {
                if attempt < max_retries {
                    println!(
                        "⏳ Attempt {}/{}: {} - {}",
                        attempt, max_retries, description, e
                    );
                    tokio::time::sleep(tokio::time::Duration::from_secs(delay_secs)).await;
                }
                last_error = e;
            }
        }
    }

    Err(format!("{}: {}", description, last_error))
}

async fn setup_authenticated_user(client: &TestClient) -> Result<User, String> {
    println!("\n=== Authenticating Test User ===");

    let test_email: EmailAddress = EmailAddress::new_unchecked("user@gmail.com");

    // Try to register
    match client.register(&test_email, TEST_PASSWORD).await {
        Ok(user) => {
            println!("✅ Registered new user: {}", user.base.email);
            Ok(user)
        }
        Err(e) if e.contains("already taken") => {
            // User exists, just login
            println!("User already exists, logging in...");
            client.login(&test_email, TEST_PASSWORD).await
        }
        Err(e) => Err(e),
    }
}

async fn wait_for_organization(client: &TestClient) -> Result<Organization, String> {
    retry("wait for organization to be created", 15, 2, || async {
        let organization: Option<Organization> = client.get("/api/organizations").await?;

        organization.ok_or_else(|| "No networks found yet".to_string())
    })
    .await
}

async fn onboard(client: &TestClient) -> Result<(), String> {
    retry("wait for organization to be created", 15, 2, || async {
        let _org = client.onboard_request().await?;

        Ok(())
    })
    .await
}

async fn wait_for_network(client: &TestClient) -> Result<Network, String> {
    retry("wait for network to be created", 15, 2, || async {
        let networks: Vec<Network> = client.get("/api/networks").await?;

        networks
            .first()
            .cloned()
            .ok_or_else(|| "No networks found yet".to_string())
    })
    .await
}

async fn wait_for_daemon(client: &TestClient) -> Result<Daemon, String> {
    retry("wait for daemon registration", 15, 2, || async {
        let daemons: Vec<Daemon> = client.get(&format!("/api/daemons")).await?;

        if daemons.is_empty() {
            return Err("No daemons registered yet".to_string());
        }

        if daemons.len() != 1 {
            return Err(format!("Expected 1 daemon, found {}", daemons.len()));
        }

        Ok(daemons.into_iter().next().unwrap())
    })
    .await
}

async fn run_discovery(client: &TestClient) -> Result<(), String> {
    // Connect to SSE stream
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

                                    // Only care about Network discovery, not SelfReport
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

async fn verify_home_assistant_discovered(client: &TestClient) -> Result<Service, String> {
    println!("\n=== Verifying Home Assistant Discovery ===");

    retry("find Home Assistant service", 10, 2, || async {
        let services: Vec<Service> = client.get(&format!("/api/services")).await?;

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

#[tokio::test]
async fn test_full_integration() {
    // Start containers
    let mut container_manager = ContainerManager::new();
    container_manager
        .start()
        .expect("Failed to start containers");

    let client = TestClient::new();

    // Authenticate
    let user = setup_authenticated_user(&client)
        .await
        .expect("Failed to authenticate user");
    println!("✅ Authenticated as: {}", user.base.email);

    // Wait for organization
    println!("\n=== Waiting for Organization ===");
    let organization = wait_for_organization(&client)
        .await
        .expect("Failed to find organization");
    println!("✅ Organization: {}", organization.base.name);

    // Onboard
    println!("\n=== Onboarding ===");
    onboard(&client).await.expect("Failed to onboard");
    println!("✅ Onboarded");

    // Wait for network
    println!("\n=== Waiting for Network ===");
    let network = wait_for_network(&client)
        .await
        .expect("Failed to find network");
    println!("✅ Network: {}", network.base.name);

    // Wait for daemon
    println!("\n=== Waiting for Daemon ===");
    let daemon = wait_for_daemon(&client)
        .await
        .expect("Failed to find daemon");
    println!("✅ Daemon registered: {}", daemon.id);

    // Run discovery
    run_discovery(&client).await.expect("Discovery failed");

    // Verify service discovered
    let _service = verify_home_assistant_discovered(&client)
        .await
        .expect("Failed to find Home Assistant");

    #[cfg(feature = "generate-fixtures")]
    {
        generate_fixtures().await;
    }

    println!("\n✅ All integration tests passed!");
    println!("   ✓ User authenticated");
    println!("   ✓ Network created");
    println!("   ✓ Daemon registered");
    println!("   ✓ Discovery completed");
    println!("   ✓ Home Assistant discovered");
}

#[cfg(feature = "generate-fixtures")]
use netvisor::server::{
    services::{definitions::ServiceDefinitionRegistry, r#impl::definitions::ServiceDefinition},
    shared::types::metadata::TypeMetadata,
};

#[cfg(feature = "generate-fixtures")]
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

#[cfg(feature = "generate-fixtures")]
async fn generate_db_fixture() -> Result<(), Box<dyn std::error::Error>> {
    let output = std::process::Command::new("docker")
        .args([
            "exec",
            "netvisor-postgres-dev-1",
            "pg_dump",
            "-U",
            "postgres",
            "-d",
            "netvisor",
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
        std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("src/tests/netvisor-next.sql");
    std::fs::write(&fixture_path, output.stdout)?;

    println!("✅ Generated netvisor-next.sql from test data");
    Ok(())
}

#[cfg(feature = "generate-fixtures")]
async fn generate_daemon_config_fixture() -> Result<(), Box<dyn std::error::Error>> {
    // First, find the config file location in the container
    let find_output = std::process::Command::new("docker")
        .args([
            "exec",
            "netvisor-daemon-1",
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

    // Now read the config file
    let output = std::process::Command::new("docker")
        .args(["exec", "netvisor-daemon-1", "cat", &config_path])
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

#[cfg(feature = "generate-fixtures")]
async fn generate_services_json() -> Result<(), Box<dyn std::error::Error>> {
    let services: Vec<serde_json::Value> = ServiceDefinitionRegistry::all_service_definitions()
        .iter()
        .map(|s| {
            serde_json::json!({
                "logo_url": s.logo_url(),
                "name": s.name(),
                "description": s.description(),
                "discovery_pattern": s.discovery_pattern().to_string(),
                "category": s.category()
            })
        })
        .collect();

    // Write JSON file
    let json_string = serde_json::to_string_pretty(&services)?;
    let json_path = std::path::Path::new("../ui/static/services-next.json");
    tokio::fs::write(json_path, json_string).await?;

    Ok(())
}

#[cfg(feature = "generate-fixtures")]
async fn generate_services_markdown() -> Result<(), Box<dyn std::error::Error>> {
    use std::collections::HashMap;

    let services = ServiceDefinitionRegistry::all_service_definitions();

    // Group services by category
    let mut by_category: HashMap<String, Vec<&Box<dyn ServiceDefinition>>> = HashMap::new();
    for service in &services {
        let category = service.category().to_string();
        by_category.entry(category).or_default().push(service);
    }

    // Sort categories for consistent output
    let mut categories: Vec<String> = by_category.keys().cloned().collect();
    categories.sort();

    let mut markdown = String::from("# NetVisor Service Definitions\n\n");
    markdown.push_str("This document lists all services that NetVisor can automatically discover and identify.\n\n");

    for category in categories {
        let services = by_category.get(&category).unwrap();

        // Add category header
        markdown.push_str(&format!("## {}\n\n", category));

        // Use HTML table with dark theme styling
        markdown.push_str("<table style=\"background-color: #1a1d29; border-collapse: collapse; width: 100%;\">\n");
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

        // Sort services by name within category
        let mut sorted_services = services.clone();
        sorted_services.sort_by_key(|s| s.name());

        for service in sorted_services {
            let logo_url = service.logo_url();
            let name = service.name();
            let description = service.description();
            let pattern = service.discovery_pattern().to_string();

            // Format logo
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

#[cfg(feature = "generate-fixtures")]
async fn generate_billing_plans_json() -> Result<(), Box<dyn std::error::Error>> {
    use netvisor::server::billing::plans::get_all_plans;
    use netvisor::server::billing::types::features::Feature;
    use netvisor::server::shared::types::metadata::MetadataProvider;
    use strum::IntoEnumIterator;

    // Get all plans (monthly + yearly)
    let plans = get_all_plans();

    // Convert to metadata format (same as API returns)
    let plan_metadata: Vec<TypeMetadata> = plans.iter().map(|p| p.to_metadata()).collect();

    // Get all features metadata
    let feature_metadata: Vec<TypeMetadata> = Feature::iter().map(|f| f.to_metadata()).collect();

    // Combine into a single structure
    let fixture = serde_json::json!({
        "billing_plans": plan_metadata,
        "features": feature_metadata,
    });

    let json_string = serde_json::to_string_pretty(&fixture)?;
    let path = std::path::Path::new("../ui/static/billing-plans-next.json");
    tokio::fs::write(path, json_string).await?;

    println!("✅ Generated billing-plans-next.json");
    Ok(())
}
