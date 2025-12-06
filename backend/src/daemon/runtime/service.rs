use crate::daemon::discovery::manager::DaemonDiscoverySessionManager;
use crate::daemon::shared::api_client::DaemonApiClient;
use crate::daemon::shared::config::ConfigStore;
use crate::daemon::utils::base::DaemonUtils;
use crate::daemon::utils::base::{PlatformDaemonUtils, create_system_utils};
use crate::server::daemons::r#impl::api::{
    DaemonCapabilities, DaemonRegistrationRequest, DaemonRegistrationResponse,
    DiscoveryUpdatePayload,
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

    pub async fn request_work(&self) -> Result<()> {
        let interval = Duration::from_secs(self.config.get_heartbeat_interval().await?);
        let daemon_id = self.config.get_id().await?;

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
            let api_response = match self
                .api_client
                .post_raw::<_, (Option<DiscoveryUpdatePayload>, bool)>(&path, &daemon_id)
                .await
            {
                Ok(r) => r,
                Err(e) => {
                    tracing::error!(daemon_id = %daemon_id, error = %e, "Failed to request work");
                    continue;
                }
            };

            if !api_response.success {
                let error_msg = api_response
                    .error
                    .unwrap_or_else(|| "Unknown error".to_string());
                if error_msg.contains("not found") {
                    tracing::error!(
                        daemon_id = %daemon_id,
                        error = %error_msg,
                        "Failed to check for work - Daemon ID not found on server. Please remove config and reinstall daemon."
                    );
                } else {
                    tracing::error!(daemon_id = %daemon_id, error = %error_msg, "Failed to check for work");
                }
                continue;
            }

            let Some((payload, cancel_current_session)) = api_response.data else {
                tracing::info!(daemon_id = %daemon_id, "No work available at this time");
                continue;
            };

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
    }

    pub async fn heartbeat(&self) -> Result<()> {
        let interval = Duration::from_secs(self.config.get_heartbeat_interval().await?);
        let daemon_id = self.config.get_id().await?;

        let mut interval_timer = tokio::time::interval(interval);
        interval_timer.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Skip);

        loop {
            interval_timer.tick().await;

            if self.config.get_network_id().await?.is_none() {
                tracing::warn!(daemon_id = %daemon_id, "Heartbeat skipped - network_id not configured");
                continue;
            }

            let path = format!("/api/daemons/{}/heartbeat", daemon_id);
            match self.api_client.post_empty_raw::<()>(&path).await {
                Ok(api_response) if api_response.success => {
                    tracing::info!(daemon_id = %daemon_id, "Heartbeat sent");
                }
                Ok(api_response) => {
                    let error_msg = api_response
                        .error
                        .unwrap_or_else(|| "Unknown error".to_string());
                    if error_msg.contains("not found") {
                        tracing::error!(
                            daemon_id = %daemon_id,
                            error = %error_msg,
                            "Heartbeat failed - Daemon ID not found on server. Please remove config and reinstall daemon."
                        );
                    } else {
                        tracing::error!(daemon_id = %daemon_id, error = %error_msg, "Heartbeat failed");
                    }
                }
                Err(e) => {
                    tracing::error!(
                        daemon_id = %daemon_id,
                        error = %e,
                        "Heartbeat failed - check network connectivity"
                    );
                }
            }

            if let Err(e) = self.config.update_heartbeat().await {
                tracing::warn!("Failed to update heartbeat timestamp: {}", e);
            }
        }
    }

    pub async fn initialize_services(&self, network_id: Uuid, api_key: String) -> Result<()> {
        self.config.set_network_id(network_id).await?;
        self.config.set_api_key(api_key).await?;

        let docker_proxy = self.config.get_docker_proxy().await;
        let daemon_id = self.config.get_id().await?;

        let has_docker_client = self
            .utils
            .new_local_docker_client(docker_proxy)
            .await
            .is_ok();

        if let Some(existing_host_id) = self.config.get_host_id().await? {
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

    pub async fn register_with_server(
        &self,
        daemon_id: Uuid,
        network_id: Uuid,
        has_docker_socket: bool,
    ) -> Result<()> {
        let config = self.api_client.config();
        let bind_address = config.get_bind_address().await?;
        let mode = config.get_mode().await?;

        let daemon_ip = if bind_address == "0.0.0.0" || bind_address == "::" {
            self.utils.get_own_ip_address()?
        } else {
            bind_address
                .parse::<IpAddr>()
                .map_err(|e| anyhow::anyhow!("Invalid bind address '{}': {}", bind_address, e))?
        };

        let daemon_port = config.get_port().await?;

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

        tracing::info!(daemon_id = %daemon_id, "Sending register request");

        let response: DaemonRegistrationResponse = self
            .api_client
            .post(
                "/api/daemons/register",
                &registration_request,
                "Registration failed",
            )
            .await?;

        config.set_host_id(response.host_id).await?;

        tracing::info!(
            "Successfully registered with server, assigned ID: {}",
            response.daemon.id
        );

        Ok(())
    }
}
