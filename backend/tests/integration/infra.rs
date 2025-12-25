//! Test infrastructure: ContainerManager, TestClient, helpers, and database utilities.

use email_address::EmailAddress;
use reqwest::StatusCode;
use scanopy::server::auth::r#impl::api::{
    LoginRequest, NetworkSetup, RegisterRequest, SetupRequest, SetupResponse,
};
use scanopy::server::daemons::r#impl::base::Daemon;
use scanopy::server::networks::r#impl::Network;
use scanopy::server::organizations::r#impl::base::Organization;
use scanopy::server::shared::types::api::ApiResponse;
use scanopy::server::users::r#impl::base::User;
use serde::Serialize;
use serde::de::DeserializeOwned;
use std::process::{Child, Command};
use uuid::Uuid;

pub const BASE_URL: &str = "http://localhost:60072";
pub const TEST_PASSWORD: &str = "TestPassword123!";

// =============================================================================
// Container Management
// =============================================================================

pub struct ContainerManager {
    container_process: Option<Child>,
}

impl ContainerManager {
    pub fn new() -> Self {
        Self {
            container_process: None,
        }
    }

    pub fn start(&mut self) -> Result<(), String> {
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

    pub fn cleanup(&mut self) {
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
            .args([
                "compose",
                "-f",
                "docker-compose.dev.yml",
                "down",
                "-v",
                "--rmi",
                "local",
                "--remove-orphans",
            ])
            .current_dir("..")
            .output();

        println!("✅ All containers cleaned up successfully");
    }
}

impl Drop for ContainerManager {
    fn drop(&mut self) {
        if std::thread::panicking() && std::env::var("CI").is_ok() {
            println!("\n⚠️  Test failed in CI - leaving containers running for log collection");
            return;
        }
        self.cleanup();
    }
}

// =============================================================================
// Test Client
// =============================================================================

pub struct TestClient {
    pub client: reqwest::Client,
}

impl TestClient {
    pub fn new() -> Self {
        Self {
            client: reqwest::Client::builder()
                .cookie_store(true)
                .build()
                .unwrap(),
        }
    }

    pub async fn register(&self, email: &EmailAddress, password: &str) -> Result<User, String> {
        let register_request = RegisterRequest {
            email: email.clone(),
            password: password.to_string(),
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

    pub async fn login(&self, email: &EmailAddress, password: &str) -> Result<User, String> {
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

    pub async fn get<T: DeserializeOwned>(&self, path: &str) -> Result<T, String> {
        let response = self
            .client
            .get(format!("{}{}", BASE_URL, path))
            .send()
            .await
            .map_err(|e| format!("GET {} failed: {}", path, e))?;

        self.parse_response(response, &format!("GET {}", path))
            .await
    }

    pub async fn post<T: DeserializeOwned, B: Serialize>(
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

    pub async fn put<T: DeserializeOwned, B: Serialize>(
        &self,
        path: &str,
        body: &B,
    ) -> Result<T, String> {
        let response = self
            .client
            .put(format!("{}{}", BASE_URL, path))
            .json(body)
            .send()
            .await
            .map_err(|e| format!("PUT {} failed: {}", path, e))?;

        self.parse_response(response, &format!("PUT {}", path))
            .await
    }

    /// DELETE request that doesn't expect response data (just success: true)
    pub async fn delete_no_content(&self, path: &str) -> Result<(), String> {
        let response = self
            .client
            .delete(format!("{}{}", BASE_URL, path))
            .send()
            .await
            .map_err(|e| format!("DELETE {} failed: {}", path, e))?;

        let status = response.status();
        if !status.is_success() {
            let body = response.text().await.unwrap_or_default();
            return Err(format!(
                "DELETE {} failed with status {}: {}",
                path, status, body
            ));
        }

        Ok(())
    }

    pub async fn post_expect_status<B: Serialize>(
        &self,
        path: &str,
        body: &B,
        expected_status: StatusCode,
    ) -> Result<String, String> {
        let response = self
            .client
            .post(format!("{}{}", BASE_URL, path))
            .json(body)
            .send()
            .await
            .map_err(|e| format!("POST {} failed: {}", path, e))?;

        let status = response.status();
        let body = response.text().await.unwrap_or_default();

        if status == expected_status {
            Ok(body)
        } else {
            Err(format!(
                "Expected status {}, got {}: {}",
                expected_status, status, body
            ))
        }
    }

    pub async fn get_expect_status(
        &self,
        path: &str,
        expected_status: StatusCode,
    ) -> Result<String, String> {
        let response = self
            .client
            .get(format!("{}{}", BASE_URL, path))
            .send()
            .await
            .map_err(|e| format!("GET {} failed: {}", path, e))?;

        let status = response.status();
        let body = response.text().await.unwrap_or_default();

        if status == expected_status {
            Ok(body)
        } else {
            Err(format!(
                "Expected status {}, got {}: {}",
                expected_status, status, body
            ))
        }
    }

    pub async fn setup(&self, request: &SetupRequest) -> Result<SetupResponse, String> {
        let response = self
            .client
            .post(format!("{}/api/auth/setup", BASE_URL))
            .json(request)
            .send()
            .await
            .map_err(|e| format!("POST /auth/setup failed: {}", e))?;

        self.parse_response(response, "POST /auth/setup").await
    }

    async fn parse_response<T: DeserializeOwned>(
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

// =============================================================================
// Test Context
// =============================================================================

pub struct TestContext {
    pub client: TestClient,
    pub network_id: Uuid,
    pub organization_id: Uuid,
}

// =============================================================================
// Helper Functions
// =============================================================================

pub async fn retry<T, F, Fut>(
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

pub async fn setup_authenticated_user(client: &TestClient) -> Result<User, String> {
    println!("\n=== Authenticating Test User ===");

    let test_email: EmailAddress = EmailAddress::new_unchecked("user@gmail.com");

    let setup_request = SetupRequest {
        organization_name: "My Organization".to_string(),
        networks: vec![NetworkSetup {
            name: "My Network".to_string(),
        }],
    };

    match client.setup(&setup_request).await {
        Ok(response) => {
            println!(
                "✅ Setup completed, network_ids: {:?}",
                response.network_ids
            );
        }
        Err(e) => {
            println!("⚠️  Setup failed (may already be registered): {}", e);
        }
    }

    match client.register(&test_email, TEST_PASSWORD).await {
        Ok(user) => {
            println!("✅ Registered new user: {}", user.base.email);
            Ok(user)
        }
        Err(e) if e.contains("already taken") => {
            println!("User already exists, logging in...");
            client.login(&test_email, TEST_PASSWORD).await
        }
        Err(e) => Err(e),
    }
}

pub async fn wait_for_organization(client: &TestClient) -> Result<Organization, String> {
    retry("wait for organization to be created", 15, 2, || async {
        let organization: Option<Organization> = client.get("/api/organizations").await?;
        organization.ok_or_else(|| "No organization found yet".to_string())
    })
    .await
}

pub async fn wait_for_network(client: &TestClient) -> Result<Network, String> {
    retry("wait for network to be created", 15, 2, || async {
        let networks: Vec<Network> = client.get("/api/networks").await?;
        networks
            .first()
            .cloned()
            .ok_or_else(|| "No networks found yet".to_string())
    })
    .await
}

pub async fn wait_for_daemon(client: &TestClient) -> Result<Daemon, String> {
    retry("wait for daemon registration", 15, 2, || async {
        let daemons: Vec<Daemon> = client.get("/api/daemons").await?;

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

// =============================================================================
// Database Helpers
// =============================================================================

pub fn exec_sql(sql: &str) -> Result<String, String> {
    let output = Command::new("docker")
        .args([
            "exec",
            "scanopy-postgres-dev-1",
            "psql",
            "-U",
            "postgres",
            "-d",
            "scanopy",
            "-c",
            sql,
        ])
        .output()
        .map_err(|e| format!("Failed to execute SQL: {}", e))?;

    if !output.status.success() {
        return Err(format!(
            "SQL failed: {}",
            String::from_utf8_lossy(&output.stderr)
        ));
    }

    Ok(String::from_utf8_lossy(&output.stdout).to_string())
}

pub fn set_plan_status(status: Option<&str>) -> Result<(), String> {
    let sql = match status {
        Some(s) => format!("UPDATE organizations SET plan_status = '{}';", s),
        None => "UPDATE organizations SET plan_status = NULL;".to_string(),
    };
    exec_sql(&sql)?;
    Ok(())
}

pub fn set_billable_plan() -> Result<(), String> {
    let plan_json = r#"{"type": "Starter", "rate": "Month", "base_cents": 0, "trial_days": 0}"#;
    let sql = format!("UPDATE organizations SET plan = '{}';", plan_json);
    exec_sql(&sql)?;
    Ok(())
}

pub fn reset_plan_to_default() -> Result<(), String> {
    let plan_json = r#"{"type": "Community", "rate": "Month", "base_cents": 0, "trial_days": 0}"#;
    let sql = format!("UPDATE organizations SET plan = '{}';", plan_json);
    exec_sql(&sql)?;
    Ok(())
}
