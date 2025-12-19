use crate::daemon::discovery::manager::DaemonDiscoverySessionManager;
use crate::daemon::shared::api_client::DaemonApiClient;
use crate::daemon::shared::config::ConfigStore;
use crate::daemon::utils::base::DaemonUtils;
use crate::daemon::utils::base::{PlatformDaemonUtils, create_system_utils};
use crate::server::daemons::r#impl::api::{
    DaemonCapabilities, DaemonHeartbeatPayload, DaemonRegistrationRequest,
    DaemonRegistrationResponse, DiscoveryUpdatePayload,
};
use anyhow::Result;
use std::net::IpAddr;
use std::sync::Arc;
use std::time::Duration;
use uuid::Uuid;

pub struct DaemonRuntimeService {
    pub config: Arc<ConfigStore>,
    pub api_client: Arc<DaemonApiClient>,
    pub utils: PlatformDaemonUtils,
    pub discovery_manager: Arc<DaemonDiscoverySessionManager>,
}

impl DaemonRuntimeService {
    pub fn new(
        config_store: Arc<ConfigStore>,
        discovery_manager: Arc<DaemonDiscoverySessionManager>,
    ) -> Self {
        Self {
            config: config_store.clone(),
            api_client: Arc::new(DaemonApiClient::new(config_store)),
            utils: create_system_utils(),
            discovery_manager,
        }
    }

    /// Check if an error indicates the API key is no longer valid (rotated/revoked).
    /// Returns Some(error) if authorization failed and the daemon should stop, None otherwise.
    fn check_authorization_error(error: &anyhow::Error, daemon_id: &Uuid) -> Option<anyhow::Error> {
        let error_str = error.to_string();
        if error_str.contains("Invalid API key") || error_str.contains("HTTP 401") {
            tracing::error!(
                daemon_id = %daemon_id,
                "API key is no longer valid. The key may have been rotated or revoked. \
                 Please reconfigure the daemon with a valid API key."
            );
            Some(anyhow::anyhow!(
                "Daemon authorization failed: API key is no longer valid"
            ))
        } else {
            None
        }
    }

    pub async fn request_work(&self) -> Result<()> {
        let interval = Duration::from_secs(self.config.get_heartbeat_interval().await?);
        let daemon_id = self.config.get_id().await?;
        let name = self.config.get_name().await?;
        let mode = self.config.get_mode().await?;
        let url = self.get_daemon_url().await?;

        let mut interval_timer = tokio::time::interval(interval);
        interval_timer.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Skip);

        loop {
            interval_timer.tick().await;

            if self.config.get_network_id().await?.is_none() {
                tracing::warn!(
                    daemon_id = %daemon_id,
                    "Work request skipped - network_id not configured"
                );
                continue;
            }

            tracing::info!(daemon_id = %daemon_id, "Checking for work...");

            let path = format!("/api/daemons/{}/request-work", daemon_id);
            let result: Result<(Option<DiscoveryUpdatePayload>, bool), _> = self
                .api_client
                .post(
                    &path,
                    &DaemonHeartbeatPayload {
                        url: url.clone(),
                        name: name.clone(),
                        mode,
                    },
                    "Failed to request work",
                )
                .await;

            match result {
                Ok((payload, cancel_current_session)) => {
                    if !cancel_current_session && payload.is_none() {
                        tracing::info!(daemon_id = %daemon_id, "No work available at this time");
                    }

                    if cancel_current_session {
                        tracing::info!(daemon_id = %daemon_id, "Received cancellation request from server");
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
                }
                Err(e) => {
                    if let Some(auth_error) = Self::check_authorization_error(&e, &daemon_id) {
                        return Err(auth_error);
                    }
                    tracing::error!(daemon_id = %daemon_id, error = %e, "Failed to request work");
                }
            }
        }
    }

    pub async fn heartbeat(&self) -> Result<()> {
        let interval = Duration::from_secs(self.config.get_heartbeat_interval().await?);
        let daemon_id = self.config.get_id().await?;
        let name = self.config.get_name().await?;
        let mode = self.config.get_mode().await?;
        let url = self.get_daemon_url().await?;

        let mut interval_timer = tokio::time::interval(interval);
        interval_timer.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Skip);

        loop {
            interval_timer.tick().await;

            if self.config.get_network_id().await?.is_none() {
                tracing::warn!(daemon_id = %daemon_id, "Heartbeat skipped - network_id not configured");
                continue;
            }

            let path = format!("/api/daemons/{}/heartbeat", daemon_id);
            match self
                .api_client
                .post_no_data::<_>(
                    &path,
                    &DaemonHeartbeatPayload {
                        url: url.clone(),
                        name: name.clone(),
                        mode,
                    },
                    "Heartbeat failed",
                )
                .await
            {
                Ok(_) => {
                    tracing::info!(daemon_id = %daemon_id, "Heartbeat sent");
                    if let Err(e) = self.config.update_heartbeat().await {
                        tracing::warn!("Failed to update heartbeat timestamp: {}", e);
                    }
                }
                Err(e) => {
                    if let Some(auth_error) = Self::check_authorization_error(&e, &daemon_id) {
                        return Err(auth_error);
                    }
                    tracing::error!(daemon_id = %daemon_id, error = %e, "Heartbeat failed");
                }
            }
        }
    }

    pub async fn initialize_services(&self, network_id: Uuid, api_key: String) -> Result<()> {
        self.config.set_network_id(network_id).await?;
        self.config.set_api_key(api_key).await?;

        let docker_proxy = self.config.get_docker_proxy().await;
        let docker_proxy_ssl_info = self.config.get_docker_proxy_ssl_info().await;
        let daemon_id = self.config.get_id().await?;

        let has_docker_client = self
            .utils
            .new_local_docker_client(docker_proxy, docker_proxy_ssl_info)
            .await
            .is_ok();

        if let Some(existing_host_id) = self.config.get_host_id().await? {
            tracing::info!(
                host_id = %existing_host_id,
                daemon_id = %daemon_id,
                network_id = %network_id,
                has_docker = %has_docker_client,
                "Already registered"
            );
            return Ok(());
        }

        tracing::info!(
            daemon_id = %daemon_id,
            network_id = %network_id,
            has_docker = %has_docker_client,
            "Registering with server"
        );

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

    // Helper function to get daemon url if override is being used, or fallback to default ip + port if not
    pub async fn get_daemon_url(&self) -> Result<String> {
        if let Some(daemon_url) = self.config.get_daemon_url().await? {
            Ok(daemon_url)
        } else {
            let bind_address = self.config.get_bind_address().await?;
            let daemon_ip = if bind_address == "0.0.0.0" || bind_address == "::" {
                self.utils.get_own_ip_address()?
            } else {
                bind_address.parse::<IpAddr>()?
            };
            let daemon_port = self.config.get_port().await?;
            Ok(format!("http://{}:{}", daemon_ip, daemon_port))
        }
    }

    pub async fn register_with_server(
        &self,
        daemon_id: Uuid,
        network_id: Uuid,
        has_docker_socket: bool,
    ) -> Result<()> {
        let config = self.api_client.config();
        let mode = config.get_mode().await?;
        let name = config.get_name().await?;

        let url = self.get_daemon_url().await?;

        let registration_request = DaemonRegistrationRequest {
            daemon_id,
            network_id,
            url: url.clone(),
            name: name.clone(),
            mode,
            capabilities: DaemonCapabilities {
                has_docker_socket,
                interfaced_subnet_ids: Vec::new(),
            },
        };

        tracing::info!(daemon_id = %daemon_id, "Sending register request");

        // Retry loop for handling pending API keys (pre-registration setup flow)
        // First attempt immediately, then wait 10s (user fills form), then exponential backoff: 1, 2, 4, 8...
        // Caps at heartbeat_interval
        let heartbeat_interval = config.get_heartbeat_interval().await?;
        let mut attempt = 0;

        loop {
            attempt += 1;

            let result: Result<DaemonRegistrationResponse, _> = self
                .api_client
                .post(
                    "/api/daemons/register",
                    &registration_request,
                    "Registration failed",
                )
                .await;

            match result {
                Ok(response) => {
                    config.set_host_id(response.host_id).await?;
                    tracing::info!(
                        "Successfully registered with server, assigned ID: {}",
                        response.daemon.id
                    );
                    return Ok(());
                }
                Err(e) => {
                    let error_str = e.to_string();

                    // Check if this is a demo mode error - provide friendly message
                    if error_str.contains("demo mode") || error_str.contains("HTTP 403") {
                        tracing::error!(
                            daemon_id = %daemon_id,
                            "This Scanopy instance is running in demo mode. \
                             Daemon registration is disabled. \
                             To use daemons, please create an account."
                        );
                        return Err(anyhow::anyhow!(
                            "Demo mode: Daemon registration is disabled on this server"
                        ));
                    }

                    // Check if this is an "Invalid API key" error
                    // This can happen when daemon is installed before user completes registration
                    if error_str.contains("Invalid API key") || error_str.contains("HTTP 401") {
                        // Calculate retry delay:
                        // Attempt 1 failed -> wait 10s (user filling out registration form)
                        // Attempt 2 failed -> wait 1s
                        // Attempt 3 failed -> wait 2s
                        // Attempt 4 failed -> wait 4s, etc.
                        // Capped at heartbeat_interval
                        let retry_secs = if attempt == 1 {
                            10 // Initial wait for user to complete registration
                        } else {
                            // Exponential backoff: 1, 2, 4, 8, 16...
                            (1u64 << (attempt - 2)).min(heartbeat_interval)
                        };

                        tracing::warn!(
                            daemon_id = %daemon_id,
                            attempt = %attempt,
                            "API key not yet active. This daemon was likely installed before account \
                             registration was completed. Waiting for account creation... \
                             Retrying in {} seconds.",
                            retry_secs
                        );

                        tokio::time::sleep(Duration::from_secs(retry_secs)).await;
                        continue;
                    }

                    // For other errors, fail immediately
                    return Err(e);
                }
            }
        }
    }
}
