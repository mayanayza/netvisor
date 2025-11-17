use crate::daemon::runtime::types::DaemonAppState;
use crate::server::{
    daemons::r#impl::api::{DaemonDiscoveryRequest, DaemonDiscoveryResponse},
    shared::types::api::{ApiError, ApiResponse, ApiResult},
};
use axum::{Router, extract::State, response::Json, routing::post};
use std::sync::Arc;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<DaemonAppState>> {
    Router::new()
        .route("/initiate", post(handle_discovery_request))
        .route("/cancel", post(handle_cancel_request))
}

async fn handle_discovery_request(
    State(state): State<Arc<DaemonAppState>>,
    Json(request): Json<DaemonDiscoveryRequest>,
) -> ApiResult<Json<ApiResponse<DaemonDiscoveryResponse>>> {
    let session_id = request.session_id;
    tracing::info!(
        "Received {} discovery request, session ID {}",
        request.discovery_type,
        request.session_id
    );

    state
        .services
        .discovery_manager
        .initiate_session(request)
        .await;

    Ok(Json(ApiResponse::success(DaemonDiscoveryResponse {
        session_id,
    })))
}

async fn handle_cancel_request(
    State(state): State<Arc<DaemonAppState>>,
    Json(session_id): Json<Uuid>,
) -> ApiResult<Json<ApiResponse<Uuid>>> {
    tracing::info!(
        "Received discovery cancellation request for session {}",
        session_id
    );

    let manager = state.services.discovery_manager.clone();

    if manager.is_discovery_running().await {
        // Just signal cancellation, don't wait
        if manager.cancel_current_session().await {
            // Don't clear the task - let the spawned task do it
            Ok(Json(ApiResponse::success(session_id)))
        } else {
            Err(ApiError::internal_error(
                "Failed to cancel discovery session",
            ))
        }
    } else {
        Err(ApiError::conflict(
            "Discovery session not currently running",
        ))
    }
}
