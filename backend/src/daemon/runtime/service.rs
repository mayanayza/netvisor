use crate::daemon::discovery::manager::DaemonDiscoverySessionManager;
use crate::daemon::discovery::service::base::{DaemonDiscoveryService, Discovery};
use crate::daemon::discovery::service::self_report::SelfReportDiscovery;
use crate::daemon::utils::base::DaemonUtils;
use crate::daemon::utils::base::{PlatformDaemonUtils, create_system_utils};
use crate::{
    daemon::shared::storage::ConfigStore,
    server::{
        daemons::types::api::{DaemonRegistrationRequest, DaemonRegistrationResponse},
        shared::types::api::ApiResponse,
    },
};
use anyhow::Result;
use std::{sync::Arc, time::Duration};
use uuid::Uuid;

pub struct DaemonRuntimeService {
    pub config_store: Arc<ConfigStore>,
    pub client: reqwest::Client,
    pub utils: PlatformDaemonUtils,
}

impl DaemonRuntimeService {
    pub fn new(config_store: Arc<ConfigStore>) -> Self {
        Self {
            config_store,
            client: reqwest::Client::new(),
            utils: create_system_utils(),
        }
    }

    pub async fn heartbeat(&self) -> Result<()> {
        let daemon_id = self.config_store.get_id().await?;
        let interval = Duration::from_secs(self.config_store.get_heartbeat_interval().await?);

        let mut interval_timer = tokio::time::interval(interval);
        interval_timer.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Skip);

        let server_target = self.config_store.get_server_endpoint().await?;

        loop {
            interval_timer.tick().await;

            if self.config_store.get_network_id().await?.is_some() {
                let response = self
                    .client
                    .put(format!(
                        "{}/api/daemons/{}/heartbeat",
                        server_target, daemon_id
                    ))
                    .send()
                    .await?;

                tracing::info!("💓 Heartbeat sent");

                if !response.status().is_success() {
                    let api_response: ApiResponse<()> = response.json().await?;

                    if !api_response.success {
                        let error_msg = api_response
                            .error
                            .unwrap_or_else(|| "Unknown error".to_string());
                        tracing::warn!("    ❤️‍🩹 Heartbeat failed: {}", error_msg);
                    }
                }

                if let Err(e) = self.config_store.update_heartbeat().await {
                    tracing::warn!("Failed to update heartbeat timestamp: {}", e);
                }
            } else {
                tracing::warn!("network_id not set, skipping heartbeat");
            }
        }
    }

    /// Initialize daemon services (called immediately or via /initialize endpoint)
    pub async fn initialize_services(
        &self,
        network_id: Uuid,
        discovery_service: Arc<DaemonDiscoveryService>,
        discovery_manager: Arc<DaemonDiscoverySessionManager>,
    ) -> Result<()> {
        // Ensure network_id is stored
        self.config_store.set_network_id(network_id).await?;

        tracing::info!("Verifying server connectivity...");
        let server_endpoint = self.config_store.get_server_endpoint().await?;
        let test_response = reqwest::Client::new()
            .get(format!("{}/api/health", server_endpoint))
            .send()
            .await?;
        tracing::info!("Server health check: {}", test_response.status());

        let daemon_id = self.config_store.get_id().await?;
        let has_docker_client = self.utils.get_own_docker_socket().await?;

        // Check if already registered
        if let Some(existing_host_id) = self.config_store.get_host_id().await? {
            tracing::info!("Already registered with host ID: {}", existing_host_id);
            return Ok(());
        }

        tracing::info!("Registering with server...");

        // Run self-discovery
        let discovery = Discovery::new(
            discovery_service.clone(),
            discovery_manager.clone(),
            SelfReportDiscovery::default(),
        );
        discovery.run_self_report_discovery().await?;

        let host_id = self
            .config_store
            .get_host_id()
            .await?
            .ok_or_else(|| anyhow::anyhow!("Host ID not set after self-report"))?;

        // Register with server
        self.register_with_server(host_id, daemon_id, network_id)
            .await?;

        // If has Docker, discover Docker services
        if has_docker_client {
            discovery.run_self_report_docker_discovery().await?;
        }

        tracing::info!("Daemon fully initialized!");

        Ok(())
    }

    /// Register daemon with server and return assigned ID
    pub async fn register_with_server(
        &self,
        host_id: Uuid,
        daemon_id: Uuid,
        network_id: Uuid,
    ) -> Result<()> {
        let daemon_ip = self.utils.get_own_ip_address()?;
        let daemon_port = self.config_store.get_port().await?;
        tracing::info!(
            "Registering daemon with ID: {}, host ID: {:?}",
            daemon_id,
            host_id
        );
        let registration_request = DaemonRegistrationRequest {
            daemon_id,
            host_id,
            network_id,
            daemon_ip,
            daemon_port,
        };

        let server_target = self.config_store.get_server_endpoint().await?;

        let response = self
            .client
            .post(format!("{}/api/daemons/register", server_target))
            .json(&registration_request)
            .send()
            .await?;

        let status = response.status();
        let api_response: ApiResponse<DaemonRegistrationResponse> = response.json().await?;

        if !status.is_success() {
            anyhow::bail!(
                "Registration failed: {}",
                api_response.error.unwrap_or("Unknown Error".to_string())
            );
        }

        if !api_response.success {
            let error_msg = api_response
                .error
                .unwrap_or_else(|| "Unknown registration error".to_string());
            anyhow::bail!("Registration failed: {}", error_msg);
        }

        let daemon_id = api_response
            .data
            .ok_or_else(|| anyhow::anyhow!("No daemon data in successful response"))?
            .daemon
            .id;

        tracing::info!(
            "Successfully registered with server, assigned ID: {}",
            daemon_id
        );

        Ok(())
    }
}
