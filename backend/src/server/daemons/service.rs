use crate::{
    daemon::runtime::types::InitializeDaemonRequest,
    server::{
        auth::middleware::AuthenticatedEntity,
        daemons::r#impl::{
            api::{DaemonDiscoveryRequest, DaemonDiscoveryResponse},
            base::Daemon,
        },
        hosts::r#impl::ports::PortBase,
        services::r#impl::endpoints::{ApplicationProtocol, Endpoint},
        shared::{
            entities::Entity,
            events::{
                bus::EventBus,
                types::{EntityEvent, EntityOperation},
            },
            services::traits::CrudService,
            storage::generic::GenericPostgresStorage,
            types::api::ApiResponse,
        },
    },
};
use anyhow::{Error, Result};
use async_trait::async_trait;
use chrono::Utc;
use std::sync::Arc;
use uuid::Uuid;

pub struct DaemonService {
    daemon_storage: Arc<GenericPostgresStorage<Daemon>>,
    client: reqwest::Client,
    event_bus: Arc<EventBus>,
}

#[async_trait]
impl CrudService<Daemon> for DaemonService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Daemon>> {
        &self.daemon_storage
    }

    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn entity_type() -> Entity {
        Entity::Daemon
    }
    fn get_network_id(&self, entity: &Daemon) -> Option<Uuid> {
        Some(entity.base.network_id)
    }
    fn get_organization_id(&self, _entity: &Daemon) -> Option<Uuid> {
        None
    }
}

impl DaemonService {
    pub fn new(
        daemon_storage: Arc<GenericPostgresStorage<Daemon>>,
        event_bus: Arc<EventBus>,
    ) -> Self {
        Self {
            daemon_storage,
            client: reqwest::Client::new(),
            event_bus,
        }
    }

    /// Send discovery request to daemon
    pub async fn send_discovery_request(
        &self,
        daemon_id: &Uuid,
        request: DaemonDiscoveryRequest,
        authentication: AuthenticatedEntity,
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

        let daemon_ref = &daemon;

        self.event_bus()
            .publish(EntityEvent {
                id: Uuid::new_v4(),
                entity_type: Self::entity_type(),
                entity_id: *daemon_id,
                network_id: self.get_network_id(daemon_ref),
                organization_id: self.get_organization_id(daemon_ref),
                operation: EntityOperation::Custom("discovery_request_sent"),
                timestamp: Utc::now(),
                metadata: serde_json::json!({}),
                authentication,
            })
            .await?;

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
        authentication: AuthenticatedEntity,
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

        self.event_bus()
            .publish(EntityEvent {
                id: Uuid::new_v4(),
                entity_type: Self::entity_type(),
                entity_id: daemon.id,
                network_id: self.get_network_id(daemon),
                organization_id: self.get_organization_id(daemon),
                operation: EntityOperation::Custom("discovery_cancellation_sent"),
                timestamp: Utc::now(),
                metadata: serde_json::json!({
                    "session_id": session_id
                }),
                authentication,
            })
            .await?;

        Ok(())
    }

    pub async fn initialize_local_daemon(
        &self,
        daemon_url: String,
        network_id: Uuid,
        api_key: String,
    ) -> Result<(), Error> {
        match self
            .client
            .post(format!("{}/api/initialize", daemon_url))
            .json(&InitializeDaemonRequest {
                network_id,
                api_key,
            })
            .send()
            .await
        {
            Ok(resp) => {
                let status = resp.status();

                if status.is_success() {
                    tracing::info!("Successfully initialized daemon");
                } else {
                    let body = resp
                        .text()
                        .await
                        .unwrap_or_else(|_| "Could not read body".to_string());
                    tracing::warn!("Daemon returned error. Status: {}, Body: {}", status, body);
                }
            }
            Err(e) => {
                tracing::warn!("Failed to reach daemon: {:?}", e);
            }
        }

        Ok(())
    }
}
