use crate::server::auth::middleware::permissions::RequireMember;
use crate::server::shared::handlers::traits::{
    CrudHandlers, bulk_delete_handler, delete_handler, get_all_handler, get_by_id_handler,
};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::traits::StorableEntity;
use crate::server::shared::types::api::{ApiError, ApiResponse, ApiResult};
use crate::server::{config::AppState, services::r#impl::base::Service};
use axum::extract::{Path, State};
use axum::routing::{delete, get, post, put};
use axum::{Json, Router};
use std::sync::Arc;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", post(create_handler))
        .route("/", get(get_all_handler::<Service>))
        .route("/{id}", put(update_handler))
        .route("/{id}", delete(delete_handler::<Service>))
        .route("/{id}", get(get_by_id_handler::<Service>))
        .route("/bulk-delete", post(bulk_delete_handler::<Service>))
}

pub async fn create_handler(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(service): Json<Service>,
) -> ApiResult<Json<ApiResponse<Service>>> {
    if let Err(err) = service.validate() {
        tracing::warn!(
            entity_type = Service::table_name(),
            user_id = %user.user_id,
            error = %err,
            "Entity validation failed"
        );
        return Err(ApiError::bad_request(&format!(
            "{} validation failed: {}",
            Service::entity_name(),
            err
        )));
    }

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

    let created = state
        .services
        .service_service
        .create(service, user.clone().into())
        .await
        .map_err(|e| {
            tracing::error!(
                entity_type = Service::table_name(),
                user_id = %user.user_id,
                error = %e,
                "Failed to create entity"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    Ok(Json(ApiResponse::success(created)))
}

pub async fn update_handler(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
    Json(mut service): Json<Service>,
) -> ApiResult<Json<ApiResponse<Service>>> {
    // Verify entity exists
    state
        .services
        .service_service
        .get_by_id(&id)
        .await
        .map_err(|e| {
            tracing::error!(
                entity_type = Service::table_name(),
                entity_id = %id,
                user_id = %user.user_id,
                error = %e,
                "Failed to fetch entity for update"
            );
            ApiError::internal_error(&e.to_string())
        })?
        .ok_or_else(|| {
            tracing::warn!(
                entity_type = Service::table_name(),
                entity_id = %id,
                user_id = %user.user_id,
                "Entity not found for update"
            );
            ApiError::not_found(format!("{} '{}' not found", Service::entity_name(), id))
        })?;

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

    let updated = state
        .services
        .service_service
        .update(&mut service, user.clone().into())
        .await
        .map_err(|e| {
            tracing::error!(
                entity_type = Service::table_name(),
                entity_id = %id,
                user_id = %user.user_id,
                error = %e,
                "Failed to update entity"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    Ok(Json(ApiResponse::success(updated)))
}
