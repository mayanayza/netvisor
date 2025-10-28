use crate::server::{
    config::AppState,
    daemons::types::{
        api::{DaemonRegistrationRequest, DaemonRegistrationResponse, DaemonResponse},
        base::{Daemon, DaemonBase},
    },
    shared::types::api::{ApiError, ApiResponse, ApiResult},
};
use axum::{
    extract::{Path, Query, State}, response::Json, routing::{delete, get, post, put}, Router
};
use std::{collections::HashMap, sync::Arc};
use tracing::info;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/register", post(register_daemon))
        .route("/:id/heartbeat", put(receive_heartbeat))
        .route("/", get(get_all_daemons))
        .route("/:id", get(get_daemon))
        .route("/:id", delete(delete_daemon))
}

/// Register a new daemon
async fn register_daemon(
    State(state): State<Arc<AppState>>,
    Json(request): Json<DaemonRegistrationRequest>,
) -> ApiResult<Json<ApiResponse<DaemonRegistrationResponse>>> {
    let service = &state.services.daemon_service;

    let daemon = Daemon::new(
        request.daemon_id,
        DaemonBase {
            host_id: request.host_id,
            network_id: request.network_id,
            ip: request.daemon_ip,
            port: request.daemon_port,
        },
    );

    let registered_daemon = service
        .register_daemon(daemon)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to register daemon: {}", e)))?;

    Ok(Json(ApiResponse::success(DaemonRegistrationResponse {
        daemon: registered_daemon,
    })))
}

/// Receive heartbeat from daemon
async fn receive_heartbeat(
    State(state): State<Arc<AppState>>,
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
    Query(params): Query<HashMap<String, String>>,
) -> ApiResult<Json<ApiResponse<Vec<Daemon>>>> {
    let network_id = params
        .get("network_id")
        .and_then(|id| Uuid::parse_str(id).ok())
        .ok_or_else(|| ApiError::bad_request("network_id query parameter required"))?;

    let service = &state.services.daemon_service;

    let daemons = service.get_all_daemons(&network_id).await.map_err(|e| {
        info!("Error getting daemons: {}", e);
        ApiError::internal_error(&format!("Failed to get daemons: {}", e))
    })?;

    Ok(Json(ApiResponse::success(daemons)))
}

/// Get specific daemon by ID
async fn get_daemon(
    State(state): State<Arc<AppState>>,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<DaemonResponse>>> {
    let service = &state.services.daemon_service;

    let daemon = service
        .get_daemon(&id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to get daemon: {}", e)))?
        .ok_or_else(|| ApiError::not_found(format!("Daemon '{}' not found", &id)))?;

    Ok(Json(ApiResponse::success(DaemonResponse { daemon })))
}

async fn delete_daemon(
    State(state): State<Arc<AppState>>,
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