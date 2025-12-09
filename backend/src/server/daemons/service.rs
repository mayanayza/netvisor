use crate::{
    daemon::runtime::types::InitializeDaemonRequest,
    server::{
        auth::middleware::auth::AuthenticatedEntity,
        daemons::r#impl::{
            api::{DaemonDiscoveryRequest, DaemonDiscoveryResponse, DiscoveryUpdatePayload},
            base::Daemon,
        },
        shared::{
            entities::ChangeTriggersTopologyStaleness,
            events::{
                bus::EventBus,
                types::{EntityEvent, EntityOperation},
            },
            services::traits::{CrudService, EventBusService},
            storage::{
                generic::GenericPostgresStorage,
                traits::{StorableEntity, Storage},
            },
            types::api::ApiResponse,
        },
    },
};
use anyhow::anyhow;
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

impl EventBusService<Daemon> for DaemonService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, entity: &Daemon) -> Option<Uuid> {
        Some(entity.base.network_id)
    }
    fn get_organization_id(&self, _entity: &Daemon) -> Option<Uuid> {
        None
    }
}

#[async_trait]
impl CrudService<Daemon> for DaemonService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Daemon>> {
        &self.daemon_storage
    }

    /// Update entity
    async fn update(
        &self,
        entity: &mut Daemon,
        authentication: AuthenticatedEntity,
    ) -> Result<Daemon, anyhow::Error> {
        let current = self
            .get_by_id(&entity.id())
            .await?
            .ok_or_else(|| anyhow!("Could not find {}", entity))?;
        let updated = self.storage().update(entity).await?;

        let suppress_logs = updated.suppress_logs(&current);
        let trigger_stale = updated.triggers_staleness(Some(current));

        self.event_bus()
            .publish_entity(EntityEvent {
                id: Uuid::new_v4(),
                entity_id: updated.id(),
                network_id: self.get_network_id(&updated),
                organization_id: self.get_organization_id(&updated),
                entity_type: updated.clone().into(),
                operation: EntityOperation::Updated,
                timestamp: Utc::now(),
                metadata: serde_json::json!({
                    "trigger_stale": trigger_stale,
                    "suppress_logs": suppress_logs
                }),
                authentication,
            })
            .await?;

        Ok(updated)
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

        let url = format!("{}/api/discovery/initiate", daemon.base.url);

        tracing::info!(
            daemon_id = %daemon_id,
            url = %url,
            session_id = %request.session_id,
            "Attempting to send discovery request to daemon"
        );

        let response = self
            .client
            .post(url.clone())
            .json(&request)
            .send()
            .await
            .map_err(|e| {
                tracing::error!(
                    daemon_id = %daemon_id,
                    url = %url,
                    error = %e,
                    error_debug = ?e,
                    is_connect = %e.is_connect(),
                    is_timeout = %e.is_timeout(),
                    "Failed to connect to daemon"
                );
                e
            })?;

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
            .publish_entity(EntityEvent {
                id: Uuid::new_v4(),
                entity_id: *daemon_id,
                network_id: self.get_network_id(daemon_ref),
                organization_id: self.get_organization_id(daemon_ref),
                entity_type: daemon.into(),
                operation: EntityOperation::DiscoveryStarted,
                timestamp: Utc::now(),
                metadata: serde_json::json!({
                    "session_id": request.session_id
                }),
                authentication,
            })
            .await?;

        Ok(())
    }

    pub async fn send_discovery_cancellation(
        &self,
        daemon: Daemon,
        session_id: Uuid,
        authentication: AuthenticatedEntity,
    ) -> Result<(), anyhow::Error> {
        let url = format!("{}/api/discovery/cancel", daemon.base.url);

        let response = self.client.post(url).json(&session_id).send().await?;

        if !response.status().is_success() {
            anyhow::bail!(
                "Failed to send discovery cancellation to daemon {}: HTTP {}",
                daemon.id,
                response.status()
            );
        }

        self.event_bus()
            .publish_entity(EntityEvent {
                id: Uuid::new_v4(),
                entity_id: daemon.id,
                network_id: self.get_network_id(&daemon),
                organization_id: self.get_organization_id(&daemon),
                entity_type: daemon.into(),
                operation: EntityOperation::DiscoveryCancelled,
                timestamp: Utc::now(),
                metadata: serde_json::json!({
                    "session_id": session_id
                }),
                authentication,
            })
            .await?;

        Ok(())
    }

    pub async fn receive_work_request(
        &self,
        daemon: Daemon,
        cancel: bool,
        cancellation_session_id: Uuid,
        next_session: Option<DiscoveryUpdatePayload>,
        authentication: AuthenticatedEntity,
    ) -> Result<(), Error> {
        if cancel {
            self.event_bus()
                .publish_entity(EntityEvent {
                    id: Uuid::new_v4(),
                    entity_id: daemon.id,
                    network_id: self.get_network_id(&daemon),
                    organization_id: self.get_organization_id(&daemon),
                    entity_type: daemon.clone().into(),
                    operation: EntityOperation::DiscoveryCancelled,
                    timestamp: Utc::now(),
                    metadata: serde_json::json!({
                        "session_id": cancellation_session_id
                    }),
                    authentication: authentication.clone(),
                })
                .await?;
        }

        if let Some(session) = next_session {
            self.event_bus()
                .publish_entity(EntityEvent {
                    id: Uuid::new_v4(),
                    entity_id: daemon.id,
                    network_id: self.get_network_id(&daemon),
                    organization_id: self.get_organization_id(&daemon),
                    entity_type: daemon.into(),
                    operation: EntityOperation::DiscoveryStarted,
                    timestamp: Utc::now(),
                    metadata: serde_json::json!({
                        "session_id": session.session_id
                    }),
                    authentication,
                })
                .await?;
        }

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
                    tracing::warn!(
                        status = %status,
                        body = %body,
                        "Daemon returned error"
                    );
                }
            }
            Err(e) => {
                tracing::warn!(
                    error = %e,
                    "Failed to reach daemon");
            }
        }

        Ok(())
    }
}
