use crate::server::{
    config::AppState,
    daemons::types::api::DiscoveryUpdatePayload,
    discovery::types::api::InitiateDiscoveryRequest,
    shared::types::api::{ApiResponse, ApiResult},
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
        .route("/initiate", post(create_session))
        .route("/{session_id}/cancel", post(cancel_discovery))
        .route("/update", post(receive_discovery_update))
        .route("/stream", get(discovery_stream))
}

/// Receive discovery progress update from daemon
async fn receive_discovery_update(
    State(state): State<Arc<AppState>>,
    Json(update): Json<DiscoveryUpdatePayload>,
) -> ApiResult<Json<ApiResponse<()>>> {
    state
        .services
        .discovery_service
        .update_session(update)
        .await?;

    Ok(Json(ApiResponse::success(())))
}

/// Endpoint to create a discovery session on a specific daemon
async fn create_session(
    State(state): State<Arc<AppState>>,
    Json(request): Json<InitiateDiscoveryRequest>,
) -> ApiResult<Json<ApiResponse<DiscoveryUpdatePayload>>> {
    let update = state
        .services
        .discovery_service
        .create_session(request.daemon_id, request.discovery_type)
        .await?;

    Ok(Json(ApiResponse::success(update)))
}

async fn discovery_stream(
    State(state): State<Arc<AppState>>,
) -> Sse<impl Stream<Item = Result<Event, Infallible>>> {
    let mut rx = state.services.discovery_service.subscribe();

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
    state
        .services
        .discovery_service
        .cancel_session(session_id)
        .await?;

    tracing::info!("Discovery session was {} cancelled", session_id);
    Ok(Json(ApiResponse::success(())))
}
