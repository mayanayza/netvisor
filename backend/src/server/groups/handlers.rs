use axum::extract::State;
use axum::Json;

use crate::server::auth::middleware::permissions::RequireMember;
use crate::server::config::AppState;
use crate::server::groups::r#impl::base::Group;
use crate::server::shared::handlers::traits::create_handler;
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::types::api::{ApiError, ApiResponse, ApiResult};
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};

// Generated handlers for operations that use generic CRUD logic
mod generated {
    use super::*;
    crate::crud_get_all_handler!(Group, "groups", "group");
    crate::crud_get_by_id_handler!(Group, "groups", "group");
    crate::crud_update_handler!(Group, "groups", "group");
    crate::crud_delete_handler!(Group, "groups", "group");
    crate::crud_bulk_delete_handler!(Group, "groups");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(generated::get_all, create_group))
        .routes(routes!(generated::get_by_id, generated::update, generated::delete))
        .routes(routes!(generated::bulk_delete))
}

/// Create a new group
#[utoipa::path(
    post,
    path = "",
    tag = "groups",
    request_body = Group,
    responses(
        (status = 200, description = "Group created successfully", body = Group),
        (status = 400, description = "Invalid request"),
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
        let binding_id_filter = EntityFilter::unfiltered().service_binding_id(binding_id);

        if let Some(service) = state
            .services
            .service_service
            .get_one(binding_id_filter)
            .await?
            && service.base.network_id != group.base.network_id
        {
            return Err(ApiError::bad_request(&format!(
                "Group is on network {}, can't add Service \"{}\" which is on network {}",
                group.base.network_id, service.base.name, service.base.network_id
            )));
        }
    }

    // Delegate to generic handler (handles validation, auth checks, creation)
    create_handler::<Group>(State(state), user, Json(group)).await
}
