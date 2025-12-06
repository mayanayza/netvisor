use axum::extract::State;
use axum::routing::{delete, get, post, put};
use axum::{Json, Router};

use crate::server::auth::middleware::permissions::RequireMember;
use crate::server::config::AppState;
use crate::server::groups::r#impl::base::Group;
use crate::server::groups::r#impl::types::GroupType;
use crate::server::shared::handlers::traits::{
    CrudHandlers, bulk_delete_handler, delete_handler, get_all_handler, get_by_id_handler,
    update_handler,
};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::storage::traits::StorableEntity;
use crate::server::shared::types::api::{ApiError, ApiResponse, ApiResult};
use std::sync::Arc;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", post(create_handler))
        .route("/", get(get_all_handler::<Group>))
        .route("/{id}", put(update_handler::<Group>))
        .route("/{id}", delete(delete_handler::<Group>))
        .route("/{id}", get(get_by_id_handler::<Group>))
        .route("/bulk-delete", post(bulk_delete_handler::<Group>))
}

pub async fn create_handler(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(group): Json<Group>,
) -> ApiResult<Json<ApiResponse<Group>>> {
    if let Err(err) = group.validate() {
        tracing::warn!(
            entity_type = Group::table_name(),
            user_id = %user.user_id,
            error = %err,
            "Entity validation failed"
        );
        return Err(ApiError::bad_request(&format!(
            "{} validation failed: {}",
            Group::entity_name(),
            err
        )));
    }

    // Check for service bindings networks other than the group's network
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

    let service = Group::get_service(&state);
    let created = service
        .create(group, user.clone().into())
        .await
        .map_err(|e| {
            tracing::error!(
                entity_type = Group::table_name(),
                user_id = %user.user_id,
                error = %e,
                "Failed to create entity"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    Ok(Json(ApiResponse::success(created)))
}
