use crate::server::{
    auth::middleware::{auth::AuthenticatedUser, permissions::RequireMember},
    config::AppState,
    shared::{
        entities::{ChangeTriggersTopologyStaleness, Entity},
        handlers::query::{FilterQueryExtractor, ParentQueryExtractor},
        services::traits::{CrudService, EventBusService},
        storage::{child::ChildStorableEntity, filter::EntityFilter, traits::StorableEntity},
        types::api::{ApiError, ApiResponse, ApiResult},
        validation::{
            validate_bulk_delete_access, validate_create_access, validate_delete_access,
            validate_entity, validate_read_access, validate_update_access,
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
use utoipa::ToSchema;
use std::fmt::Display;
use std::sync::Arc;
use uuid::Uuid;

/// Trait for creating standard CRUD handlers for an entity
#[async_trait]
pub trait CrudHandlers: StorableEntity + Serialize + for<'de> Deserialize<'de>
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

    /// Optional: Validate entity before create/update
    fn validate(&self) -> Result<(), String> {
        Ok(())
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
    Json(entity): Json<T>,
) -> ApiResult<Json<ApiResponse<T>>>
where
    T: CrudHandlers + 'static + ChangeTriggersTopologyStaleness<T> + Default,
    Entity: From<T>,
{
    validate_entity(|| entity.validate(), T::entity_name())?;

    let service = T::get_service(&state);

    validate_create_access(
        service.get_network_id(&entity),
        service.get_organization_id(&entity),
        &user.network_ids,
        user.organization_id,
    )?;

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
    Query(query): Query<T::FilterQuery>,
) -> ApiResult<Json<ApiResponse<Vec<T>>>>
where
    T: CrudHandlers + 'static + ChangeTriggersTopologyStaleness<T> + Default,
    Entity: From<T>,
{
    let filter = query.apply_to_filter(
        EntityFilter::unfiltered(),
        &user.network_ids,
        user.organization_id,
    );

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

    validate_update_access(
        service.get_network_id(&existing),
        service.get_organization_id(&existing),
        service.get_network_id(&entity),
        service.get_organization_id(&entity),
        &user.network_ids,
        user.organization_id,
    )?;

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

#[derive(Serialize, ToSchema)]
pub struct BulkDeleteResponse {
    pub deleted_count: usize,
    pub requested_count: usize,
}

/// Trait for creating CRUD handlers for child entities that support parent filtering.
/// Extends CrudHandlers by requiring ChildStorableEntity which provides parent_column().
pub trait ChildCrudHandlers: CrudHandlers + ChildStorableEntity
where
    Self: Display + ChangeTriggersTopologyStaleness<Self> + Default,
    Entity: From<Self>,
{
    /// Query type for parent filtering in get_all requests.
    /// Use `HostIdQuery` for entities with host_id parent,
    /// `ServiceIdQuery` for entities with service_id parent, etc.
    type ParentQuery: ParentQueryExtractor;
}

/// Create a CRUD router for child entities with parent-based query filtering.
/// Supports `GET /entity?{parent_column}=uuid` for filtering by parent.
pub fn create_child_crud_router<T>() -> Router<Arc<AppState>>
where
    T: ChildCrudHandlers + 'static + ChangeTriggersTopologyStaleness<T> + Default,
    Entity: From<T>,
{
    Router::new()
        .route("/", post(create_handler::<T>))
        .route("/", get(get_all_children_handler::<T>))
        .route("/{id}", put(update_handler::<T>))
        .route("/{id}", delete(delete_handler::<T>))
        .route("/{id}", get(get_by_id_handler::<T>))
        .route("/bulk-delete", post(bulk_delete_handler::<T>))
}

/// Get all child entities with optional parent filtering.
/// Uses the entity's ParentQuery type to extract parent ID from query params.
pub async fn get_all_children_handler<T>(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
    Query(parent_query): Query<T::ParentQuery>,
) -> ApiResult<Json<ApiResponse<Vec<T>>>>
where
    T: ChildCrudHandlers + 'static + ChangeTriggersTopologyStaleness<T> + Default,
    Entity: From<T>,
{
    let mut filter = EntityFilter::unfiltered().network_ids(&user.network_ids);

    // Apply parent filter if provided
    if let Some(parent_id) = parent_query.parent_id() {
        filter = filter.uuid_column(T::parent_column(), &parent_id);
    }

    let service = T::get_service(&state);

    let entities = service.get_all(filter).await.map_err(|e| {
        tracing::error!(
            entity_type = T::table_name(),
            user_id = %user.user_id,
            error = %e,
            "Failed to fetch child entities"
        );
        ApiError::internal_error(&e.to_string())
    })?;

    Ok(Json(ApiResponse::success(entities)))
}
