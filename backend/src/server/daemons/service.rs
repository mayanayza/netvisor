use crate::server::{
    daemons::r#impl::{
        api::{DaemonDiscoveryRequest, DaemonDiscoveryResponse},
        base::Daemon,
    },
    hosts::r#impl::ports::PortBase,
    services::r#impl::endpoints::{ApplicationProtocol, Endpoint},
    shared::{
        services::traits::CrudService, storage::generic::GenericPostgresStorage,
        types::api::ApiResponse,
    },
};
use anyhow::{Error, Result, anyhow};
use async_trait::async_trait;
use itertools::Itertools;
use std::{
    collections::HashMap,
    sync::{Arc, Mutex},
};
use uuid::Uuid;

pub struct DaemonService {
    daemon_storage: Arc<GenericPostgresStorage<Daemon>>,
    client: reqwest::Client,
    // network_id to API key
    pending_api_keys: Arc<Mutex<HashMap<Uuid, Vec<String>>>>,
}

#[async_trait]
impl CrudService<Daemon> for DaemonService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Daemon>> {
        &self.daemon_storage
    }
}

impl DaemonService {
    pub fn new(daemon_storage: Arc<GenericPostgresStorage<Daemon>>) -> Self {
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

    /// Send discovery request to daemon
    pub async fn send_discovery_request(
        &self,
        daemon_id: &Uuid,
        request: DaemonDiscoveryRequest,
    ) -> Result<(), Error> {
        let daemon = self
            .get_by_id(daemon_id)
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
            .json(&session_id)
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
