use axum::extract::State;
use axum::routing::{delete, get, post, put};
use axum::{Json, Router};

use crate::server::auth::middleware::permissions::RequireMember;
use crate::server::config::AppState;
use crate::server::groups::r#impl::base::Group;
use crate::server::groups::r#impl::types::GroupType;
use crate::server::shared::handlers::traits::{
    bulk_delete_handler, create_handler, delete_handler, get_all_handler, get_by_id_handler,
    update_handler,
};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::types::api::{ApiError, ApiResponse, ApiResult};
use std::sync::Arc;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", post(create_group))
        .route("/", get(get_all_handler::<Group>))
        .route("/{id}", put(update_handler::<Group>))
        .route("/{id}", delete(delete_handler::<Group>))
        .route("/{id}", get(get_by_id_handler::<Group>))
        .route("/bulk-delete", post(bulk_delete_handler::<Group>))
}

/// Create a new group with service binding network validation
pub async fn create_group(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    Json(group): Json<Group>,
) -> ApiResult<Json<ApiResponse<Group>>> {
    // Custom validation: Check for service bindings on different networks
    match &group.base.group_type {
        GroupType::HubAndSpoke { service_bindings }
        | GroupType::RequestPath { service_bindings } => {
            for binding_id in service_bindings {
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
        }
    }

    // Delegate to generic handler (handles validation, auth checks, creation)
    create_handler::<Group>(State(state), user, Json(group)).await
}
