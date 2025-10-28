use crate::server::{
    config::AppState,
    daemons::types::{
        api::{DaemonDiscoveryRequest, DiscoveryUpdatePayload},
        base::Daemon,
    },
    discovery::types::{api::InitiateDiscoveryRequest, base::DiscoveryType},
    shared::types::api::{ApiError, ApiResponse, ApiResult},
};
use axum::{
    Router,
    extract::{Path, State},
    response::{
        Json, Sse,
        sse::{Event, KeepAlive},
    },
    routing::{get, post},
};
use futures::Stream;
use std::{convert::Infallible, sync::Arc};
use tokio::sync::broadcast;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/initiate", post(user_initiate_discovery))
        .route("/daemon-initiate", post(daemon_initiate_discovery))
        .route("/:session_id/cancel", post(cancel_discovery))
        .route("/update", post(receive_discovery_update))
        .route("/stream", get(discovery_stream))
}

/// Receive discovery progress update from daemon
async fn receive_discovery_update(
    State(state): State<Arc<AppState>>,
    Json(update): Json<DiscoveryUpdatePayload>,
) -> ApiResult<Json<ApiResponse<()>>> {
    state.discovery_manager.update_session(update).await?;

    Ok(Json(ApiResponse::success(())))
}

/// Endpoint for daemon to initiate discovery
async fn daemon_initiate_discovery(
    State(state): State<Arc<AppState>>,
    Json(request): Json<InitiateDiscoveryRequest>,
) -> ApiResult<Json<ApiResponse<Uuid>>> {
    let (daemon, session_id) = initiate_discovery(state.clone(), request).await?;

    // Create discovery session
    state
        .discovery_manager
        .create_session(session_id, daemon.id)
        .await
        .map_err(|e| {
            ApiError::internal_error(&format!("Failed to create discovery session: {}", e))
        })?;

    Ok(Json(ApiResponse::success(session_id)))
}

/// Endpoint for users to initiate discovery on a specific daemon
async fn user_initiate_discovery(
    State(state): State<Arc<AppState>>,
    Json(request): Json<InitiateDiscoveryRequest>,
) -> ApiResult<Json<ApiResponse<DiscoveryUpdatePayload>>> {
    let (daemon, session_id) = initiate_discovery(state.clone(), request).await?;

    // Send discovery request to daemon
    state
        .services
        .daemon_service
        .send_discovery_request(
            &daemon,
            DaemonDiscoveryRequest {
                discovery_type: DiscoveryType::Network,
                session_id,
            },
        )
        .await?;

    // Create discovery session
    let update = state
        .discovery_manager
        .create_session(session_id, request.daemon_id)
        .await
        .map_err(|e| {
            ApiError::internal_error(&format!("Failed to create discovery session: {}", e))
        })?;

    Ok(Json(ApiResponse::success(update)))
}

async fn initiate_discovery(
    state: Arc<AppState>,
    request: InitiateDiscoveryRequest,
) -> Result<(Daemon, Uuid), ApiError> {
    let daemon_service = &state.services.daemon_service;

    // Get the specified daemon
    let daemon = match daemon_service.get_daemon(&request.daemon_id).await? {
        Some(daemon) => daemon,
        None => {
            return Err(ApiError::not_found(format!(
                "Daemon '{}' not found",
                &request.daemon_id
            )));
        }
    };

    // Check if daemon is already running discovery
    if let Some(existing_session_id) = state
        .discovery_manager
        .is_daemon_discovering(&daemon.id)
        .await
    {
        return Err(ApiError::conflict(&format!(
            "Daemon '{}' is already running discovery session '{}'",
            daemon.id, existing_session_id
        )));
    }

    Ok((daemon, Uuid::new_v4()))
}

async fn discovery_stream(
    State(state): State<Arc<AppState>>,
) -> Sse<impl Stream<Item = Result<Event, Infallible>>> {
    let mut rx = state.discovery_manager.subscribe();

    let stream = async_stream::stream! {
        loop {
            match rx.recv().await {
                Ok(update) => {
                    let json = serde_json::to_string(&update).unwrap_or_default();
                    yield Ok(Event::default().data(json));
                }
                Err(broadcast::error::RecvError::Lagged(n)) => {
                    tracing::warn!("SSE client lagged by {} messages", n);
                    continue;
                }
                Err(broadcast::error::RecvError::Closed) => break,
            }
        }
    };

    Sse::new(stream).keep_alive(KeepAlive::default())
}

/// Cancel an active discovery session
async fn cancel_discovery(
    State(state): State<Arc<AppState>>,
    Path(session_id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    // Cancel the session and get daemon ID
    let daemon_id = match state.discovery_manager.get_session(&session_id).await {
        Some(session) => session.daemon_id,
        None => {
            return Err(ApiError::not_found(format!(
                "Session '{}' not found",
                session_id
            )));
        }
    };

    let daemon_service = &state.services.daemon_service;

    if let Some(daemon) = daemon_service.get_daemon(&daemon_id).await? {
        if let Err(e) = daemon_service
            .send_discovery_cancellation(&daemon, session_id)
            .await
        {
            tracing::warn!(
                "Failed to send discovery cancellation to daemon {} for session {}: {}",
                daemon_id,
                session_id,
                e
            );
            // Don't return error - local cancellation succeeded
        } else {
            tracing::info!(
                "Cancellation request sent to daemon {} for session {}",
                daemon_id,
                session_id
            );
        }
    } else {
        tracing::warn!(
            "Daemon {} not found when trying to cancel discovery session {}",
            daemon_id,
            session_id
        );
    }

    tracing::info!("Discovery session was {} cancelled", session_id);
    Ok(Json(ApiResponse::success(())))
}
