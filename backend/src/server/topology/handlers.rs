use crate::server::{
    auth::middleware::{auth::AuthenticatedUser, permissions::RequireMember},
    config::AppState,
    shared::{
        events::types::{TelemetryEvent, TelemetryOperation},
        handlers::traits::{
            CrudHandlers, delete_handler, get_all_handler, get_by_id_handler, update_handler,
        },
        services::traits::CrudService,
        storage::traits::StorableEntity,
        types::api::{ApiError, ApiResponse, ApiResult},
    },
    topology::{service::main::BuildGraphParams, types::base::Topology},
};
use axum::{
    Router,
    extract::State,
    response::{
        Json, Sse,
        sse::{Event, KeepAlive},
    },
    routing::{delete, get, post, put},
};
use chrono::Utc;
use futures::{Stream, stream};
use std::{convert::Infallible, sync::Arc};
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", post(create_handler))
        .route("/", get(get_all_handler::<Topology>))
        .route("/{id}", put(update_handler::<Topology>))
        .route("/{id}", delete(delete_handler::<Topology>))
        .route("/{id}", get(get_by_id_handler::<Topology>))
        .route("/{id}/refresh", post(refresh))
        .route("/{id}/rebuild", post(rebuild))
        .route("/{id}/lock", post(lock))
        .route("/{id}/unlock", post(unlock))
        .route("/stream", get(staleness_stream))
}

pub async fn create_handler(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(mut topology): Json<Topology>,
) -> ApiResult<Json<ApiResponse<Topology>>> {
    if let Err(err) = topology.validate() {
        tracing::warn!(
            entity_type = Topology::table_name(),
            user_id = %user.user_id,
            error = %err,
            "Entity validation failed"
        );
        return Err(ApiError::bad_request(&format!(
            "{} validation failed: {}",
            Topology::entity_name(),
            err
        )));
    }

    tracing::debug!(
        entity_type = Topology::table_name(),
        user_id = %user.user_id,
        "Create request received"
    );

    let service = Topology::get_service(&state);

    let (hosts, interfaces, subnets, groups) =
        service.get_entity_data(topology.base.network_id).await?;

    let services = service
        .get_service_data(topology.base.network_id, &topology.base.options)
        .await?;

    let (nodes, edges) = service.build_graph(BuildGraphParams {
        options: &topology.base.options,
        hosts: &hosts,
        interfaces: &interfaces,
        subnets: &subnets,
        services: &services,
        groups: &groups,
        old_edges: &[],
        old_nodes: &[],
    });

    topology.base.hosts = hosts;
    topology.base.interfaces = interfaces;
    topology.base.services = services;
    topology.base.subnets = subnets;
    topology.base.groups = groups;
    topology.base.edges = edges;
    topology.base.nodes = nodes;
    topology.clear_stale();

    let created = service
        .create(topology, user.clone().into())
        .await
        .map_err(|e| {
            tracing::error!(
                entity_type = Topology::table_name(),
                user_id = %user.user_id,
                error = %e,
                "Failed to create entity"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    tracing::info!(
        entity_type = Topology::table_name(),
        entity_id = %created.id(),
        user_id = %user.user_id,
        "Entity created via API"
    );

    Ok(Json(ApiResponse::success(created)))
}

/// Refresh entity data. Only used when cosmetic properties (ie group color/line routing, entity names) are changed
async fn refresh(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(mut topology): Json<Topology>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let service = Topology::get_service(&state);

    let (hosts, interfaces, subnets, groups) =
        service.get_entity_data(topology.base.network_id).await?;

    let services = service
        .get_service_data(topology.base.network_id, &topology.base.options)
        .await?;

    topology.base.hosts = hosts;
    topology.base.interfaces = interfaces;
    topology.base.services = services;
    topology.base.subnets = subnets;
    topology.base.groups = groups;

    service.update(&mut topology, user.into()).await?;

    // Return will be handled through event subscriber which triggers SSE

    Ok(Json(ApiResponse::success(())))
}

/// Recalculate node and edges and refresh entity data
async fn rebuild(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(mut topology): Json<Topology>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let service = Topology::get_service(&state);

    let (hosts, interfaces, subnets, groups) =
        service.get_entity_data(topology.base.network_id).await?;

    let services = service
        .get_service_data(topology.base.network_id, &topology.base.options)
        .await?;

    let (nodes, edges) = service.build_graph(BuildGraphParams {
        options: &topology.base.options,
        hosts: &hosts,
        interfaces: &interfaces,
        subnets: &subnets,
        services: &services,
        groups: &groups,
        old_nodes: &topology.base.nodes,
        old_edges: &topology.base.edges,
    });

    topology.base.hosts = hosts;
    topology.base.interfaces = interfaces;
    topology.base.services = services;
    topology.base.subnets = subnets;
    topology.base.groups = groups;
    topology.base.edges = edges;
    topology.base.nodes = nodes;
    topology.clear_stale();

    service.update(&mut topology, user.clone().into()).await?;

    let organization = state
        .services
        .organization_service
        .get_by_id(&user.organization_id)
        .await?;

    if let Some(organization) = organization
        && organization.not_onboarded(&TelemetryOperation::FirstTopologyRebuild)
    {
        state
            .services
            .event_bus
            .publish_telemetry(TelemetryEvent {
                id: Uuid::new_v4(),
                organization_id: user.organization_id,
                operation: TelemetryOperation::FirstTopologyRebuild,
                timestamp: Utc::now(),
                authentication: user.into(),
                metadata: serde_json::json!({
                    "is_onboarding_step": true
                }),
            })
            .await?;
    }

    // Return will be handled through event subscriber which triggers SSE

    Ok(Json(ApiResponse::success(())))
}

async fn lock(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(mut topology): Json<Topology>,
) -> ApiResult<Json<ApiResponse<Topology>>> {
    let service = Topology::get_service(&state);

    topology.lock(user.user_id);

    let updated = service.update(&mut topology, user.into()).await?;

    Ok(Json(ApiResponse::success(updated)))
}

async fn unlock(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(mut topology): Json<Topology>,
) -> ApiResult<Json<ApiResponse<Topology>>> {
    let service = Topology::get_service(&state);

    topology.unlock();

    let updated = service.update(&mut topology, user.into()).await?;

    Ok(Json(ApiResponse::success(updated)))
}

async fn staleness_stream(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> Sse<impl Stream<Item = Result<Event, Infallible>>> {
    let rx = state
        .services
        .topology_service
        .subscribe_staleness_changes();

    let allowed_networks = user.network_ids;

    let stream = stream::unfold(rx, move |mut rx| {
        let allowed = allowed_networks.clone();
        async move {
            loop {
                match rx.recv().await {
                    Ok(update) => {
                        // Only emit if user has access to this topology's network
                        if allowed.contains(&update.base.network_id) {
                            let json = serde_json::to_string(&update).ok()?;
                            return Some((Ok(Event::default().data(json)), rx));
                        }
                        // Otherwise skip and wait for next message
                    }
                    Err(_) => return None,
                }
            }
        }
    });

    Sse::new(stream).keep_alive(KeepAlive::default())
}
