use crate::server::{
    auth::middleware::{auth::AuthenticatedUser, permissions::RequireMember},
    config::AppState,
    shared::{
        entities::{ChangeTriggersTopologyStaleness, Entity},
        services::traits::{CrudService, EventBusService},
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
    Self: Display + ChangeTriggersTopologyStaleness<Self>,
    Entity: From<Self>,
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
    T: CrudHandlers + 'static + ChangeTriggersTopologyStaleness<T>,
    Entity: From<T>,
{
    Router::new()
        .route("/", post(create_handler::<T>))
        .route("/", get(get_all_handler::<T>))
        .route("/{id}", put(update_handler::<T>))
        .route("/{id}", delete(delete_handler::<T>))
        .route("/{id}", get(get_by_id_handler::<T>))
        .route("/bulk-delete", post(bulk_delete_handler::<T>))
}

pub async fn create_handler<T>(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(entity): Json<T>,
) -> ApiResult<Json<ApiResponse<T>>>
where
    T: CrudHandlers + 'static + ChangeTriggersTopologyStaleness<T>,
    Entity: From<T>,
{
    if let Err(err) = entity.validate() {
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

    let service = T::get_service(&state);

    if let Some(network_id) = service.get_network_id(&entity)
        && user.network_ids.contains(&network_id)
    {
        return Err(ApiError::unauthorized(
            "You aren't allowed to create entities on this network".to_string(),
        ));
    }

    if let Some(organization_id) = service.get_organization_id(&entity)
        && user.organization_id != organization_id
    {
        return Err(ApiError::unauthorized(
            "You aren't allowed to create entities for this organization".to_string(),
        ));
    }

    let created = service
        .create(entity, user.clone().into())
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

    Ok(Json(ApiResponse::success(created)))
}

pub async fn get_all_handler<T>(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> ApiResult<Json<ApiResponse<Vec<T>>>>
where
    T: CrudHandlers + 'static + ChangeTriggersTopologyStaleness<T>,
    Entity: From<T>,
{
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

    Ok(Json(ApiResponse::success(entities)))
}

pub async fn get_by_id_handler<T>(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<T>>>
where
    T: CrudHandlers + 'static + ChangeTriggersTopologyStaleness<T>,
    Entity: From<T>,
{
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

    if let Some(network_id) = service.get_network_id(&entity)
        && user.network_ids.contains(&network_id)
    {
        return Err(ApiError::unauthorized(
            "You aren't allowed to access entities on this network".to_string(),
        ));
    }

    if let Some(organization_id) = service.get_organization_id(&entity)
        && user.organization_id != organization_id
    {
        return Err(ApiError::unauthorized(
            "You aren't allowed to access entities from this organization".to_string(),
        ));
    }

    Ok(Json(ApiResponse::success(entity)))
}

pub async fn update_handler<T>(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
    Json(mut entity): Json<T>,
) -> ApiResult<Json<ApiResponse<T>>>
where
    T: CrudHandlers + 'static + ChangeTriggersTopologyStaleness<T>,
    Entity: From<T>,
{
    let service = T::get_service(&state);

    if let Some(network_id) = service.get_network_id(&entity)
        && user.network_ids.contains(&network_id)
    {
        return Err(ApiError::unauthorized(
            "You aren't allowed to update entities on this network".to_string(),
        ));
    }

    if let Some(organization_id) = service.get_organization_id(&entity)
        && user.organization_id != organization_id
    {
        return Err(ApiError::unauthorized(
            "You aren't allowed to update entities for this organization".to_string(),
        ));
    }

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
        .update(&mut entity, user.clone().into())
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

    Ok(Json(ApiResponse::success(updated)))
}

pub async fn delete_handler<T>(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>>
where
    T: CrudHandlers + 'static + ChangeTriggersTopologyStaleness<T>,
    Entity: From<T>,
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

    if let Some(network_id) = service.get_network_id(&entity)
        && user.network_ids.contains(&network_id)
    {
        return Err(ApiError::unauthorized(
            "You aren't allowed to delete entities on this network".to_string(),
        ));
    }

    if let Some(organization_id) = service.get_organization_id(&entity)
        && user.organization_id != organization_id
    {
        return Err(ApiError::unauthorized(
            "You aren't allowed to delete entities for this organization".to_string(),
        ));
    }

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

pub async fn bulk_delete_handler<T>(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(ids): Json<Vec<Uuid>>,
) -> ApiResult<Json<ApiResponse<BulkDeleteResponse>>>
where
    T: CrudHandlers + 'static,
    Entity: From<T>,
{
    if ids.is_empty() {
        return Err(ApiError::bad_request("No IDs provided for bulk delete"));
    }

    let service = T::get_service(&state);

    let entity_filter = EntityFilter::unfiltered().entity_ids(&ids);
    let entities = service.get_all(entity_filter).await?;

    for entity in entities {
        if let Some(network_id) = service.get_network_id(&entity)
            && user.network_ids.contains(&network_id)
        {
            return Err(ApiError::unauthorized(
                "You aren't allowed to delete entities on this network".to_string(),
            ));
        }

        if let Some(organization_id) = service.get_organization_id(&entity)
            && user.organization_id != organization_id
        {
            return Err(ApiError::unauthorized(
                "You aren't allowed to delete entities for this organization".to_string(),
            ));
        }
    }

    let deleted_count = service
        .delete_many(&ids, user.clone().into())
        .await
        .map_err(|e| {
            tracing::error!(
                entity_type = T::table_name(),
                user_id = %user.user_id,
                error = %e,
                "Failed to bulk delete entities"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    Ok(Json(ApiResponse::success(BulkDeleteResponse {
        deleted_count,
        requested_count: ids.len(),
    })))
}

#[derive(Serialize)]
pub struct BulkDeleteResponse {
    pub deleted_count: usize,
    pub requested_count: usize,
}
