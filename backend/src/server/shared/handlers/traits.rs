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
        && !user.network_ids.contains(&network_id)
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
        && !user.network_ids.contains(&network_id)
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

    // Enforce path ID matches body ID
    if entity.id() != id {
        tracing::warn!(
            entity_type = T::table_name(),
            path_id = %id,
            body_id = %entity.id(),
            user_id = %user.user_id,
            "Path/body ID mismatch"
        );
        return Err(ApiError::bad_request(
            "Entity ID in request body must match URL path ID",
        ));
    }

    // Fetch existing entity and verify ownership BEFORE any updates
    let existing = service
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

    // Verify user has access to the EXISTING entity's network
    if let Some(network_id) = service.get_network_id(&existing)
        && !user.network_ids.contains(&network_id)
    {
        tracing::warn!(
            entity_type = T::table_name(),
            entity_id = %id,
            user_id = %user.user_id,
            entity_network_id = %network_id,
            "Unauthorized update attempt - user lacks access to entity's current network"
        );
        return Err(ApiError::unauthorized(
            "You don't have access to this entity".to_string(),
        ));
    }

    // Verify user has access to the EXISTING entity's organization
    if let Some(organization_id) = service.get_organization_id(&existing)
        && user.organization_id != organization_id
    {
        tracing::warn!(
            entity_type = T::table_name(),
            entity_id = %id,
            user_id = %user.user_id,
            entity_org_id = %organization_id,
            user_org_id = %user.organization_id,
            "Unauthorized update attempt - entity belongs to different organization"
        );
        return Err(ApiError::unauthorized(
            "You don't have access to this entity".to_string(),
        ));
    }

    // Now check the NEW values being set (prevent reassigning to unauthorized network/org)
    if let Some(network_id) = service.get_network_id(&entity)
        && !user.network_ids.contains(&network_id)
    {
        return Err(ApiError::unauthorized(
            "You can't move this entity to a network you don't have access to".to_string(),
        ));
    }

    if let Some(organization_id) = service.get_organization_id(&entity)
        && user.organization_id != organization_id
    {
        return Err(ApiError::unauthorized(
            "You can't move this entity to a different organization".to_string(),
        ));
    }

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

    // Fetch entity first to verify ownership
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

    // Verify ownership BEFORE delete - check existing entity's network
    if let Some(network_id) = service.get_network_id(&entity)
        && !user.network_ids.contains(&network_id)
    {
        tracing::warn!(
            entity_type = T::table_name(),
            entity_id = %id,
            user_id = %user.user_id,
            "Unauthorized delete attempt - user lacks network access"
        );
        return Err(ApiError::unauthorized(
            "You don't have access to delete this entity".to_string(),
        ));
    }

    // Verify ownership - check existing entity's organization
    if let Some(organization_id) = service.get_organization_id(&entity)
        && user.organization_id != organization_id
    {
        tracing::warn!(
            entity_type = T::table_name(),
            entity_id = %id,
            user_id = %user.user_id,
            "Unauthorized delete attempt - entity belongs to different organization"
        );
        return Err(ApiError::unauthorized(
            "You don't have access to delete this entity".to_string(),
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

    // Fetch all entities by the requested IDs
    let entity_filter = EntityFilter::unfiltered().entity_ids(&ids);
    let entities = service.get_all(entity_filter).await?;

    // Verify we found all requested entities
    if entities.len() != ids.len() {
        let found_ids: Vec<Uuid> = entities.iter().map(|e| e.id()).collect();
        let missing: Vec<&Uuid> = ids.iter().filter(|id| !found_ids.contains(id)).collect();
        tracing::warn!(
            entity_type = T::table_name(),
            user_id = %user.user_id,
            missing_ids = ?missing,
            "Bulk delete requested non-existent entities"
        );
    }

    // Verify ownership of ALL entities before deleting any
    for entity in &entities {
        if let Some(network_id) = service.get_network_id(entity)
            && !user.network_ids.contains(&network_id)
        {
            tracing::warn!(
                entity_type = T::table_name(),
                user_id = %user.user_id,
                entity_network_id = %network_id,
                "Bulk delete rejected - user lacks access to entity's network"
            );
            return Err(ApiError::unauthorized(
                "You don't have access to delete one or more of these entities".to_string(),
            ));
        }

        if let Some(organization_id) = service.get_organization_id(entity)
            && user.organization_id != organization_id
        {
            tracing::warn!(
                entity_type = T::table_name(),
                user_id = %user.user_id,
                entity_org_id = %organization_id,
                "Bulk delete rejected - entity belongs to different organization"
            );
            return Err(ApiError::unauthorized(
                "You don't have access to delete one or more of these entities".to_string(),
            ));
        }
    }

    // Only delete entities that actually exist and user has access to
    let valid_ids: Vec<Uuid> = entities.iter().map(|e| e.id()).collect();

    let deleted_count = service
        .delete_many(&valid_ids, user.clone().into())
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
