use crate::server::{
    auth::middleware::{auth::AuthenticatedUser, permissions::RequireMember},
    config::AppState,
    shared::{
        events::types::{TelemetryEvent, TelemetryOperation},
        handlers::traits::{CrudHandlers, update_handler},
        services::traits::CrudService,
        storage::{filter::EntityFilter, traits::StorableEntity},
        types::api::{ApiError, ApiErrorResponse, ApiResponse, ApiResult, EmptyApiResponse},
    },
    topology::{
        service::main::BuildGraphParams,
        types::base::{SetEntitiesParams, Topology},
    },
};
use axum::{
    extract::{Path, State},
    response::{
        Json, Sse,
        sse::{Event, KeepAlive},
    },
    routing::get,
};
use chrono::Utc;
use futures::{Stream, stream};
use std::{convert::Infallible, sync::Arc};
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

// Generated handlers for generic CRUD operations
mod generated {
    use super::*;
    crate::crud_get_by_id_handler!(Topology, "topology", "topology");
    crate::crud_delete_handler!(Topology, "topology", "topology");
}

/// Topology endpoints are internal-only (hidden from public docs)
pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(get_all_topologies, create_topology))
        .routes(routes!(
            generated::get_by_id,
            update_topology,
            generated::delete
        ))
        .routes(routes!(refresh))
        .routes(routes!(rebuild))
        .routes(routes!(lock))
        .routes(routes!(unlock))
        // SSE endpoint (not well-supported by OpenAPI)
        .route("/stream", get(staleness_stream))
}

#[utoipa::path(
    put,
    path = "/{id}",
    tags = ["topology", "internal"],
    params(("id" = Uuid, Path, description = "Topology ID")),
    responses(
        (status = 200, description = "Topology updated", body = ApiResponse<Topology>),
        (status = 404, description = "Topology not found", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn update_topology(
    state: State<Arc<AppState>>,
    user: RequireMember,
    id: Path<Uuid>,
    topology: Json<Topology>,
) -> ApiResult<Json<ApiResponse<Topology>>> {
    update_handler::<Topology>(state, user, id, topology).await
}

/// Get all topologies
#[utoipa::path(
    get,
    path = "",
    tags = ["topology", "internal"],
    responses(
        (status = 200, description = "List of topologies", body = ApiResponse<Vec<Topology>>),
    ),
    security(("session" = []))
)]
async fn get_all_topologies(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
) -> ApiResult<Json<ApiResponse<Vec<Topology>>>> {
    let service = Topology::get_service(&state);
    let filter = EntityFilter::unfiltered().network_ids(&user.network_ids);
    let entities = service.get_all(filter).await.map_err(|e| {
        tracing::error!(error = %e, "Failed to fetch topologies");
        ApiError::internal_error(&e.to_string())
    })?;
    Ok(Json(ApiResponse::success(entities)))
}

/// Create topology
#[utoipa::path(
    post,
    path = "",
    tags = ["topology", "internal"],
    request_body = Topology,
    responses(
        (status = 200, description = "Topology created", body = ApiResponse<Topology>),
        (status = 400, description = "Validation failed", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn create_topology(
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

    let (hosts, interfaces, subnets, groups, ports, bindings) =
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
        ports: &ports,
        bindings: &bindings,
        old_edges: &[],
        old_nodes: &[],
    });

    topology.set_entities(SetEntitiesParams {
        hosts,
        interfaces,
        services,
        subnets,
        groups,
        ports,
        bindings,
    });

    topology.set_graph(nodes, edges);

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

/// Refresh topology data
#[utoipa::path(
    post,
    path = "/{id}/refresh",
    tags = ["topology", "internal"],
    params(("id" = Uuid, Path, description = "Topology ID")),
    request_body = Topology,
    responses(
        (status = 200, description = "Topology refreshed", body = EmptyApiResponse),
    ),
    security(("session" = []))
)]
async fn refresh(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(mut topology): Json<Topology>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let service = Topology::get_service(&state);

    let (hosts, interfaces, subnets, groups, ports, bindings) =
        service.get_entity_data(topology.base.network_id).await?;

    let services = service
        .get_service_data(topology.base.network_id, &topology.base.options)
        .await?;

    topology.set_entities(SetEntitiesParams {
        hosts,
        services,
        interfaces,
        subnets,
        groups,
        ports,
        bindings,
    });

    service.update(&mut topology, user.into()).await?;

    // Return will be handled through event subscriber which triggers SSE

    Ok(Json(ApiResponse::success(())))
}

/// Rebuild topology layout
#[utoipa::path(
    post,
    path = "/{id}/rebuild",
    tags = ["topology", "internal"],
    params(("id" = Uuid, Path, description = "Topology ID")),
    request_body = Topology,
    responses(
        (status = 200, description = "Topology rebuilt", body = EmptyApiResponse),
    ),
    security(("session" = []))
)]
async fn rebuild(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(mut topology): Json<Topology>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let service = Topology::get_service(&state);

    let (hosts, interfaces, subnets, groups, ports, bindings) =
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
        ports: &ports,
        bindings: &bindings,
        old_nodes: &topology.base.nodes,
        old_edges: &topology.base.edges,
    });

    topology.set_entities(SetEntitiesParams {
        hosts,
        services,
        interfaces,
        subnets,
        groups,
        ports,
        bindings,
    });

    topology.set_graph(nodes, edges);

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

/// Lock a topology
#[utoipa::path(
    post,
    path = "/{id}/lock",
    tags = ["topology"],
    params(("id" = Uuid, Path, description = "Topology ID")),
    request_body = Topology,
    responses(
        (status = 200, description = "Topology locked", body = ApiResponse<Topology>),
    ),
    security(("session" = []))
)]
async fn lock(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<Topology>>> {
    let service = Topology::get_service(&state);

    if let Some(mut topology) = service.get_by_id(&id).await? {
        topology.lock(user.user_id);

        let updated = service.update(&mut topology, user.into()).await?;

        Ok(Json(ApiResponse::success(updated)))
    } else {
        Err(ApiError::not_found(format!(
            "Could not find topology {}",
            id
        )))
    }
}

/// Unlock a topology
#[utoipa::path(
    post,
    path = "/{id}/unlock",
    tags = ["topology"],
    params(("id" = Uuid, Path, description = "Topology ID")),
    request_body = Topology,
    responses(
        (status = 200, description = "Topology unlocked", body = ApiResponse<Topology>),
    ),
    security(("session" = []))
)]
async fn unlock(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<Topology>>> {
    let service = Topology::get_service(&state);

    if let Some(mut topology) = service.get_by_id(&id).await? {
        topology.unlock();

        let updated = service.update(&mut topology, user.into()).await?;

        Ok(Json(ApiResponse::success(updated)))
    } else {
        Err(ApiError::not_found(format!(
            "Could not find topology {}",
            id
        )))
    }
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
