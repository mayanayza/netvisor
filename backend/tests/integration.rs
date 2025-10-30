use netvisor::server::auth::types::api::{LoginRequest, RegisterRequest};
use netvisor::server::daemons::types::api::DiscoveryUpdatePayload;
use netvisor::server::daemons::types::base::Daemon;
use netvisor::server::discovery::types::api::InitiateDiscoveryRequest;
use netvisor::server::networks::types::Network;
use netvisor::server::services::definitions::home_assistant::HomeAssistant;
use netvisor::server::services::types::base::Service;
use netvisor::server::shared::types::api::ApiResponse;
use netvisor::server::shared::types::metadata::HasId;
use netvisor::server::users::types::base::User;
use std::process::{Child, Command};
use uuid::Uuid;

const BASE_URL: &str = "http://localhost:60072";
const TEST_USERNAME: &str = "testuser";
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

        let _ = Command::new("docker")
            .args(["compose", "down", "-v", "--remove-orphans"])
            .current_dir("..")
            .output();

        println!("✅ All containers cleaned up successfully");
    }
}

impl Drop for ContainerManager {
    fn drop(&mut self) {
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
    async fn register(&self, username: &str, password: &str) -> Result<User, String> {
        let register_request = RegisterRequest {
            username: username.to_string(),
            password: password.to_string(),
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
    async fn login(&self, username: &str, password: &str) -> Result<User, String> {
        let login_request = LoginRequest {
            name: username.to_string(),
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

    /// Generic POST request
    async fn post<T: serde::de::DeserializeOwned, B: serde::Serialize>(
        &self,
        path: &str,
        body: &B,
    ) -> Result<T, String> {
        let response = self
            .client
            .post(format!("{}{}", BASE_URL, path))
            .json(body)
            .send()
            .await
            .map_err(|e| format!("POST {} failed: {}", path, e))?;

        self.parse_response(response, &format!("POST {}", path))
            .await
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

    // Try to register (will fail if user exists, which is fine)
    match client.register(TEST_USERNAME, TEST_PASSWORD).await {
        Ok(user) => {
            println!("✅ Registered new user: {}", user.base.username);
            Ok(user)
        }
        Err(e) if e.contains("already taken") => {
            // User exists, just login
            println!("User already exists, logging in...");
            client.login(TEST_USERNAME, TEST_PASSWORD).await
        }
        Err(e) => Err(e),
    }
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

async fn wait_for_daemon(client: &TestClient, network_id: Uuid) -> Result<Daemon, String> {
    retry("wait for daemon registration", 15, 2, || async {
        let daemons: Vec<Daemon> = client
            .get(&format!("/api/daemons?network_id={}", network_id))
            .await?;

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

async fn run_discovery(client: &TestClient, daemon_id: Uuid) -> Result<(), String> {
    println!("\n=== Starting Discovery ===");

    let initial_update: DiscoveryUpdatePayload = client
        .post(
            "/api/discovery/initiate",
            &InitiateDiscoveryRequest { daemon_id },
        )
        .await?;

    let session_id = initial_update.session_id;
    println!("✅ Discovery session started: {}", session_id);

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
                                    if update.session_id != session_id {
                                        continue;
                                    }

                                    println!(
                                        "📊 Discovery: {} - {}/{} scanned, {} discovered",
                                        update.phase,
                                        update.completed,
                                        update.total,
                                        update.discovered_count
                                    );

                                    if update.finished_at.is_some() {
                                        if let Some(error) = &update.error {
                                            return Err(format!("Discovery failed: {}", error));
                                        }
                                        println!("✅ Discovery completed!");
                                        println!("   Total scanned: {}", update.completed);
                                        println!("   Hosts discovered: {}", update.discovered_count);
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

async fn verify_home_assistant_discovered(
    client: &TestClient,
    network_id: Uuid,
) -> Result<Service, String> {
    println!("\n=== Verifying Home Assistant Discovery ===");

    retry("find Home Assistant service", 10, 2, || async {
        let services: Vec<Service> = client
            .get(&format!("/api/services?network_id={}", network_id))
            .await?;

        if services.is_empty() {
            return Err("No services found yet".to_string());
        }

        println!("✅ Found {} service(s)", services.len());

        services
            .into_iter()
            .find(|s| s.base.service_definition.id() == HomeAssistant.id())
            .ok_or_else(|| "Home Assistant service not found".to_string())
    })
    .await
}

async fn generate_fixtures() -> Result<(), Box<dyn std::error::Error>> {
    let output = std::process::Command::new("docker")
        .args([
            "exec",
            "netvisor-postgres-1",
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
    println!("✅ Authenticated as: {}", user.base.username);

    // Wait for network
    println!("\n=== Waiting for Network ===");
    let network = wait_for_network(&client)
        .await
        .expect("Failed to find network");
    println!("✅ Network: {}", network.base.name);

    // Wait for daemon
    println!("\n=== Waiting for Daemon ===");
    let daemon = wait_for_daemon(&client, network.id)
        .await
        .expect("Failed to find daemon");
    println!("✅ Daemon registered: {}", daemon.id);

    // Run discovery
    run_discovery(&client, daemon.id)
        .await
        .expect("Discovery failed");

    // Verify service discovered
    let _service = verify_home_assistant_discovered(&client, network.id)
        .await
        .expect("Failed to find Home Assistant");

    // Generate fixtures
    generate_fixtures()
        .await
        .expect("Failed to generate fixtures");

    println!("\n✅ All integration tests passed!");
    println!("   ✓ User authenticated");
    println!("   ✓ Network created");
    println!("   ✓ Daemon registered");
    println!("   ✓ Discovery completed");
    println!("   ✓ Home Assistant discovered");
}
