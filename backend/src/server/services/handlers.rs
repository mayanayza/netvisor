use crate::server::auth::middleware::permissions::RequireMember;
use crate::server::shared::handlers::traits::{
    bulk_delete_handler, create_handler, delete_handler, get_all_handler, get_by_id_handler,
    update_handler,
};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::types::api::{ApiError, ApiResponse, ApiResult};
use crate::server::{config::AppState, services::r#impl::base::Service};
use axum::extract::{Path, State};
use axum::routing::{delete, get, post, put};
use axum::{Json, Router};
use std::sync::Arc;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", post(create_service))
        .route("/", get(get_all_handler::<Service>))
        .route("/{id}", put(update_service))
        .route("/{id}", delete(delete_handler::<Service>))
        .route("/{id}", get(get_by_id_handler::<Service>))
        .route("/bulk-delete", post(bulk_delete_handler::<Service>))
}

/// Create a new service with host network validation
pub async fn create_service(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    Json(service): Json<Service>,
) -> ApiResult<Json<ApiResponse<Service>>> {
    // Custom validation: Check host network matches service network
    if let Some(host) = state
        .services
        .host_service
        .get_by_id(&service.base.host_id)
        .await?
        && host.base.network_id != service.base.network_id
    {
        return Err(ApiError::bad_request(&format!(
            "Host is on network {}, Service \"{}\" can't be on a different network ({}).",
            host.base.network_id, service.base.name, service.base.network_id
        )));
    }

    // Delegate to generic handler (handles validation, auth checks, creation)
    create_handler::<Service>(State(state), user, Json(service)).await
}

/// Update a service with host network validation
pub async fn update_service(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    Path(id): Path<Uuid>,
    Json(service): Json<Service>,
) -> ApiResult<Json<ApiResponse<Service>>> {
    // Custom validation: Check host network matches service network
    if let Some(host) = state
        .services
        .host_service
        .get_by_id(&service.base.host_id)
        .await?
        && host.base.network_id != service.base.network_id
    {
        return Err(ApiError::bad_request(&format!(
            "Host is on network {}, Service \"{}\" can't be on a different network ({}).",
            host.base.network_id, service.base.name, service.base.network_id
        )));
    }

    // Delegate to generic handler (handles validation, auth checks, update)
    update_handler::<Service>(State(state), user, Path(id), Json(service)).await
}
