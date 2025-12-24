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
        handlers::{traits::create_handler},
        services::traits::CrudService,
        types::api::{ApiError, ApiResponse, ApiResult},
    },
};
use axum::{
    extract::{Path, State},
    response::{
        Json, Sse,
        sse::{Event, KeepAlive},
    },
    routing::{get, post},
};
use chrono::Utc;
use futures::Stream;
use std::{convert::Infallible, sync::Arc};
use tokio::sync::broadcast;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

// Generated handlers for operations that use generic CRUD logic
mod generated {
    use super::*;
    crate::crud_get_all_handler!(Discovery, "discoveries", "discovery");
    crate::crud_get_by_id_handler!(Discovery, "discoveries", "discovery");
    crate::crud_update_handler!(Discovery, "discoveries", "discovery");
    crate::crud_delete_handler!(Discovery, "discoveries", "discovery");
    crate::crud_bulk_delete_handler!(Discovery, "discoveries");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(generated::get_all, create_discovery))
        .routes(routes!(generated::get_by_id, generated::update, generated::delete))
        .routes(routes!(generated::bulk_delete))
        .routes(routes!(start_session))
        .routes(routes!(get_active_sessions))
        .routes(routes!(cancel_discovery))
        // Internal daemon endpoints - no OpenAPI docs
        .route("/{session_id}/update", post(receive_discovery_update))
        // SSE endpoint - no OpenAPI docs (not well-supported)
        .route("/stream", get(discovery_stream))
}

/// Create a new discovery
#[utoipa::path(
    post,
    path = "",
    tag = "discoveries",
    request_body = Discovery,
    responses(
        (status = 200, description = "Discovery created successfully", body = Discovery),
        (status = 400, description = "Invalid subnet network"),
    ),
    security(("session" = []))
)]
pub async fn create_discovery(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    Json(discovery): Json<Discovery>,
) -> ApiResult<Json<ApiResponse<Discovery>>> {
    // Custom validation: Check if any subnets aren't on the same network as the discovery
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
        DiscoveryType::Docker { .. } | DiscoveryType::SelfReport { .. } => (),
    }

    // Delegate to generic handler (handles validation, auth checks, creation)
    create_handler::<Discovery>(State(state), user, Json(discovery)).await
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

/// Start a discovery session
#[utoipa::path(
    post,
    path = "/start-session",
    tag = "discoveries",
    request_body = Uuid,
    responses(
        (status = 200, description = "Discovery session started", body = DiscoveryUpdatePayload),
        (status = 404, description = "Discovery not found"),
    ),
    security(("session" = []))
)]
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

/// Get active discovery sessions
#[utoipa::path(
    get,
    path = "/active-sessions",
    tag = "discoveries",
    responses(
        (status = 200, description = "List of active discovery sessions", body = Vec<DiscoveryUpdatePayload>),
    ),
    security(("session" = []))
)]
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

/// Cancel a discovery session
#[utoipa::path(
    post,
    path = "/{session_id}/cancel",
    tag = "discoveries",
    params(("session_id" = Uuid, Path, description = "Session ID")),
    responses(
        (status = 200, description = "Discovery session cancelled"),
    ),
    security(("session" = []))
)]
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
