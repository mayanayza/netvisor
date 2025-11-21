use crate::server::{
    auth::middleware::{AuthenticatedDaemon, AuthenticatedEntity},
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
        handlers::traits::{
            create_handler, delete_handler, get_all_handler, get_by_id_handler, update_handler,
        },
        services::traits::CrudService,
        storage::traits::StorableEntity,
        types::api::{ApiError, ApiResponse, ApiResult},
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
        .route("/", post(create_handler::<Daemon>))
        .route("/", get(get_all_handler::<Daemon>))
        .route("/{id}", put(update_handler::<Daemon>))
        .route("/{id}", delete(delete_handler::<Daemon>))
        .route("/{id}", get(get_by_id_handler::<Daemon>))
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
    let service = &state.services.daemon_service;

    // Create a dummy host to return a host_id to the daemon
    let mut dummy_host = Host::new(HostBase::default());
    dummy_host.base.network_id = request.network_id;
    dummy_host.base.name = request.daemon_ip.to_string();

    let (host, _) = state
        .services
        .host_service
        .create_host_with_services(dummy_host, Vec::new(), auth_daemon.clone().into())
        .await?;

    let mut daemon = Daemon::new(DaemonBase {
        host_id: host.id,
        network_id: request.network_id,
        ip: request.daemon_ip,
        port: request.daemon_port,
        capabilities: request.capabilities.clone(),
        last_seen: Utc::now(),
        mode: request.mode,
    });

    daemon.id = request.daemon_id;

    let registered_daemon = service
        .create(daemon, auth_daemon.into())
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to register daemon: {}", e)))?;

    let discovery_service = state.services.discovery_service.clone();

    let self_report_discovery = discovery_service
        .create_discovery(
            Discovery::new(DiscoveryBase {
                run_type: RunType::Scheduled {
                    cron_schedule: DAILY_MIDNIGHT_CRON.to_string(),
                    last_run: None,
                    enabled: true,
                },
                discovery_type: DiscoveryType::SelfReport { host_id: host.id },
                name: format!("Self Report @ {}", request.daemon_ip),
                daemon_id: request.daemon_id,
                network_id: request.network_id,
            }),
            AuthenticatedEntity::System,
        )
        .await?;

    discovery_service
        .start_session(self_report_discovery, AuthenticatedEntity::System)
        .await?;

    if request.capabilities.has_docker_socket {
        let docker_discovery = discovery_service
            .create_discovery(
                Discovery::new(DiscoveryBase {
                    run_type: RunType::Scheduled {
                        cron_schedule: DAILY_MIDNIGHT_CRON.to_string(),
                        last_run: None,
                        enabled: true,
                    },
                    discovery_type: DiscoveryType::Docker {
                        host_id: host.id,
                        host_naming_fallback: HostNamingFallback::BestService,
                    },
                    name: format!("Docker @ {}", request.daemon_ip),
                    daemon_id: request.daemon_id,
                    network_id: request.network_id,
                }),
                AuthenticatedEntity::System,
            )
            .await?;

        discovery_service
            .start_session(docker_discovery, AuthenticatedEntity::System)
            .await?;
    }

    let network_discovery = discovery_service
        .create_discovery(
            Discovery::new(DiscoveryBase {
                run_type: RunType::Scheduled {
                    cron_schedule: DAILY_MIDNIGHT_CRON.to_string(),
                    last_run: None,
                    enabled: true,
                },
                discovery_type: DiscoveryType::Network {
                    subnet_ids: None,
                    host_naming_fallback: HostNamingFallback::BestService,
                },
                name: format!("Network Scan @ {}", request.daemon_ip),
                daemon_id: request.daemon_id,
                network_id: request.network_id,
            }),
            AuthenticatedEntity::System,
        )
        .await?;

    discovery_service
        .start_session(network_discovery, AuthenticatedEntity::System)
        .await?;

    Ok(Json(ApiResponse::success(DaemonRegistrationResponse {
        daemon: registered_daemon,
        host_id: host.id,
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
) -> ApiResult<Json<ApiResponse<()>>> {
    let service = &state.services.daemon_service;

    let mut daemon = service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to get daemon: {}", e)))?
        .ok_or_else(|| ApiError::not_found(format!("Daemon '{}' not found", &id)))?;

    daemon.base.last_seen = Utc::now();

    service
        .update(&mut daemon, auth_daemon.into())
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to update heartbeat: {}", e)))?;

    Ok(Json(ApiResponse::success(())))
}

async fn receive_work_request(
    State(state): State<Arc<AppState>>,
    auth_daemon: AuthenticatedDaemon,
    Path(id): Path<Uuid>,
    Json(daemon_id): Json<Uuid>,
) -> ApiResult<Json<ApiResponse<(Option<DiscoveryUpdatePayload>, bool)>>> {
    let service = &state.services.daemon_service;

    let mut daemon = service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to get daemon: {}", e)))?
        .ok_or_else(|| ApiError::not_found(format!("Daemon '{}' not found", &id)))?;

    daemon.base.last_seen = Utc::now();

    service
        .update(&mut daemon, auth_daemon.clone().into())
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
