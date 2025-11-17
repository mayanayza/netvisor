use crate::daemon::discovery::manager::DaemonDiscoverySessionManager;
use crate::daemon::utils::base::DaemonUtils;
use crate::daemon::utils::base::{PlatformDaemonUtils, create_system_utils};
use crate::server::daemons::r#impl::api::{DaemonCapabilities, DiscoveryUpdatePayload};
use crate::{
    daemon::shared::config::ConfigStore,
    server::{
        daemons::r#impl::api::{DaemonRegistrationRequest, DaemonRegistrationResponse},
        shared::types::api::ApiResponse,
    },
};
use anyhow::Result;
use std::net::IpAddr;
use std::{sync::Arc, time::Duration};
use uuid::Uuid;

pub struct DaemonRuntimeService {
    pub config_store: Arc<ConfigStore>,
    pub client: reqwest::Client,
    pub utils: PlatformDaemonUtils,
    pub discovery_manager: Arc<DaemonDiscoverySessionManager>,
}

impl DaemonRuntimeService {
    pub fn new(
        config_store: Arc<ConfigStore>,
        discovery_manager: Arc<DaemonDiscoverySessionManager>,
    ) -> Self {
        Self {
            config_store,
            client: reqwest::Client::new(),
            utils: create_system_utils(),
            discovery_manager,
        }
    }

    pub async fn request_work(&self) -> Result<()> {
        let api_key = self
            .config_store
            .get_api_key()
            .await?
            .ok_or_else(|| anyhow::anyhow!("API key not set"))?;
        let interval = Duration::from_secs(self.config_store.get_heartbeat_interval().await?);

        let mut interval_timer = tokio::time::interval(interval);
        interval_timer.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Skip);

        let server_target = self.config_store.get_server_url().await?;
        let daemon_id = self.config_store.get_id().await?;

        loop {
            interval_timer.tick().await;

            if self.config_store.get_network_id().await?.is_some() {
                let response = self
                    .client
                    .post(format!(
                        "{}/api/daemons/{}/request-work",
                        server_target, daemon_id
                    ))
                    .json(&daemon_id)
                    .header("Authorization", format!("Bearer {}", api_key))
                    .send()
                    .await?;

                tracing::info!(
                    daemon_id = %daemon_id,
                    "Checking for work..."
                );

                let api_response: ApiResponse<(Option<DiscoveryUpdatePayload>, bool)> =
                    response.json().await?;

                if !api_response.success {
                    let error_msg = api_response
                        .error
                        .unwrap_or_else(|| "Unknown error".to_string());
                    tracing::warn!(
                        daemon_id = %daemon_id,
                        err = %error_msg,
                        "Failed to check for work"
                    );
                } else if let Some((payload, cancel_current_session)) = api_response.data {
                    if !cancel_current_session && payload.is_none() {
                        tracing::info!(
                            daemon_id = %daemon_id,
                            "No work available at this time"
                        );
                    }

                    if cancel_current_session {
                        tracing::info!(
                            daemon_id = %daemon_id,
                            "Received cancellation request from server"
                        );
                        self.discovery_manager.cancel_current_session().await;
                    }

                    if let Some(payload) = payload
                        && !self.discovery_manager.is_discovery_running().await
                    {
                        tracing::info!(
                            daemon_id = %daemon_id,
                            session_id = %payload.session_id,
                            "Received discovery session from server"
                        );
                        self.discovery_manager
                            .initiate_session(payload.into())
                            .await;
                    }
                } else {
                    tracing::info!(
                        daemon_id = %daemon_id,
                        "No work available at this time"
                    );
                }
            } else {
                tracing::warn!(
                    daemon_id = %daemon_id,
                    "Work request skipped - network_id not configured"
                );
            }
        }
    }

    pub async fn heartbeat(&self) -> Result<()> {
        let daemon_id = self.config_store.get_id().await?;
        let api_key = self
            .config_store
            .get_api_key()
            .await?
            .ok_or_else(|| anyhow::anyhow!("API key not set"))?;
        let interval = Duration::from_secs(self.config_store.get_heartbeat_interval().await?);

        let mut interval_timer = tokio::time::interval(interval);
        interval_timer.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Skip);

        let server_target = self.config_store.get_server_url().await?;

        loop {
            interval_timer.tick().await;

            if self.config_store.get_network_id().await?.is_some() {
                let response = self
                    .client
                    .post(format!(
                        "{}/api/daemons/{}/heartbeat",
                        server_target, daemon_id
                    ))
                    .header("Authorization", format!("Bearer {}", api_key))
                    .send()
                    .await?;

                tracing::info!(
                    daemon_id = %daemon_id,
                    "Heartbeat sent"
                );

                if !response.status().is_success() {
                    let api_response: ApiResponse<()> = response.json().await?;

                    let error_msg = api_response
                        .error
                        .unwrap_or_else(|| "Unknown error".to_string());
                    tracing::error!(
                        error = %error_msg,
                        "Heartbeat failed - check network connectivity"
                    );
                }

                if let Err(e) = self.config_store.update_heartbeat().await {
                    tracing::warn!("Failed to update heartbeat timestamp: {}", e);
                }
            } else {
                tracing::warn!(
                    daemon_id = %daemon_id,
                    "Heartbeat skipped - network_id not configured"
                );
            }
        }
    }

    /// Initialize daemon services (called immediately or via /initialize endpoint)
    pub async fn initialize_services(&self, network_id: Uuid, api_key: String) -> Result<()> {
        // Ensure network_id is stored
        self.config_store.set_network_id(network_id).await?;
        self.config_store.set_api_key(api_key).await?;

        let daemon_id = self.config_store.get_id().await?;
        let has_docker_client = self.utils.get_own_docker_socket().await?;

        // Check if already registered
        if let Some(existing_host_id) = self.config_store.get_host_id().await? {
            tracing::info!("Already registered with host ID: {}", existing_host_id);
            return Ok(());
        }

        tracing::info!("Registering with server...");

        self.register_with_server(daemon_id, network_id, has_docker_client)
            .await?;

        tracing::info!(
            daemon_id = %daemon_id,
            network_id = %network_id,
            has_docker = %has_docker_client,
            "Daemon fully initialized"
        );

        Ok(())
    }

    /// Register daemon with server and return assigned ID
    pub async fn register_with_server(
        &self,
        daemon_id: Uuid,
        network_id: Uuid,
        has_docker_socket: bool,
    ) -> Result<()> {
        let bind_address = self.config_store.get_bind_address().await?;
        let mode = self.config_store.get_mode().await?;

        let daemon_ip = if bind_address == "0.0.0.0" || bind_address == "::" {
            // If binding to all interfaces, auto-detect the primary IP
            self.utils.get_own_ip_address()?
        } else {
            // Use the configured bind address as the advertised IP
            bind_address
                .parse::<IpAddr>()
                .map_err(|e| anyhow::anyhow!("Invalid bind address '{}': {}", bind_address, e))?
        };

        let daemon_port = self.config_store.get_port().await?;
        if let Some(api_key) = self.config_store.get_api_key().await? {
            tracing::info!("Registering daemon with ID: {}", daemon_id,);
            let registration_request = DaemonRegistrationRequest {
                daemon_id,
                network_id,
                daemon_ip,
                daemon_port,
                mode,
                capabilities: DaemonCapabilities {
                    has_docker_socket,
                    interfaced_subnet_ids: Vec::new(),
                },
            };

            let server_target = self.config_store.get_server_url().await?;

            let response = self
                .client
                .post(format!("{}/api/daemons/register", server_target))
                .header("Authorization", format!("Bearer {}", api_key))
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

            let response = api_response
                .data
                .ok_or_else(|| anyhow::anyhow!("No daemon data in successful response"))?;

            self.config_store.set_host_id(response.host_id).await?;

            tracing::info!(
                "Successfully registered with server, assigned ID: {}",
                response.daemon.id
            );

            Ok(())
        } else {
            anyhow::bail!("API key not set for daemon. Registration failed.")
        }
    }
}
