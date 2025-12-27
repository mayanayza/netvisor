use axum::Json;
use axum::extract::{Path, State};
use uuid::Uuid;

use crate::server::auth::middleware::permissions::RequireMember;
use crate::server::config::AppState;
use crate::server::groups::r#impl::base::Group;
use crate::server::shared::handlers::traits::{create_handler, update_handler};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::types::api::{ApiError, ApiErrorResponse, ApiResponse, ApiResult};
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};

// Generated handlers for operations that use generic CRUD logic
mod generated {
    use super::*;
    crate::crud_get_all_handler!(Group, "groups", "group");
    crate::crud_get_by_id_handler!(Group, "groups", "group");
    crate::crud_delete_handler!(Group, "groups", "group");
    crate::crud_bulk_delete_handler!(Group, "groups");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(generated::get_all, create_group))
        .routes(routes!(
            generated::get_by_id,
            update_group,
            generated::delete
        ))
        .routes(routes!(generated::bulk_delete))
}

/// Create a new group
#[utoipa::path(
    post,
    path = "",
    tag = "groups",
    request_body = Group,
    responses(
        (status = 200, description = "Group created successfully", body = ApiResponse<Group>),
        (status = 400, description = "Invalid request", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn create_group(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    Json(group): Json<Group>,
) -> ApiResult<Json<ApiResponse<Group>>> {
    // Custom validation: Check for service bindings on different networks
    for binding_id in &group.base.binding_ids {
        let binding_id_filter = EntityFilter::unfiltered().entity_id(binding_id);

        if let Some(binding) = state
            .services
            .binding_service
            .get_one(binding_id_filter)
            .await?
            && binding.base.network_id != group.base.network_id
        {
            return Err(ApiError::bad_request(&format!(
                "Group is on network {}, can't add binding which is on network {}",
                group.base.network_id, binding.base.network_id
            )));
        }
    }

    // Delegate to generic handler (handles validation, auth checks, creation)
    create_handler::<Group>(State(state), user, Json(group)).await
}

/// Update a group
#[utoipa::path(
    put,
    path = "/{id}",
    tag = "groups",
    params(("id" = Uuid, Path, description = "Group ID")),
    request_body = Group,
    responses(
        (status = 200, description = "Group updated successfully", body = ApiResponse<Group>),
        (status = 400, description = "Invalid request", body = ApiErrorResponse),
        (status = 404, description = "Group not found", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
async fn update_group(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    path: Path<Uuid>,
    Json(group): Json<Group>,
) -> ApiResult<Json<ApiResponse<Group>>> {
    // Custom validation: Check for service bindings on different networks
    for binding_id in &group.base.binding_ids {
        let binding_id_filter = EntityFilter::unfiltered().entity_id(binding_id);

        if let Some(binding) = state
            .services
            .binding_service
            .get_one(binding_id_filter)
            .await?
            && binding.base.network_id != group.base.network_id
        {
            return Err(ApiError::bad_request(&format!(
                "Group is on network {}, can't add binding which is on network {}",
                group.base.network_id, binding.base.network_id
            )));
        }
    }

    // Delegate to generic handler (handles validation, auth checks, update)
    update_handler::<Group>(State(state), user, path, Json(group)).await
}
