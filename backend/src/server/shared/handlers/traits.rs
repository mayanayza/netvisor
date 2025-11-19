use crate::server::{
    auth::middleware::{AuthenticatedUser, RequireMember},
    config::AppState,
    shared::{
        services::traits::CrudService,
        storage::{filter::EntityFilter, traits::StorableEntity},
        types::api::{ApiError, ApiResponse, ApiResult},
    },
};
use async_trait::async_trait;
use axum::{
    Router,
    extract::{Path, State},
    response::Json,
    routing::{delete, get, post, put},
};
use serde::{Deserialize, Serialize};
use std::{fmt::Display, sync::Arc};
use uuid::Uuid;

/// Trait for creating standard CRUD handlers for an entity
#[async_trait]
pub trait CrudHandlers: StorableEntity + Serialize + for<'de> Deserialize<'de>
where
    Self: Display,
{
    /// Get the service from AppState (must implement CrudService)
    type Service: CrudService<Self> + Send + Sync;
    fn get_service(state: &AppState) -> &Self::Service;

    /// Get entity name for error messages (e.g., "Group", "Network")
    fn entity_name() -> &'static str {
        Self::table_name()
    }

    /// Optional: Validate entity before create/update
    fn validate(&self) -> Result<(), String> {
        Ok(())
    }
}

/// Create a standard CRUD router
pub fn create_crud_router<T>() -> Router<Arc<AppState>>
where
    T: CrudHandlers + 'static,
{
    Router::new()
        .route("/", post(create_handler::<T>))
        .route("/", get(get_all_handler::<T>))
        .route("/{id}", put(update_handler::<T>))
        .route("/{id}", delete(delete_handler::<T>))
        .route("/{id}", get(get_by_id_handler::<T>))
}

pub async fn create_handler<T>(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(request): Json<T>,
) -> ApiResult<Json<ApiResponse<T>>>
where
    T: CrudHandlers + 'static,
{
    if let Err(err) = request.validate() {
        tracing::warn!(
            entity_type = T::table_name(),
            user_id = %user.user_id,
            error = %err,
            "Entity validation failed"
        );
        return Err(ApiError::bad_request(&format!(
            "{} validation failed: {}",
            T::entity_name(),
            err
        )));
    }

    tracing::debug!(
        entity_type = T::table_name(),
        user_id = %user.user_id,
        "Create request received"
    );

    let service = T::get_service(&state);
    let created = service
        .create(request, user.clone().into())
        .await
        .map_err(|e| {
            tracing::error!(
                entity_type = T::table_name(),
                user_id = %user.user_id,
                error = %e,
                "Failed to create entity"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    tracing::info!(
        entity_type = T::table_name(),
        entity_id = %created.id(),
        user_id = %user.user_id,
        "Entity created via API"
    );

    Ok(Json(ApiResponse::success(created)))
}

pub async fn get_all_handler<T>(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> ApiResult<Json<ApiResponse<Vec<T>>>>
where
    T: CrudHandlers + 'static,
{
    tracing::debug!(
        entity_type = T::table_name(),
        user_id = %user.user_id,
        network_count = %user.network_ids.len(),
        "Get all request received"
    );

    let network_filter = EntityFilter::unfiltered().network_ids(&user.network_ids);

    let service = T::get_service(&state);
    let entities = service.get_all(network_filter).await.map_err(|e| {
        tracing::error!(
            entity_type = T::table_name(),
            user_id = %user.user_id,
            error = %e,
            "Failed to fetch entities"
        );
        ApiError::internal_error(&e.to_string())
    })?;

    tracing::debug!(
        entity_type = T::table_name(),
        user_id = %user.user_id,
        count = %entities.len(),
        "Entities fetched successfully"
    );

    Ok(Json(ApiResponse::success(entities)))
}

pub async fn get_by_id_handler<T>(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<T>>>
where
    T: CrudHandlers + 'static,
{
    tracing::debug!(
        entity_type = T::table_name(),
        entity_id = %id,
        user_id = %user.user_id,
        "Get by ID request received"
    );

    let service = T::get_service(&state);
    let entity = service
        .get_by_id(&id)
        .await
        .map_err(|e| {
            tracing::error!(
                entity_type = T::table_name(),
                entity_id = %id,
                user_id = %user.user_id,
                error = %e,
                "Failed to fetch entity by ID"
            );
            ApiError::internal_error(&e.to_string())
        })?
        .ok_or_else(|| {
            tracing::warn!(
                entity_type = T::table_name(),
                entity_id = %id,
                user_id = %user.user_id,
                "Entity not found"
            );
            ApiError::not_found(format!("{} '{}' not found", T::entity_name(), id))
        })?;

    tracing::debug!(
        entity_type = T::table_name(),
        entity_id = %id,
        user_id = %user.user_id,
        "Entity fetched successfully"
    );

    Ok(Json(ApiResponse::success(entity)))
}

pub async fn update_handler<T>(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
    Json(mut request): Json<T>,
) -> ApiResult<Json<ApiResponse<T>>>
where
    T: CrudHandlers + 'static,
{
    tracing::debug!(
        entity_type = T::table_name(),
        entity_id = %id,
        user_id = %user.user_id,
        "Update request received"
    );

    let service = T::get_service(&state);

    // Verify entity exists
    service
        .get_by_id(&id)
        .await
        .map_err(|e| {
            tracing::error!(
                entity_type = T::table_name(),
                entity_id = %id,
                user_id = %user.user_id,
                error = %e,
                "Failed to fetch entity for update"
            );
            ApiError::internal_error(&e.to_string())
        })?
        .ok_or_else(|| {
            tracing::warn!(
                entity_type = T::table_name(),
                entity_id = %id,
                user_id = %user.user_id,
                "Entity not found for update"
            );
            ApiError::not_found(format!("{} '{}' not found", T::entity_name(), id))
        })?;

    let updated = service
        .update(&mut request, user.clone().into())
        .await
        .map_err(|e| {
            tracing::error!(
                entity_type = T::table_name(),
                entity_id = %id,
                user_id = %user.user_id,
                error = %e,
                "Failed to update entity"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    tracing::info!(
        entity_type = T::table_name(),
        entity_id = %id,
        user_id = %user.user_id,
        "Entity updated via API"
    );

    Ok(Json(ApiResponse::success(updated)))
}

pub async fn delete_handler<T>(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>>
where
    T: CrudHandlers + 'static,
{
    let service = T::get_service(&state);

    // Verify entity exists and log the deletion attempt
    let entity = service
        .get_by_id(&id)
        .await
        .map_err(|e| {
            tracing::error!(
                entity_type = T::table_name(),
                entity_id = %id,
                error = %e,
                "Failed to fetch entity for deletion"
            );
            ApiError::internal_error(&e.to_string())
        })?
        .ok_or_else(|| {
            tracing::warn!(
                entity_type = T::table_name(),
                entity_id = %id,
                "Entity not found for deletion"
            );
            ApiError::not_found(format!("{} '{}' not found", T::entity_name(), id))
        })?;

    tracing::info!(
        entity_type = T::table_name(),
        entity_id = %id,
        entity_name = %entity,
        "Delete request received"
    );

    service.delete(&id, user.into()).await.map_err(|e| {
        tracing::error!(
            entity_type = T::table_name(),
            entity_id = %id,
            error = %e,
            "Failed to delete entity"
        );
        ApiError::internal_error(&e.to_string())
    })?;

    Ok(Json(ApiResponse::success(())))
}
