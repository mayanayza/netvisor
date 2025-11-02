use crate::server::{
    daemons::{
        storage::DaemonStorage,
        types::{
            api::{
                DaemonDiscoveryCancellationRequest, DaemonDiscoveryRequest, DaemonDiscoveryResponse,
            },
            base::Daemon,
        },
    },
    hosts::types::ports::PortBase,
    services::types::endpoints::{ApplicationProtocol, Endpoint},
    shared::types::api::ApiResponse,
};
use anyhow::{Error, Result, anyhow};
use itertools::Itertools;
use std::{
    collections::HashMap,
    sync::{Arc, Mutex},
};
use uuid::Uuid;

pub struct DaemonService {
    daemon_storage: Arc<dyn DaemonStorage>,
    client: reqwest::Client,
    // network_id to API key
    pending_api_keys: Arc<Mutex<HashMap<Uuid, Vec<String>>>>,
}

impl DaemonService {
    pub fn new(daemon_storage: Arc<dyn DaemonStorage>) -> Self {
        Self {
            daemon_storage,
            client: reqwest::Client::new(),
            pending_api_keys: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    pub fn generate_api_key(&self) -> String {
        Uuid::new_v4().simple().to_string()
    }

    /// Create a new pending API key for a daemon to claim when it registers
    pub async fn create_pending_api_key(&self, network_id: Uuid, api_key: String) -> Result<()> {
        let mut pending_api_keys = self
            .pending_api_keys
            .lock()
            .map_err(|_| anyhow!("Failed to acquire write access to pending API keys"))?;

        pending_api_keys
            .entry(network_id)
            .or_insert_with(Vec::new)
            .push(api_key);

        Ok(())
    }

    /// Create a new pending API key for a daemon to claim when it registers
    pub async fn claim_pending_api_key(
        &self,
        network_id: Uuid,
        api_key: &String,
    ) -> Result<(), Error> {
        let mut pending_api_keys = self
            .pending_api_keys
            .lock()
            .map_err(|_| anyhow!("Failed to acquire write access to pending API keys"))?;

        if let Some(pending_keys) = pending_api_keys.get_mut(&network_id) {
            if let Some((position, _)) = pending_keys.iter().find_position(|v| *v == api_key) {
                pending_keys.remove(position);
                Ok(())
            } else {
                Err(anyhow!(
                    "API key {} is not pending for network id {}",
                    api_key,
                    network_id
                ))
            }
        } else {
            Err(anyhow!(
                "No pending API keys available for network {}",
                network_id
            ))
        }
    }

    /// Register a new daemon
    pub async fn register_daemon(&self, daemon: Daemon) -> Result<Daemon> {
        self.daemon_storage.create(&daemon).await?;
        Ok(daemon)
    }

    /// Get daemon by ID
    pub async fn get_daemon(&self, id: &Uuid) -> Result<Option<Daemon>> {
        self.daemon_storage.get_by_id(id).await
    }

    /// Get daemon by host ID
    pub async fn get_host_daemon(&self, host_id: &Uuid) -> Result<Option<Daemon>> {
        self.daemon_storage.get_by_host_id(host_id).await
    }

    /// Get daemon by API key hash
    pub async fn get_daemon_by_api_key(&self, api_key: &str) -> Result<Option<Daemon>> {
        self.daemon_storage.get_by_api_key(api_key).await
    }

    /// Get all registered daemons
    pub async fn get_all_daemons(&self, network_ids: &[Uuid]) -> Result<Vec<Daemon>> {
        self.daemon_storage.get_all(network_ids).await
    }

    /// Update daemon
    pub async fn update_daemon(&self, daemon: Daemon) -> Result<Daemon> {
        let daemon = self.daemon_storage.update(&daemon).await?;
        Ok(daemon)
    }

    /// Update daemon heartbeat
    pub async fn receive_heartbeat(&self, mut daemon: Daemon) -> Result<Daemon> {
        daemon.last_seen = chrono::Utc::now();
        let daemon = self.daemon_storage.update(&daemon).await?;
        Ok(daemon)
    }

    /// Delete daemon
    pub async fn delete_daemon(&self, id: Uuid) -> Result<()> {
        self.daemon_storage.delete(&id).await
    }

    /// Send discovery request to daemon
    pub async fn send_discovery_request(
        &self,
        daemon_id: &Uuid,
        request: DaemonDiscoveryRequest,
    ) -> Result<(), Error> {
        let daemon = self
            .get_daemon(daemon_id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Could not find daemon {}", daemon_id))?;

        let endpoint = Endpoint {
            ip: Some(daemon.base.ip),
            port_base: PortBase::new_tcp(daemon.base.port),
            protocol: ApplicationProtocol::Http,
            path: "/api/discovery/initiate".to_string(),
        };

        let response = self
            .client
            .post(format!("{}", endpoint))
            .json(&request)
            .send()
            .await?;

        if !response.status().is_success() {
            anyhow::bail!(
                "Failed to send discovery request: HTTP {}",
                response.status()
            );
        }

        let api_response: ApiResponse<DaemonDiscoveryResponse> = response.json().await?;

        if !api_response.success {
            anyhow::bail!(
                "Failed to send discovery request to daemon {}: {}",
                daemon.id,
                api_response.error.unwrap_or("Unknown error".to_string())
            );
        }

        tracing::info!(
            "Discovery request sent to daemon {} for session {}",
            daemon.id,
            request.session_id
        );
        Ok(())
    }

    pub async fn send_discovery_cancellation(
        &self,
        daemon: &Daemon,
        session_id: Uuid,
    ) -> Result<(), anyhow::Error> {
        let endpoint = Endpoint {
            ip: Some(daemon.base.ip),
            port_base: PortBase::new_tcp(daemon.base.port),
            protocol: ApplicationProtocol::Http,
            path: "/api/discovery/cancel".to_string(),
        };

        let response = self
            .client
            .post(format!("{}", endpoint))
            .json(&DaemonDiscoveryCancellationRequest { session_id })
            .send()
            .await?;

        if !response.status().is_success() {
            anyhow::bail!(
                "Failed to send discovery cancellation to daemon {}: HTTP {}",
                daemon.id,
                response.status()
            );
        }

        Ok(())
    }
}
