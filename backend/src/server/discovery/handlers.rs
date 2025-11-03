use crate::server::{
    auth::middleware::AuthenticatedUser,
    config::AppState,
    daemons::types::api::DiscoveryUpdatePayload,
    discovery::types::base::{Discovery, RunType},
    shared::types::api::{ApiError, ApiResponse, ApiResult},
};
use axum::{
    Router,
    extract::{Path, State},
    response::{
        Json, Sse,
        sse::{Event, KeepAlive},
    },
    routing::{delete, get, post, put},
};
use chrono::Utc;
use futures::Stream;
use std::{convert::Infallible, sync::Arc};
use tokio::sync::broadcast;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/start-session", post(start_session))
        .route("/{session_id}/cancel", post(cancel_discovery))
        .route("/{session_id}/update", post(receive_discovery_update))
        .route("/stream", get(discovery_stream))
        .route("/", post(create_discovery))
        .route("/", get(get_all_discoveries))
        .route("/{id}", put(update_discovery))
        .route("/{id}", delete(delete_discovery))
}

async fn create_discovery(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Json(request): Json<Discovery>,
) -> ApiResult<Json<ApiResponse<Discovery>>> {
    let service = &state.services.discovery_service;

    let created_discovery = service.create_discovery(request).await?;

    Ok(Json(ApiResponse::success(created_discovery)))
}

async fn get_all_discoveries(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> ApiResult<Json<ApiResponse<Vec<Discovery>>>> {
    let service = &state.services.discovery_service;

    let network_ids: Vec<Uuid> = state
        .services
        .network_service
        .get_all_networks(&user.0)
        .await?
        .iter()
        .map(|n| n.id)
        .collect();

    let groups = service.get_all_discoveries(&network_ids).await?;

    Ok(Json(ApiResponse::success(groups)))
}

async fn update_discovery(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Path(id): Path<Uuid>,
    Json(request): Json<Discovery>,
) -> ApiResult<Json<ApiResponse<Discovery>>> {
    let service = &state.services.discovery_service;

    let mut discovery = service
        .get_discovery(&id)
        .await?
        .ok_or_else(|| ApiError::not_found(format!("Discovery '{}' not found", &id)))?;

    discovery.base = request.base;
    let updated_discovery = service.update_discovery(discovery).await?;

    Ok(Json(ApiResponse::success(updated_discovery)))
}

async fn delete_discovery(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let service = &state.services.discovery_service;

    service.delete_discovery(&id).await?;
    Ok(Json(ApiResponse::success(())))
}

/// Receive discovery progress update from daemon
async fn receive_discovery_update(
    State(state): State<Arc<AppState>>,
    Path(_session_id): Path<Uuid>,
    Json(update): Json<DiscoveryUpdatePayload>,
) -> ApiResult<Json<ApiResponse<()>>> {
    state
        .services
        .discovery_service
        .update_session(update)
        .await?;

    Ok(Json(ApiResponse::success(())))
}

/// Endpoint to start a discovery session
async fn start_session(
    State(state): State<Arc<AppState>>,
    Json(discovery_id): Json<Uuid>,
) -> ApiResult<Json<ApiResponse<DiscoveryUpdatePayload>>> {
    let mut discovery = state
        .services
        .discovery_service
        .get_discovery(&discovery_id)
        .await?
        .ok_or_else(|| ApiError::not_found(format!("Discovery '{}' not found", &discovery_id)))?;

    // Update last_run BEFORE moving any fields
    if let RunType::Scheduled {
        ref mut last_run, ..
    } = discovery.base.run_type
    {
        *last_run = Some(Utc::now());
    } else if let RunType::AdHoc {
        ref mut last_run, ..
    } = discovery.base.run_type
    {
        *last_run = Some(Utc::now());
    }

    let update = state
        .services
        .discovery_service
        .start_session(discovery.clone())
        .await?;

    state
        .services
        .discovery_service
        .update_discovery(discovery)
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
