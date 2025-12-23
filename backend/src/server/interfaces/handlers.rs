use crate::server::auth::middleware::auth::AuthenticatedUser;
use crate::server::auth::middleware::permissions::RequireMember;
use crate::server::interfaces::r#impl::base::Interface;
use crate::server::shared::handlers::traits::{
    BulkDeleteResponse, CrudHandlers, bulk_delete_handler, create_handler, delete_handler,
    get_by_id_handler, update_handler,
};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::storage::traits::StorableEntity;
use crate::server::shared::types::api::ApiError;
use crate::server::{
    config::AppState,
    shared::types::api::{ApiResponse, ApiResult},
};
use axum::extract::{Path, Query, State};
use axum::response::Json;
use serde::Deserialize;
use std::sync::Arc;
use utoipa::IntoParams;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

#[derive(Deserialize, IntoParams)]
pub struct InterfaceQuery {
    /// Filter by host ID
    pub host_id: Option<Uuid>,
    /// Filter by subnet ID
    pub subnet_id: Option<Uuid>,
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(get_all_interfaces, create_interface))
        .routes(routes!(get_interface_by_id, update_interface, delete_interface))
        .routes(routes!(bulk_delete_interfaces))
}

/// List all interfaces
///
/// Returns interfaces filtered by optional host_id or subnet_id query parameters.
#[utoipa::path(
    get,
    path = "",
    tag = "interfaces",
    params(InterfaceQuery),
    responses(
        (status = 200, description = "List of interfaces", body = Vec<Interface>),
    ),
    security(("session" = []))
)]
async fn get_all_interfaces(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
    query: Query<InterfaceQuery>,
) -> ApiResult<Json<ApiResponse<Vec<Interface>>>> {
    let service = Interface::get_service(&state);

    // Build filter based on query params, always restricted to user's networks
    let mut filter = EntityFilter::unfiltered().network_ids(&user.network_ids);

    if let Some(host_id) = query.host_id {
        filter = filter.host_id(&host_id);
    }

    if let Some(subnet_id) = query.subnet_id {
        filter = filter.subnet_id(&subnet_id);
    }

    let entities = service.get_all(filter).await.map_err(|e| {
        tracing::error!(
            entity_type = Interface::table_name(),
            user_id = %user.user_id,
            error = %e,
            "Failed to fetch interfaces"
        );
        ApiError::internal_error(&e.to_string())
    })?;

    Ok(Json(ApiResponse::success(entities)))
}

/// Create a new interface
#[utoipa::path(
    post,
    path = "",
    tag = "interfaces",
    request_body = Interface,
    responses(
        (status = 200, description = "Interface created successfully", body = Interface),
        (status = 400, description = "Invalid request"),
    ),
    security(("session" = []))
)]
async fn create_interface(
    state: State<Arc<AppState>>,
    user: RequireMember,
    json: Json<Interface>,
) -> ApiResult<Json<ApiResponse<Interface>>> {
    create_handler::<Interface>(state, user, json).await
}

/// Get an interface by ID
#[utoipa::path(
    get,
    path = "/{id}",
    tag = "interfaces",
    params(("id" = Uuid, Path, description = "Interface ID")),
    responses(
        (status = 200, description = "Interface found", body = Interface),
        (status = 404, description = "Interface not found"),
    ),
    security(("session" = []))
)]
async fn get_interface_by_id(
    state: State<Arc<AppState>>,
    user: RequireMember,
    path: Path<Uuid>,
) -> ApiResult<Json<ApiResponse<Interface>>> {
    get_by_id_handler::<Interface>(state, user, path).await
}

/// Update an interface
#[utoipa::path(
    put,
    path = "/{id}",
    tag = "interfaces",
    params(("id" = Uuid, Path, description = "Interface ID")),
    request_body = Interface,
    responses(
        (status = 200, description = "Interface updated", body = Interface),
        (status = 404, description = "Interface not found"),
    ),
    security(("session" = []))
)]
async fn update_interface(
    state: State<Arc<AppState>>,
    user: RequireMember,
    path: Path<Uuid>,
    json: Json<Interface>,
) -> ApiResult<Json<ApiResponse<Interface>>> {
    update_handler::<Interface>(state, user, path, json).await
}

/// Delete an interface
#[utoipa::path(
    delete,
    path = "/{id}",
    tag = "interfaces",
    params(("id" = Uuid, Path, description = "Interface ID")),
    responses(
        (status = 200, description = "Interface deleted"),
        (status = 404, description = "Interface not found"),
    ),
    security(("session" = []))
)]
async fn delete_interface(
    state: State<Arc<AppState>>,
    user: RequireMember,
    path: Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    delete_handler::<Interface>(state, user, path).await
}

/// Bulk delete interfaces
#[utoipa::path(
    post,
    path = "/bulk-delete",
    tag = "interfaces",
    request_body(content = Vec<Uuid>, description = "Array of interface IDs to delete"),
    responses(
        (status = 200, description = "Interfaces deleted successfully", body = BulkDeleteResponse),
    ),
    security(("session" = []))
)]
async fn bulk_delete_interfaces(
    state: State<Arc<AppState>>,
    user: RequireMember,
    json: Json<Vec<Uuid>>,
) -> ApiResult<Json<ApiResponse<BulkDeleteResponse>>> {
    bulk_delete_handler::<Interface>(state, user, json).await
}
