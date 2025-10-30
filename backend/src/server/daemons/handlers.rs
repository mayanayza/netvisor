use crate::server::{
    auth::middleware::{AuthenticatedDaemon, AuthenticatedUser},
    config::AppState,
    daemons::types::{
        api::{DaemonRegistrationRequest, DaemonRegistrationResponse, GenerateKeyRequest},
        base::{Daemon, DaemonBase},
    },
    hosts::types::base::{Host, HostBase},
    shared::types::api::{ApiError, ApiResponse, ApiResult},
};
use axum::{
    Router,
    extract::{Path, State},
    response::Json,
    routing::{delete, get, post, put},
};
use std::sync::Arc;
use tracing::info;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/register", post(register_daemon))
        .route("/generate_api_key", post(generate_api_key))
        .route("/{id}/heartbeat", put(receive_heartbeat))
        .route("/", get(get_all_daemons))
        .route("/{id}", get(get_daemon))
        .route("/{id}", delete(delete_daemon))
}

async fn generate_api_key(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Json(request): Json<GenerateKeyRequest>,
) -> ApiResult<Json<ApiResponse<String>>> {
    let service = &state.services.daemon_service;

    if let Some(mut daemon) = service.get_daemon(&request.daemon_id).await? {
        let api_key = Uuid::new_v4().simple().to_string();
        daemon.base.api_key = Some(api_key.clone());
        service.update_daemon(daemon.clone()).await?;

        Ok(Json(ApiResponse::success(api_key)))
    } else {
        Err(ApiError::not_found(format!(
            "Could not find daemon {}. Unable to generate API key.",
            request.daemon_id
        )))
    }
}

/// Register a new daemon
async fn register_daemon(
    State(state): State<Arc<AppState>>,
    Json(request): Json<DaemonRegistrationRequest>,
) -> ApiResult<Json<ApiResponse<DaemonRegistrationResponse>>> {
    let service = &state.services.daemon_service;

    let api_key = Uuid::new_v4().simple().to_string();

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
            api_key: Some(api_key.clone()),
        },
    );

    let registered_daemon = service
        .register_daemon(daemon)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to register daemon: {}", e)))?;

    Ok(Json(ApiResponse::success(DaemonRegistrationResponse {
        daemon: registered_daemon,
        api_key,
        host_id: host.id,
    })))
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
