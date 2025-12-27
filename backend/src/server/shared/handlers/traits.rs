use crate::server::{
    auth::middleware::{auth::AuthenticatedUser, permissions::RequireMember},
    config::AppState,
    shared::{
        entities::{ChangeTriggersTopologyStaleness, Entity},
        handlers::query::FilterQueryExtractor,
        services::traits::{CrudService, EventBusService},
        storage::{filter::EntityFilter, traits::StorableEntity},
        types::api::{ApiError, ApiResponse, ApiResult},
        types::entities::EntitySource,
        validation::{
            validate_and_dedupe_tags, validate_bulk_delete_access, validate_create_access,
            validate_delete_access, validate_entity, validate_read_access, validate_update_access,
        },
    },
};
use async_trait::async_trait;
use axum::{
    Router,
    extract::{Path, Query, State},
    response::Json,
    routing::{delete, get, post, put},
};
use serde::{Deserialize, Serialize};
use std::fmt::Display;
use std::sync::Arc;
use utoipa::ToSchema;
use uuid::Uuid;

/// Trait for creating standard CRUD handlers for an entity
#[async_trait]
pub trait CrudHandlers:
    StorableEntity + Serialize + for<'de> Deserialize<'de> + validator::Validate
where
    Self: Display + ChangeTriggersTopologyStaleness<Self> + Default,
    Entity: From<Self>,
{
    /// Get the service from AppState (must implement CrudService)
    type Service: CrudService<Self> + Send + Sync;
    fn get_service(state: &AppState) -> &Self::Service;

    /// Query type for filtering in get_all requests.
    /// Use `NetworkFilterQuery` for network-keyed entities,
    /// `OrganizationFilterQuery` for organization-keyed entities.
    type FilterQuery: FilterQueryExtractor;

    /// Get entity name for error messages (e.g., "Group", "Network")
    fn entity_name() -> &'static str {
        Self::table_name()
    }

    /// Validate entity before create/update (uses validator crate by default)
    fn validate(&self) -> Result<(), String> {
        validator::Validate::validate(self).map_err(|e| e.to_string())
    }

    /// Optional: Set the source field on the entity.
    /// Override for entities with a source field to set it appropriately.
    /// Default is a no-op for entities without a source field.
    fn set_source(&mut self, _source: EntitySource) {
        // Default: no-op
    }

    /// Optional: Preserve entity-specific immutable fields from the existing entity.
    /// Override for entities that have additional read-only fields beyond id/created_at.
    /// For example, ApiKey should preserve `key` and `last_used`.
    /// Default is a no-op for entities without extra immutable fields.
    fn preserve_immutable_fields(&mut self, _existing: &Self) {
        // Default: no-op
    }

    /// Optional: Get the tags field from the entity for validation.
    /// Override for entities with a tags field.
    /// Returns None for entities without tags.
    fn get_tags(&self) -> Option<&Vec<Uuid>> {
        None
    }

    /// Optional: Set the tags field on the entity.
    /// Override for entities with a tags field.
    fn set_tags(&mut self, _tags: Vec<Uuid>) {
        // Default: no-op
    }
}

/// Create a standard CRUD router
pub fn create_crud_router<T>() -> Router<Arc<AppState>>
where
    T: CrudHandlers + 'static + ChangeTriggersTopologyStaleness<T> + Default,
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
    Json(mut entity): Json<T>,
) -> ApiResult<Json<ApiResponse<T>>>
where
    T: CrudHandlers + 'static + ChangeTriggersTopologyStaleness<T> + Default,
    Entity: From<T>,
{
    // Set source to Manual for user-created entities
    entity.set_source(EntitySource::Manual);

    validate_entity(|| CrudHandlers::validate(&entity), T::entity_name())?;

    let service = T::get_service(&state);

    validate_create_access(
        service.get_network_id(&entity),
        service.get_organization_id(&entity),
        &user.network_ids,
        user.organization_id,
    )?;

    // Validate and dedupe tags if entity has them
    if let Some(tags) = entity.get_tags() {
        let validated_tags = validate_and_dedupe_tags(
            tags.clone(),
            user.organization_id,
            &state.services.tag_service,
        )
        .await?;
        entity.set_tags(validated_tags);
    }

    let created = service
        .create(entity, user.clone().into())
        .await
        .map_err(|e| {
            // Use From<anyhow::Error> to properly handle ValidationError (400) vs internal errors (500)
            let api_error = ApiError::from(e);
            if api_error.status.is_server_error() {
                tracing::error!(
                    entity_type = T::table_name(),
                    user_id = %user.user_id,
                    error = %api_error.message,
                    "Failed to create entity"
                );
            }
            api_error
        })?;

    Ok(Json(ApiResponse::success(created)))
}

pub async fn get_all_handler<T>(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
    Query(query): Query<T::FilterQuery>,
) -> ApiResult<Json<ApiResponse<Vec<T>>>>
where
    T: CrudHandlers + 'static + ChangeTriggersTopologyStaleness<T> + Default,
    Entity: From<T>,
{
    let base_filter = if T::is_network_keyed() {
        EntityFilter::unfiltered().network_ids(&user.network_ids)
    } else {
        EntityFilter::unfiltered().organization_id(&user.organization_id)
    };

    let filter = query.apply_to_filter(base_filter, &user.network_ids, user.organization_id);

    let service = T::get_service(&state);

    let entities = service.get_all(filter).await.map_err(|e| {
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
    T: CrudHandlers + 'static + ChangeTriggersTopologyStaleness<T> + Default,
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

    validate_read_access(
        service.get_network_id(&entity),
        service.get_organization_id(&entity),
        &user.network_ids,
        user.organization_id,
    )?;

    Ok(Json(ApiResponse::success(entity)))
}

pub async fn update_handler<T>(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
    Json(mut entity): Json<T>,
) -> ApiResult<Json<ApiResponse<T>>>
where
    T: CrudHandlers + 'static + ChangeTriggersTopologyStaleness<T> + Default,
    Entity: From<T>,
{
    let service = T::get_service(&state);

    // Fetch existing entity and verify ownership BEFORE any updates
    // The path ID is canonical - we use it to find the existing entity
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

    // Preserve immutable fields from existing entity.
    // These fields cannot be changed via the API - the existing values are authoritative.
    // This includes: id, created_at (common to all entities), plus any entity-specific
    // immutable fields handled by preserve_immutable_fields (e.g., ApiKey.key, Daemon.url).
    entity.set_id(existing.id());
    entity.set_created_at(existing.created_at());
    entity.preserve_immutable_fields(&existing);

    // Validate entity (e.g., name length limits)
    validate_entity(|| CrudHandlers::validate(&entity), T::entity_name())?;

    validate_update_access(
        service.get_network_id(&existing),
        service.get_organization_id(&existing),
        service.get_network_id(&entity),
        service.get_organization_id(&entity),
        &user.network_ids,
        user.organization_id,
    )?;

    // Validate and dedupe tags if entity has them
    if let Some(tags) = entity.get_tags() {
        let validated_tags = validate_and_dedupe_tags(
            tags.clone(),
            user.organization_id,
            &state.services.tag_service,
        )
        .await?;
        entity.set_tags(validated_tags);
    }

    let updated = service
        .update(&mut entity, user.clone().into())
        .await
        .map_err(|e| {
            // Use From<anyhow::Error> to properly handle ValidationError (400) vs internal errors (500)
            let api_error = ApiError::from(e);
            if api_error.status.is_server_error() {
                tracing::error!(
                    entity_type = T::table_name(),
                    entity_id = %id,
                    user_id = %user.user_id,
                    error = %api_error.message,
                    "Failed to update entity"
                );
            }
            api_error
        })?;

    Ok(Json(ApiResponse::success(updated)))
}

pub async fn delete_handler<T>(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>>
where
    T: CrudHandlers + 'static + ChangeTriggersTopologyStaleness<T> + Default,
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

    validate_delete_access(
        service.get_network_id(&entity),
        service.get_organization_id(&entity),
        &user.network_ids,
        user.organization_id,
    )?;

    service.delete(&id, user.into()).await.map_err(|e| {
        // Use From<anyhow::Error> to properly handle ValidationError (400) vs internal errors (500)
        let api_error = ApiError::from(e);
        if api_error.status.is_server_error() {
            tracing::error!(
                entity_type = T::table_name(),
                entity_id = %id,
                error = %api_error.message,
                "Failed to delete entity"
            );
        }
        api_error
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
        validate_bulk_delete_access(
            service.get_network_id(entity),
            service.get_organization_id(entity),
            &user.network_ids,
            user.organization_id,
        )?;
    }

    // Only delete entities that actually exist and user has access to
    let valid_ids: Vec<Uuid> = entities.iter().map(|e| e.id()).collect();

    let deleted_count = service
        .delete_many(&valid_ids, user.clone().into())
        .await
        .map_err(|e| {
            // Use From<anyhow::Error> to properly handle ValidationError (400) vs internal errors (500)
            let api_error = ApiError::from(e);
            if api_error.status.is_server_error() {
                tracing::error!(
                    entity_type = T::table_name(),
                    user_id = %user.user_id,
                    error = %api_error.message,
                    "Failed to bulk delete entities"
                );
            }
            api_error
        })?;

    Ok(Json(ApiResponse::success(BulkDeleteResponse {
        deleted_count,
        requested_count: ids.len(),
    })))
}

#[derive(Serialize, ToSchema)]
pub struct BulkDeleteResponse {
    pub deleted_count: usize,
    pub requested_count: usize,
}
