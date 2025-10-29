use std::process::{Child, Command};

use netvisor::server::daemons::types::api::DiscoveryUpdatePayload;
use netvisor::server::daemons::types::base::Daemon;
use netvisor::server::discovery::types::api::InitiateDiscoveryRequest;
use netvisor::server::networks::types::Network;
use netvisor::server::services::definitions::home_assistant::HomeAssistant;
use netvisor::server::services::types::base::Service;
use netvisor::server::shared::types::api::ApiResponse;
use netvisor::server::shared::types::metadata::HasId;
use netvisor::server::users::types::User;
use uuid::Uuid;

struct ContainerManager {
    container_process: Option<Child>,
}

/// Container lifecycle management
impl ContainerManager {
    fn new() -> Self {
        Self {
            container_process: None,
        }
    }

    fn start(&mut self) -> Result<(), String> {
        println!("Starting containers with docker compose...");

        // Start containers and wait for them to be healthy
        // Don't use -d, let docker compose wait for health before returning
        let status = Command::new("docker")
            .args([
                "compose",
                "-f",
                "docker-compose.dev.yml",
                "up",
                "--build",
                "--wait", // Wait for services to be healthy before returning
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

        // Kill the spawned process
        if let Some(mut process) = self.container_process.take() {
            let _ = process.kill();
            let _ = process.wait();
        }

        // Stop all containers with make dev-down
        let cleanup_output = Command::new("make")
            .arg("dev-down")
            .current_dir("..")
            .output()
            .expect("Failed to run make dev-down");

        if !cleanup_output.status.success() {
            eprintln!(
                "make dev-down failed: {}",
                String::from_utf8_lossy(&cleanup_output.stderr)
            );
        }

        // Additional safety: force kill any remaining containers
        let docker_cleanup = Command::new("docker")
            .args(["compose", "down", "-v", "--remove-orphans"])
            .current_dir("..")
            .output();

        match docker_cleanup {
            Ok(output) if output.status.success() => {
                println!("✅ All containers cleaned up successfully");
            }
            Ok(output) => {
                eprintln!(
                    "docker compose down warning: {}",
                    String::from_utf8_lossy(&output.stderr)
                );
            }
            Err(e) => {
                eprintln!("Failed to run docker compose down: {}", e);
            }
        }
    }
}

impl Drop for ContainerManager {
    fn drop(&mut self) {
        self.cleanup();
    }
}

/// Generic retry helper with exponential backoff
async fn retry_api_request<T, F, Fut>(
    description: &str,
    max_retries: u32,
    initial_delay_secs: u64,
    request_fn: F,
) -> Result<T, String>
where
    F: Fn() -> Fut,
    Fut: std::future::Future<Output = Result<T, String>>,
{
    let mut last_error = String::new();

    for attempt in 1..=max_retries {
        println!("Attempt {}/{} to {}...", attempt, max_retries, description);

        match request_fn().await {
            Ok(result) => {
                println!("✅ Successfully {}", description);
                return Ok(result);
            }
            Err(e) => {
                println!("⏳ {}: {}", description, e);
                last_error = e;
            }
        }

        if attempt < max_retries {
            tokio::time::sleep(tokio::time::Duration::from_secs(initial_delay_secs)).await;
        }
    }

    Err(last_error)
}

async fn check_user_created(client: &reqwest::Client) -> Result<User, String> {
    let user = retry_api_request("check network exists", 15, 2, || {
        let client = client.clone();

        async move {
            let response = client
                .get("http://localhost:60072/api/users")
                .send()
                .await
                .map_err(|e| format!("Request failed: {}", e))?;

            let status = response.status();
            if !status.is_success() {
                let body = response
                    .text()
                    .await
                    .unwrap_or_else(|_| "Could not read body".to_string());
                return Err(format!("Status {}: {}", status, body));
            }

            let api_response = response
                .json::<ApiResponse<Vec<User>>>()
                .await
                .map_err(|e| format!("Failed to parse response: {}", e))?;

            if !api_response.success {
                let error = api_response
                    .error
                    .unwrap_or_else(|| "Unknown error".to_string());
                return Err(format!("API returned success=false: {}", error));
            }

            let users = api_response
                .data
                .ok_or_else(|| "No data in response".to_string())?;

            if let Some(user) = users.first() {
                println!("✅ Found {}", user);
                return Ok(user.clone());
            }
            Err("Failed to find user".to_string())
        }
    })
    .await?;

    Ok(user.clone())
}

async fn check_network_created(client: &reqwest::Client, user_id: Uuid) -> Result<Network, String> {
    let network = retry_api_request("check network exists", 15, 2, || {
        let client = client.clone();

        async move {
            let response = client
                .get(format!(
                    "http://localhost:60072/api/networks?user_id={}",
                    user_id
                ))
                .send()
                .await
                .map_err(|e| format!("Request failed: {}", e))?;

            let status = response.status();
            if !status.is_success() {
                let body = response
                    .text()
                    .await
                    .unwrap_or_else(|_| "Could not read body".to_string());
                return Err(format!("Status {}: {}", status, body));
            }

            let api_response = response
                .json::<ApiResponse<Vec<Network>>>()
                .await
                .map_err(|e| format!("Failed to parse response: {}", e))?;

            if !api_response.success {
                let error = api_response
                    .error
                    .unwrap_or_else(|| "Unknown error".to_string());
                return Err(format!("API returned success=false: {}", error));
            }

            let networks = api_response
                .data
                .ok_or_else(|| "No data in response".to_string())?;

            if let Some(network) = networks.first() {
                println!("✅ Found {}", network);
                return Ok(network.clone());
            }
            Err("Failed to find network".to_string())
        }
    })
    .await?;

    Ok(network.clone())
}

/// Verify daemon is registered
async fn check_daemon_registered(
    client: &reqwest::Client,
    network_id: Uuid,
) -> Result<Daemon, String> {
    let daemons = retry_api_request("check daemon registration", 15, 2, || {
        let client = client.clone();
        async move {
            let response = client
                .get(format!(
                    "http://localhost:60072/api/daemons?network_id={}",
                    network_id
                ))
                .send()
                .await
                .map_err(|e| format!("Request failed: {}", e))?;

            let status = response.status();
            if !status.is_success() {
                let body = response
                    .text()
                    .await
                    .unwrap_or_else(|_| "Could not read body".to_string());
                return Err(format!("Status {}: {}", status, body));
            }

            let api_response = response
                .json::<ApiResponse<Vec<Daemon>>>()
                .await
                .map_err(|e| format!("Failed to parse response: {}", e))?;

            if !api_response.success {
                let error = api_response
                    .error
                    .unwrap_or_else(|| "Unknown error".to_string());
                return Err(format!("API returned success=false: {}", error));
            }

            let daemon_list = api_response
                .data
                .ok_or_else(|| "No data in response".to_string())?;

            if daemon_list.is_empty() {
                return Err("No daemons registered yet".to_string());
            }

            println!("✅ Found {} daemon(s) registered", daemon_list.len());
            Ok(daemon_list)
        }
    })
    .await?;

    if daemons.len() != 1 {
        return Err(format!(
            "Expected 1 daemon to be registered, found {}",
            daemons.len()
        ));
    }

    Ok(daemons.into_iter().next().unwrap())
}

/// Start discovery and wait for it to complete using SSE
async fn run_discovery_and_wait(client: &reqwest::Client, daemon_id: Uuid) -> Result<(), String> {
    // Initiate discovery
    println!("\n=== Starting Discovery ===");
    let response = client
        .post("http://localhost:60072/api/discovery/initiate")
        .json(&InitiateDiscoveryRequest { daemon_id })
        .send()
        .await
        .map_err(|e| format!("Failed to initiate discovery: {}", e))?;

    let status = response.status();

    if !status.is_success() {
        let body = &response
            .text()
            .await
            .unwrap_or_else(|_| "Could not read body".to_string());
        return Err(format!(
            "Discovery initiation failed with status {}: {}",
            status, body
        ));
    }

    let api_response = response
        .json::<ApiResponse<DiscoveryUpdatePayload>>()
        .await
        .map_err(|e| format!("Failed to parse discovery response: {}", e))?;

    if !api_response.success {
        let error = api_response
            .error
            .unwrap_or_else(|| "Unknown error".to_string());
        return Err(format!("Discovery initiation returned error: {}", error));
    }

    let initial_update = api_response
        .data
        .ok_or_else(|| "No session data in response".to_string())?;

    let session_id = initial_update.session_id;
    println!("✅ Discovery session started: {}", session_id);

    // Connect to SSE stream and wait for completion
    println!("🔌 Connecting to SSE stream...");

    let mut event_source = client
        .get("http://localhost:60072/api/discovery/stream")
        .send()
        .await
        .map_err(|e| format!("Failed to connect to SSE stream: {}", e))?;

    // Set a timeout for the entire discovery process
    let timeout_duration = tokio::time::Duration::from_secs(300); // 5 minutes
    let timeout = tokio::time::sleep(timeout_duration);
    tokio::pin!(timeout);

    loop {
        tokio::select! {
            _ = &mut timeout => {
                return Err("Discovery timed out after 5 minutes".to_string());
            }

            chunk = event_source.chunk() => {
                match chunk {
                    Ok(Some(bytes)) => {
                        // Parse SSE data
                        let text = String::from_utf8_lossy(&bytes);

                        // SSE format: "data: {json}\n\n"
                        for line in text.lines() {
                            if let Some(data) = line.strip_prefix("data: ") {
                                match serde_json::from_str::<DiscoveryUpdatePayload>(data) {
                                    Ok(update) => {
                                        // Only process updates for our session
                                        if update.session_id != session_id {
                                            continue;
                                        }

                                        println!(
                                            "📊 Discovery progress: {} - {}/{} scanned, {} discovered",
                                            update.phase,
                                            update.completed,
                                            update.total,
                                            update.discovered_count
                                        );

                                        // Check if discovery is complete
                                        if update.finished_at.is_some() {
                                            if let Some(error) = &update.error {
                                                return Err(format!("Discovery failed: {}", error));
                                            }
                                            println!("✅ Discovery completed successfully!");
                                            println!("   Total scanned: {}", update.completed);
                                            println!("   Hosts discovered: {}", update.discovered_count);
                                            return Ok(());
                                        }
                                    }
                                    Err(e) => {
                                        eprintln!("⚠️  Failed to parse SSE update: {} - Data: {}", e, data);
                                    }
                                }
                            }
                        }
                    }
                    Ok(None) => {
                        return Err("SSE stream ended unexpectedly".to_string());
                    }
                    Err(e) => {
                        return Err(format!("Error reading SSE stream: {}", e));
                    }
                }
            }
        }
    }
}

/// Check for Home Assistant service
async fn check_for_home_assistant_service(
    client: &reqwest::Client,
    network_id: Uuid,
) -> Result<Service, String> {
    println!("\n=== Checking for Home Assistant Service ===");

    let services = retry_api_request("fetch services", 10, 2, || {
        let client = client.clone();
        async move {
            let response = client
                .get(format!(
                    "http://localhost:60072/api/services?network_id={}",
                    network_id
                ))
                .send()
                .await
                .map_err(|e| format!("Request failed: {}", e))?;

            let status = response.status();
            if !status.is_success() {
                let body = response
                    .text()
                    .await
                    .unwrap_or_else(|_| "Could not read body".to_string());
                return Err(format!("Status {}: {}", status, body));
            }

            let api_response = response
                .json::<ApiResponse<Vec<Service>>>()
                .await
                .map_err(|e| format!("Failed to parse response: {}", e))?;

            if !api_response.success {
                let error = api_response
                    .error
                    .unwrap_or_else(|| "Unknown error".to_string());
                return Err(format!("API returned success=false: {}", error));
            }

            let service_list = api_response
                .data
                .ok_or_else(|| "No data in response".to_string())?;

            if service_list.is_empty() {
                return Err("No services found yet".to_string());
            }

            println!(
                "✅ Found {} service(s): {:?}",
                service_list.len(),
                service_list
                    .iter()
                    .map(|s| s.base.name.clone())
                    .collect::<Vec<String>>()
            );
            Ok(service_list)
        }
    })
    .await?;

    // Find Home Assistant service
    let home_assistant_service = services
        .clone()
        .into_iter()
        .find(|s| s.base.service_definition.id() == HomeAssistant.id())
        .ok_or_else(|| {
            format!(
                "Home Assistant service not found. Available services: {:?}",
                services.iter().map(|s| &s.base.name).collect::<Vec<_>>()
            )
        })?;

    println!(
        "✅ Found Home Assistant service: {:?}",
        home_assistant_service.base.name
    );

    Ok(home_assistant_service)
}

async fn generate_fixtures_from_test_data() -> Result<(), Box<dyn std::error::Error>> {
    // This test should run AFTER all other integration tests
    // The database now contains all the data created during test runs

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

    println!("✓ Generated netvisor-next.sql from integration test database");

    Ok(())
}

#[tokio::test]
async fn test_container_daemon_server_integration() {
    // Start containers
    let mut container_manager = ContainerManager::new();
    container_manager
        .start()
        .expect("Failed to start containers");

    let client = reqwest::Client::new();

    println!("\n=== Step 0: Checking User ===");
    let user = check_user_created(&client)
        .await
        .expect("Failed to verify user");
    println!("User: {}", user);

    println!("\n=== Step 1: Checking Network ===");
    let network = check_network_created(&client, user.id)
        .await
        .expect("Failed to verify network");
    println!("Network: {}", network);

    // Step 1: Check daemon registration
    println!("\n=== Step 1: Checking Daemon Registration ===");
    let daemon = check_daemon_registered(&client, network.id)
        .await
        .expect("Failed to verify daemon registration");
    println!("Daemon: {}", daemon);

    // Step 2: Run discovery and wait for completion
    println!("\n=== Step 2: Running Discovery ===");
    run_discovery_and_wait(&client, daemon.id)
        .await
        .expect("Discovery failed");

    // Step 3: Verify Home Assistant service was discovered
    println!("\n=== Step 3: Verifying Service Discovery ===");
    let _service = check_for_home_assistant_service(&client, network.id)
        .await
        .expect("Failed to find Home Assistant service");

    generate_fixtures_from_test_data()
        .await
        .expect("Failed to generate test fixtures");

    println!("\n✅ All integration tests passed!");
    println!("   ✓ Daemon registered successfully");
    println!("   ✓ Discovery completed successfully");
    println!("   ✓ Home Assistant service discovered");

    // Cleanup happens automatically via Drop trait
}
