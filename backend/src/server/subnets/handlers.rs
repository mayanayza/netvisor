use crate::server::auth::middleware::permissions::{MemberOrDaemon, RequireMember};
use crate::server::shared::handlers::traits::{
    BulkDeleteResponse, CrudHandlers, bulk_delete_handler, delete_handler, get_by_id_handler,
    update_handler,
};
use crate::server::shared::types::api::ApiError;
use crate::server::{
    config::AppState,
    shared::{
        services::traits::CrudService,
        storage::filter::EntityFilter,
        types::api::{ApiResponse, ApiResult},
    },
    subnets::r#impl::base::Subnet,
};
use axum::extract::{Path, State};
use axum::response::Json;
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(get_all_subnets, create_subnet))
        .routes(routes!(get_subnet_by_id, update_subnet, delete_subnet))
        .routes(routes!(bulk_delete_subnets))
}

/// Create a new subnet
#[utoipa::path(
    post,
    path = "",
    tag = "subnets",
    request_body = Subnet,
    responses(
        (status = 200, description = "Subnet created successfully", body = Subnet),
        (status = 400, description = "Invalid request"),
    ),
    security(("session" = []))
)]
async fn create_subnet(
    State(state): State<Arc<AppState>>,
    MemberOrDaemon { entity, .. }: MemberOrDaemon,
    Json(request): Json<Subnet>,
) -> ApiResult<Json<ApiResponse<Subnet>>> {
    if let Err(err) = request.validate() {
        tracing::warn!(
            subnet_name = %request.base.name,
            subnet_cidr = %request.base.cidr,
            entity_id = %entity.entity_id(),
            error = %err,
            "Subnet validation failed"
        );
        return Err(ApiError::bad_request(&format!(
            "Subnet validation failed: {}",
            err
        )));
    }

    tracing::debug!(
        subnet_name = %request.base.name,
        subnet_cidr = %request.base.cidr,
        network_id = %request.base.network_id,
        entity_id = %entity.entity_id(),
        "Subnet create request received"
    );

    let service = Subnet::get_service(&state);
    let created = service.create(request, entity.clone()).await.map_err(|e| {
        tracing::error!(
            error = %e,
            entity_id = %entity.entity_id(),
            "Failed to create subnet"
        );
        ApiError::internal_error(&e.to_string())
    })?;

    tracing::info!(
        subnet_id = %created.id,
        subnet_name = %created.base.name,
        entity_id = %entity.entity_id(),
        "Subnet created via API"
    );

    Ok(Json(ApiResponse::success(created)))
}

/// List all subnets
#[utoipa::path(
    get,
    path = "",
    tag = "subnets",
    responses(
        (status = 200, description = "List of subnets", body = Vec<Subnet>),
    ),
    security(("session" = []))
)]
async fn get_all_subnets(
    State(state): State<Arc<AppState>>,
    MemberOrDaemon { network_ids, .. }: MemberOrDaemon,
) -> ApiResult<Json<ApiResponse<Vec<Subnet>>>> {
    let filter = EntityFilter::unfiltered().network_ids(&network_ids);
    let subnets = state.services.subnet_service.get_all(filter).await?;
    Ok(Json(ApiResponse::success(subnets)))
}

/// Get a subnet by ID
#[utoipa::path(
    get,
    path = "/{id}",
    tag = "subnets",
    params(("id" = Uuid, Path, description = "Subnet ID")),
    responses(
        (status = 200, description = "Subnet found", body = Subnet),
        (status = 404, description = "Subnet not found"),
    ),
    security(("session" = []))
)]
async fn get_subnet_by_id(
    state: State<Arc<AppState>>,
    user: RequireMember,
    path: Path<Uuid>,
) -> ApiResult<Json<ApiResponse<Subnet>>> {
    get_by_id_handler::<Subnet>(state, user, path).await
}

/// Update a subnet
#[utoipa::path(
    put,
    path = "/{id}",
    tag = "subnets",
    params(("id" = Uuid, Path, description = "Subnet ID")),
    request_body = Subnet,
    responses(
        (status = 200, description = "Subnet updated", body = Subnet),
        (status = 404, description = "Subnet not found"),
    ),
    security(("session" = []))
)]
async fn update_subnet(
    state: State<Arc<AppState>>,
    user: RequireMember,
    path: Path<Uuid>,
    json: Json<Subnet>,
) -> ApiResult<Json<ApiResponse<Subnet>>> {
    update_handler::<Subnet>(state, user, path, json).await
}

/// Delete a subnet
#[utoipa::path(
    delete,
    path = "/{id}",
    tag = "subnets",
    params(("id" = Uuid, Path, description = "Subnet ID")),
    responses(
        (status = 200, description = "Subnet deleted"),
        (status = 404, description = "Subnet not found"),
    ),
    security(("session" = []))
)]
async fn delete_subnet(
    state: State<Arc<AppState>>,
    user: RequireMember,
    path: Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    delete_handler::<Subnet>(state, user, path).await
}

/// Bulk delete subnets
#[utoipa::path(
    post,
    path = "/bulk-delete",
    tag = "subnets",
    request_body(content = Vec<Uuid>, description = "Array of subnet IDs to delete"),
    responses(
        (status = 200, description = "Subnets deleted successfully", body = BulkDeleteResponse),
    ),
    security(("session" = []))
)]
async fn bulk_delete_subnets(
    state: State<Arc<AppState>>,
    user: RequireMember,
    json: Json<Vec<Uuid>>,
) -> ApiResult<Json<ApiResponse<BulkDeleteResponse>>> {
    bulk_delete_handler::<Subnet>(state, user, json).await
}
