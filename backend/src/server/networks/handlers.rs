use crate::server::auth::middleware::{
    auth::AuthenticatedUser,
    features::{CreateNetworkFeature, RequireFeature},
    permissions::{RequireAdmin, RequireMember},
};
use crate::server::networks::api::CreateNetworkRequest;
use crate::server::shared::handlers::traits::{
    BulkDeleteResponse, CrudHandlers, bulk_delete_handler, delete_handler, get_by_id_handler,
    update_handler,
};
use crate::server::shared::types::api::ApiError;
use crate::server::{
    config::AppState,
    networks::r#impl::Network,
    shared::{
        services::traits::CrudService,
        storage::filter::EntityFilter,
        types::api::{ApiResponse, ApiResult},
    },
};
use axum::extract::{Path, State};
use axum::response::Json;
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(get_all_networks, create_network))
        .routes(routes!(get_network_by_id, update_network, delete_network))
        .routes(routes!(bulk_delete_networks))
}

/// Create a new network
#[utoipa::path(
    post,
    path = "",
    tag = "networks",
    request_body = CreateNetworkRequest,
    responses(
        (status = 200, description = "Network created successfully", body = Network),
        (status = 400, description = "Invalid request"),
        (status = 403, description = "Feature not available or not admin"),
    ),
    security(("session" = []))
)]
async fn create_network(
    State(state): State<Arc<AppState>>,
    RequireAdmin(user): RequireAdmin,
    RequireFeature { .. }: RequireFeature<CreateNetworkFeature>,
    Json(request): Json<CreateNetworkRequest>,
) -> ApiResult<Json<ApiResponse<Network>>> {
    if let Err(err) = request.network.validate() {
        return Err(ApiError::bad_request(&format!(
            "Network validation failed: {}",
            err
        )));
    }

    let service = Network::get_service(&state);
    let created = service
        .create(request.network, user.clone().into())
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    if request.seed_baseline_data {
        service.seed_default_data(created.id, user.into()).await?;
    }

    Ok(Json(ApiResponse::success(created)))
}

/// List all networks
#[utoipa::path(
    get,
    path = "",
    tag = "networks",
    responses(
        (status = 200, description = "List of networks", body = Vec<Network>),
    ),
    security(("session" = []))
)]
async fn get_all_networks(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> ApiResult<Json<ApiResponse<Vec<Network>>>> {
    let service = &state.services.network_service;

    let filter = EntityFilter::unfiltered().entity_ids(&user.network_ids);

    let networks = service.get_all(filter).await?;

    Ok(Json(ApiResponse::success(networks)))
}

/// Get a network by ID
#[utoipa::path(
    get,
    path = "/{id}",
    tag = "networks",
    params(("id" = Uuid, Path, description = "Network ID")),
    responses(
        (status = 200, description = "Network found", body = Network),
        (status = 404, description = "Network not found"),
    ),
    security(("session" = []))
)]
async fn get_network_by_id(
    state: State<Arc<AppState>>,
    user: RequireMember,
    path: Path<Uuid>,
) -> ApiResult<Json<ApiResponse<Network>>> {
    get_by_id_handler::<Network>(state, user, path).await
}

/// Update a network
#[utoipa::path(
    put,
    path = "/{id}",
    tag = "networks",
    params(("id" = Uuid, Path, description = "Network ID")),
    request_body = Network,
    responses(
        (status = 200, description = "Network updated", body = Network),
        (status = 404, description = "Network not found"),
    ),
    security(("session" = []))
)]
async fn update_network(
    state: State<Arc<AppState>>,
    user: RequireMember,
    path: Path<Uuid>,
    json: Json<Network>,
) -> ApiResult<Json<ApiResponse<Network>>> {
    update_handler::<Network>(state, user, path, json).await
}

/// Delete a network
#[utoipa::path(
    delete,
    path = "/{id}",
    tag = "networks",
    params(("id" = Uuid, Path, description = "Network ID")),
    responses(
        (status = 200, description = "Network deleted"),
        (status = 404, description = "Network not found"),
    ),
    security(("session" = []))
)]
async fn delete_network(
    state: State<Arc<AppState>>,
    user: RequireMember,
    path: Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    delete_handler::<Network>(state, user, path).await
}

/// Bulk delete networks
#[utoipa::path(
    post,
    path = "/bulk-delete",
    tag = "networks",
    request_body(content = Vec<Uuid>, description = "Array of network IDs to delete"),
    responses(
        (status = 200, description = "Networks deleted successfully", body = BulkDeleteResponse),
    ),
    security(("session" = []))
)]
async fn bulk_delete_networks(
    state: State<Arc<AppState>>,
    user: RequireMember,
    json: Json<Vec<Uuid>>,
) -> ApiResult<Json<ApiResponse<BulkDeleteResponse>>> {
    bulk_delete_handler::<Network>(state, user, json).await
}
