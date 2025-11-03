use crate::server::{
    auth::middleware::{AuthenticatedDaemon, AuthenticatedUser},
    config::AppState,
    daemons::types::{
        api::{DaemonCapabilities, DaemonRegistrationRequest, DaemonRegistrationResponse},
        base::{Daemon, DaemonBase},
    },
    discovery::types::base::{Discovery, DiscoveryBase, DiscoveryType, RunType},
    hosts::types::base::{Host, HostBase},
    shared::types::api::{ApiError, ApiResponse, ApiResult},
};
use axum::{
    Router,
    extract::{Path, State},
    response::Json,
    routing::{delete, get, post},
};
use std::sync::Arc;
use tracing::info;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", get(get_all_daemons))
        .route("/register", post(register_daemon))
        .route("/create_new_api_key", post(create_new_api_key))
        .route("/{id}/update_api_key", post(update_api_key))
        .route("/{id}/heartbeat", post(receive_heartbeat))
        .route("/{id}/update-capabilities", post(update_capabilities))
        .route("/{id}", get(get_daemon))
        .route("/{id}", delete(delete_daemon))
}

const DAILY_MIDNIGHT_CRON: &str = "0 0 0 * * *";

async fn create_new_api_key(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Json(network_id): Json<Uuid>,
) -> ApiResult<Json<ApiResponse<String>>> {
    let service = &state.services.daemon_service;

    let api_key = service.generate_api_key();

    service
        .create_pending_api_key(network_id, api_key.clone())
        .await?;

    Ok(Json(ApiResponse::success(api_key)))
}

async fn update_api_key(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Path(daemon_id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<String>>> {
    let service = &state.services.daemon_service;

    if let Some(mut daemon) = service.get_daemon(&daemon_id).await? {
        let api_key = service.generate_api_key();
        daemon.base.api_key = Some(api_key.clone());
        service.update_daemon(daemon.clone()).await?;

        Ok(Json(ApiResponse::success(api_key)))
    } else {
        Err(ApiError::not_found(format!(
            "Could not find daemon {}. Unable to generate API key.",
            daemon_id
        )))
    }
}

/// Register a new daemon
async fn register_daemon(
    State(state): State<Arc<AppState>>,
    Json(request): Json<DaemonRegistrationRequest>,
) -> ApiResult<Json<ApiResponse<DaemonRegistrationResponse>>> {
    let service = &state.services.daemon_service;

    service
        .claim_pending_api_key(request.network_id, &request.api_key)
        .await?;

    // Create a dummy host to return a host_id to the daemon
    let mut dummy_host = Host::new(HostBase::default());
    dummy_host.base.network_id = request.network_id;
    dummy_host.base.name = request.daemon_ip.to_string();

    let (host, _) = state
        .services
        .host_service
        .create_host_with_services(dummy_host, Vec::new())
        .await?;

    let daemon = Daemon::new(
        request.daemon_id,
        DaemonBase {
            host_id: host.id,
            network_id: request.network_id,
            ip: request.daemon_ip,
            port: request.daemon_port,
            api_key: Some(request.api_key),
            capabilities: request.capabilities.clone(),
        },
    );

    let registered_daemon = service
        .register_daemon(daemon)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to register daemon: {}", e)))?;

    let discovery_service = state.services.discovery_service.clone();

    let self_report_discovery = discovery_service
        .create_discovery(Discovery::new(DiscoveryBase {
            run_type: RunType::Scheduled {
                cron_schedule: DAILY_MIDNIGHT_CRON.to_string(),
                last_run: None,
                enabled: true,
            },
            discovery_type: DiscoveryType::SelfReport { host_id: host.id },
            name: format!("Self Report @ {}", request.daemon_ip),
            daemon_id: request.daemon_id,
            network_id: request.network_id,
        }))
        .await?;

    discovery_service
        .start_session(self_report_discovery)
        .await?;

    if request.capabilities.has_docker_socket {
        let docker_discovery = discovery_service
            .create_discovery(Discovery::new(DiscoveryBase {
                run_type: RunType::Scheduled {
                    cron_schedule: DAILY_MIDNIGHT_CRON.to_string(),
                    last_run: None,
                    enabled: true,
                },
                discovery_type: DiscoveryType::Docker { host_id: host.id },
                name: format!("Docker @ {}", request.daemon_ip),
                daemon_id: request.daemon_id,
                network_id: request.network_id,
            }))
            .await?;

        discovery_service.start_session(docker_discovery).await?;
    }

    let network_discovery = discovery_service
        .create_discovery(Discovery::new(DiscoveryBase {
            run_type: RunType::Scheduled {
                cron_schedule: DAILY_MIDNIGHT_CRON.to_string(),
                last_run: None,
                enabled: true,
            },
            discovery_type: DiscoveryType::Network { subnet_ids: None },
            name: format!("Network Scan @ {}", request.daemon_ip),
            daemon_id: request.daemon_id,
            network_id: request.network_id,
        }))
        .await?;

    discovery_service.start_session(network_discovery).await?;

    Ok(Json(ApiResponse::success(DaemonRegistrationResponse {
        daemon: registered_daemon,
        host_id: host.id,
    })))
}

async fn update_capabilities(
    State(state): State<Arc<AppState>>,
    _daemon: AuthenticatedDaemon,
    Path(id): Path<Uuid>,
    Json(updated_capabilities): Json<DaemonCapabilities>,
) -> ApiResult<Json<ApiResponse<()>>> {
    tracing::debug!(
        "Updating capabilities for daemon {}: {:?}",
        id,
        updated_capabilities
    );
    let service = &state.services.daemon_service;

    let mut daemon = service
        .get_daemon(&id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to get daemon: {}", e)))?
        .ok_or_else(|| ApiError::not_found(format!("Daemon '{}' not found", &id)))?;

    daemon.base.capabilities = updated_capabilities;

    service.update_daemon(daemon).await?;

    Ok(Json(ApiResponse::success(())))
}

/// Receive heartbeat from daemon
async fn receive_heartbeat(
    State(state): State<Arc<AppState>>,
    _daemon: AuthenticatedDaemon,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let service = &state.services.daemon_service;

    let daemon = service
        .get_daemon(&id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to get daemon: {}", e)))?
        .ok_or_else(|| ApiError::not_found(format!("Daemon '{}' not found", &id)))?;

    service
        .receive_heartbeat(daemon)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to update heartbeat: {}", e)))?;

    Ok(Json(ApiResponse::success(())))
}

/// Get all registered daemons
async fn get_all_daemons(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> ApiResult<Json<ApiResponse<Vec<Daemon>>>> {
    let service = &state.services.daemon_service;

    let network_ids: Vec<Uuid> = state
        .services
        .network_service
        .get_all_networks(&user.0)
        .await?
        .iter()
        .map(|n| n.id)
        .collect();

    let daemons = service.get_all_daemons(&network_ids).await.map_err(|e| {
        info!("Error getting daemons: {}", e);
        ApiError::internal_error(&format!("Failed to get daemons: {}", e))
    })?;

    Ok(Json(ApiResponse::success(daemons)))
}

/// Get specific daemon by ID
async fn get_daemon(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<Daemon>>> {
    let service = &state.services.daemon_service;

    let daemon = service
        .get_daemon(&id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to get daemon: {}", e)))?
        .ok_or_else(|| ApiError::not_found(format!("Daemon '{}' not found", &id)))?;

    Ok(Json(ApiResponse::success(daemon)))
}

async fn delete_daemon(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let service = &state.services.daemon_service;

    // Check if host exists
    if service.get_daemon(&id).await?.is_none() {
        return Err(ApiError::not_found(format!("Daemon '{}' not found", &id)));
    }

    service.delete_daemon(id).await?;

    Ok(Json(ApiResponse::success(())))
}
