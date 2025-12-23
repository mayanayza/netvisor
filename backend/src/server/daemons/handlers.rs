use crate::server::billing::types::base::BillingPlan;
use crate::server::daemons::r#impl::api::DaemonHeartbeatPayload;
use crate::server::shared::events::types::TelemetryOperation;
use crate::server::{
    auth::middleware::auth::{AuthenticatedDaemon, AuthenticatedEntity},
    config::AppState,
    daemons::r#impl::{
        api::{
            DaemonCapabilities, DaemonRegistrationRequest, DaemonRegistrationResponse,
            DiscoveryUpdatePayload,
        },
        base::{Daemon, DaemonBase},
    },
    discovery::r#impl::{
        base::{Discovery, DiscoveryBase},
        types::{DiscoveryType, HostNamingFallback, RunType},
    },
    hosts::r#impl::base::{Host, HostBase},
    shared::{
        events::types::TelemetryEvent,
        handlers::traits::{
            bulk_delete_handler, delete_handler, get_all_handler, get_by_id_handler, update_handler,
        },
        services::traits::{CrudService, EventBusService},
        storage::traits::StorableEntity,
        types::{
            api::{ApiError, ApiResponse, ApiResult},
            entities::EntitySource,
        },
    },
};
use axum::{
    Router,
    extract::{Path, State},
    response::Json,
    routing::{delete, get, post, put},
};
use chrono::Utc;
use std::sync::Arc;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", get(get_all_handler::<Daemon>))
        .route("/{id}", put(update_handler::<Daemon>))
        .route("/{id}", delete(delete_handler::<Daemon>))
        .route("/{id}", get(get_by_id_handler::<Daemon>))
        .route("/bulk-delete", post(bulk_delete_handler::<Daemon>))
        .route("/register", post(register_daemon))
        .route("/{id}/heartbeat", post(receive_heartbeat))
        .route("/{id}/update-capabilities", post(update_capabilities))
        .route("/{id}/request-work", post(receive_work_request))
}

const DAILY_MIDNIGHT_CRON: &str = "0 0 0 * * *";

/// Register a new daemon
async fn register_daemon(
    State(state): State<Arc<AppState>>,
    auth_daemon: AuthenticatedDaemon,
    Json(request): Json<DaemonRegistrationRequest>,
) -> ApiResult<Json<ApiResponse<DaemonRegistrationResponse>>> {
    // Check if this is a demo organization - block daemon registration
    let network = state
        .services
        .network_service
        .get_by_id(&auth_daemon.network_id)
        .await?
        .ok_or_else(|| ApiError::not_found("Network not found".to_string()))?;

    let org = state
        .services
        .organization_service
        .get_by_id(&network.base.organization_id)
        .await?
        .ok_or_else(|| ApiError::not_found("Organization not found".to_string()))?;

    if matches!(org.base.plan, Some(BillingPlan::Demo(_))) {
        return Err(ApiError::forbidden(
            "Daemon registration is disabled in demo mode",
        ));
    }

    let service = &state.services.daemon_service;

    tracing::info!("{:?}", request);

    // Create a dummy host to return a host_id to the daemon
    let dummy_host = Host::new(HostBase {
        network_id: request.network_id,
        name: request.name.clone(),
        hostname: None,
        description: None,
        source: EntitySource::Discovery { metadata: vec![] },
        virtualization: None,
        hidden: false,
        tags: Vec::new(),
    });

    let host_response = state
        .services
        .host_service
        .discover_host(dummy_host, vec![], vec![], vec![], auth_daemon.into())
        .await?;

    let mut daemon = Daemon::new(DaemonBase {
        host_id: host_response.id,
        network_id: request.network_id,
        url: request.url.clone(),
        capabilities: request.capabilities.clone(),
        last_seen: Utc::now(),
        mode: request.mode,
        name: request.name,
        tags: Vec::new(),
    });

    daemon.id = request.daemon_id;

    let registered_daemon = service
        .create(daemon, auth_daemon.into())
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to register daemon: {}", e)))?;

    let org_id = state
        .services
        .network_service
        .get_by_id(&request.network_id)
        .await?
        .map(|n| n.base.organization_id)
        .unwrap_or_default();
    let organization = state
        .services
        .organization_service
        .get_by_id(&org_id)
        .await?;

    if let Some(organization) = organization
        && organization.not_onboarded(&TelemetryOperation::FirstDaemonRegistered)
    {
        state
            .services
            .daemon_service
            .event_bus()
            .publish_telemetry(TelemetryEvent {
                id: Uuid::new_v4(),
                authentication: auth_daemon.into(),
                organization_id: organization.id,
                operation: TelemetryOperation::FirstDaemonRegistered,
                timestamp: Utc::now(),
                metadata: serde_json::json!({
                    "is_onboarding_step": true
                }),
            })
            .await?;
    }

    let discovery_service = state.services.discovery_service.clone();

    let self_report_discovery_type = DiscoveryType::SelfReport {
        host_id: host_response.id,
    };

    let self_report_discovery = discovery_service
        .create_discovery(
            Discovery::new(DiscoveryBase {
                run_type: RunType::Scheduled {
                    cron_schedule: DAILY_MIDNIGHT_CRON.to_string(),
                    last_run: None,
                    enabled: true,
                },
                discovery_type: self_report_discovery_type.clone(),
                name: self_report_discovery_type.to_string(),
                daemon_id: request.daemon_id,
                network_id: request.network_id,
                tags: Vec::new(),
            }),
            AuthenticatedEntity::System,
        )
        .await?;

    discovery_service
        .start_session(self_report_discovery, AuthenticatedEntity::System)
        .await?;

    if request.capabilities.has_docker_socket {
        let docker_discovery_type = DiscoveryType::Docker {
            host_id: host_response.id,
            host_naming_fallback: HostNamingFallback::BestService,
        };

        let docker_discovery = discovery_service
            .create_discovery(
                Discovery::new(DiscoveryBase {
                    run_type: RunType::Scheduled {
                        cron_schedule: DAILY_MIDNIGHT_CRON.to_string(),
                        last_run: None,
                        enabled: true,
                    },
                    discovery_type: docker_discovery_type.clone(),
                    name: docker_discovery_type.to_string(),
                    daemon_id: request.daemon_id,
                    network_id: request.network_id,
                    tags: Vec::new(),
                }),
                AuthenticatedEntity::System,
            )
            .await?;

        discovery_service
            .start_session(docker_discovery, AuthenticatedEntity::System)
            .await?;
    }

    let network_discovery_type = DiscoveryType::Network {
        subnet_ids: None,
        host_naming_fallback: HostNamingFallback::BestService,
    };

    let network_discovery = discovery_service
        .create_discovery(
            Discovery::new(DiscoveryBase {
                run_type: RunType::Scheduled {
                    cron_schedule: DAILY_MIDNIGHT_CRON.to_string(),
                    last_run: None,
                    enabled: true,
                },
                discovery_type: network_discovery_type.clone(),
                name: network_discovery_type.to_string(),
                daemon_id: request.daemon_id,
                network_id: request.network_id,
                tags: Vec::new(),
            }),
            AuthenticatedEntity::System,
        )
        .await?;

    discovery_service
        .start_session(network_discovery, AuthenticatedEntity::System)
        .await?;

    Ok(Json(ApiResponse::success(DaemonRegistrationResponse {
        daemon: registered_daemon,
        host_id: host_response.id,
    })))
}

async fn update_capabilities(
    State(state): State<Arc<AppState>>,
    auth_daemon: AuthenticatedDaemon,
    Path(id): Path<Uuid>,
    Json(updated_capabilities): Json<DaemonCapabilities>,
) -> ApiResult<Json<ApiResponse<()>>> {
    tracing::debug!(
        id = %id,
        capabilities = %updated_capabilities,
        "Updating capabilities for daemon",
    );
    let service = &state.services.daemon_service;

    let mut daemon = service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to get daemon: {}", e)))?
        .ok_or_else(|| ApiError::not_found(format!("Daemon '{}' not found", &id)))?;

    daemon.base.capabilities = updated_capabilities;

    service.update(&mut daemon, auth_daemon.into()).await?;

    Ok(Json(ApiResponse::success(())))
}

/// Receive heartbeat from daemon
async fn receive_heartbeat(
    State(state): State<Arc<AppState>>,
    auth_daemon: AuthenticatedDaemon,
    Path(id): Path<Uuid>,
    Json(request): Json<DaemonHeartbeatPayload>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let service = &state.services.daemon_service;

    let mut daemon = service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to get daemon: {}", e)))?
        .ok_or_else(|| ApiError::not_found(format!("Daemon '{}' not found", &id)))?;

    daemon.base.last_seen = Utc::now();
    daemon.base.url = request.url;
    daemon.base.name = request.name;
    daemon.base.mode = request.mode;

    service
        .update(&mut daemon, auth_daemon.into())
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to update heartbeat: {}", e)))?;

    Ok(Json(ApiResponse::success(())))
}

async fn receive_work_request(
    State(state): State<Arc<AppState>>,
    auth_daemon: AuthenticatedDaemon,
    Path(daemon_id): Path<Uuid>,
    Json(request): Json<DaemonHeartbeatPayload>,
) -> ApiResult<Json<ApiResponse<(Option<DiscoveryUpdatePayload>, bool)>>> {
    let service = &state.services.daemon_service;

    let mut daemon = service
        .get_by_id(&daemon_id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to get daemon: {}", e)))?
        .ok_or_else(|| ApiError::not_found(format!("Daemon '{}' not found", &daemon_id)))?;

    daemon.base.last_seen = Utc::now();
    daemon.base.url = request.url;
    daemon.base.name = request.name;
    daemon.base.mode = request.mode;

    service
        .update(&mut daemon, auth_daemon.into())
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to update heartbeat: {}", e)))?;

    let sessions = state
        .services
        .discovery_service
        .get_sessions_for_daemon(&daemon_id)
        .await;
    let (cancel, session_id_to_cancel) = state
        .services
        .discovery_service
        .pull_cancellation_for_daemon(&daemon_id)
        .await;

    let next_session = sessions.first().cloned();

    service
        .receive_work_request(
            daemon,
            cancel,
            session_id_to_cancel,
            next_session.clone(),
            auth_daemon.into(),
        )
        .await?;

    Ok(Json(ApiResponse::success((next_session, cancel))))
}
