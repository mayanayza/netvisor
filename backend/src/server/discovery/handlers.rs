use crate::server::shared::storage::traits::StorableEntity;
use crate::server::{
    auth::middleware::{
        auth::{AuthenticatedDaemon, AuthenticatedUser},
        permissions::RequireMember,
    },
    config::AppState,
    daemons::r#impl::api::DiscoveryUpdatePayload,
    discovery::r#impl::{
        base::Discovery,
        types::{DiscoveryType, RunType},
    },
    shared::{
        handlers::traits::{
            CrudHandlers, bulk_delete_handler, delete_handler, get_all_handler, get_by_id_handler,
            update_handler,
        },
        services::traits::CrudService,
        types::api::{ApiError, ApiResponse, ApiResult},
    },
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
        .route("/", post(create_handler))
        .route("/", get(get_all_handler::<Discovery>))
        .route("/{id}", put(update_handler::<Discovery>))
        .route("/{id}", delete(delete_handler::<Discovery>))
        .route("/bulk-delete", post(bulk_delete_handler::<Discovery>))
        .route("/{id}", get(get_by_id_handler::<Discovery>))
        .route("/start-session", post(start_session))
        .route("/active-sessions", get(get_active_sessions))
        .route("/{session_id}/cancel", post(cancel_discovery))
        .route("/{session_id}/update", post(receive_discovery_update))
        .route("/stream", get(discovery_stream))
}

pub async fn create_handler(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(discovery): Json<Discovery>,
) -> ApiResult<Json<ApiResponse<Discovery>>> {
    if let Err(err) = discovery.validate() {
        tracing::warn!(
            entity_type = Discovery::table_name(),
            user_id = %user.user_id,
            error = %err,
            "Entity validation failed"
        );
        return Err(ApiError::bad_request(&format!(
            "{} validation failed: {}",
            Discovery::entity_name(),
            err
        )));
    }

    // Check if any subnets aren't on the same network as the discovery / daemon
    #[allow(clippy::single_match)]
    match &discovery.base.discovery_type {
        DiscoveryType::Network { subnet_ids, .. } => {
            for subnet_id in subnet_ids.as_ref().unwrap_or(&vec![]) {
                if let Some(subnet) = state.services.subnet_service.get_by_id(subnet_id).await?
                    && subnet.base.network_id != discovery.base.network_id
                {
                    return Err(ApiError::bad_request(&format!(
                        "Discovery is on network {}, cannot target subnet \"{}\" which is on network {}.",
                        discovery.base.network_id, subnet.base.name, subnet.base.network_id
                    )));
                }
            }
        }
        _ => (),
    }

    let service = Discovery::get_service(&state);
    let created = service
        .create(discovery, user.clone().into())
        .await
        .map_err(|e| {
            tracing::error!(
                entity_type = Discovery::table_name(),
                user_id = %user.user_id,
                error = %e,
                "Failed to create entity"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    Ok(Json(ApiResponse::success(created)))
}

/// Receive discovery progress update from daemon
async fn receive_discovery_update(
    State(state): State<Arc<AppState>>,
    _daemon: AuthenticatedDaemon,
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
    RequireMember(user): RequireMember,
    Json(discovery_id): Json<Uuid>,
) -> ApiResult<Json<ApiResponse<DiscoveryUpdatePayload>>> {
    let mut discovery = state
        .services
        .discovery_service
        .get_by_id(&discovery_id)
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
        .start_session(discovery.clone(), user.clone().into())
        .await?;

    state
        .services
        .discovery_service
        .update_discovery(discovery, user.into())
        .await?;

    Ok(Json(ApiResponse::success(update)))
}

async fn discovery_stream(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> Sse<impl Stream<Item = Result<Event, Infallible>>> {
    let mut rx = state.services.discovery_service.subscribe();
    let allowed_networks = user.network_ids;

    let stream = async_stream::stream! {
        loop {
            match rx.recv().await {
                Ok(update) => {
                    // Only emit if user has access to this discovery's network
                    if allowed_networks.contains(&update.network_id) {
                        let json = serde_json::to_string(&update).unwrap_or_default();
                        yield Ok(Event::default().data(json));
                    }
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

/// Get the latest payload from active discovery sessions
async fn get_active_sessions(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
) -> ApiResult<Json<ApiResponse<Vec<DiscoveryUpdatePayload>>>> {
    let sessions = state
        .services
        .discovery_service
        .get_all_sessions(&user.network_ids)
        .await;

    Ok(Json(ApiResponse::success(sessions)))
}

/// Cancel an active discovery session
async fn cancel_discovery(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(session_id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    state
        .services
        .discovery_service
        .cancel_session(session_id, user.into())
        .await?;

    tracing::info!("Discovery session was {} cancelled", session_id);
    Ok(Json(ApiResponse::success(())))
}
