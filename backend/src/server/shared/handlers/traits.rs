use crate::server::{
    auth::middleware::AuthenticatedUser, config::AppState, networks::service::NetworkService, shared::{
        services::traits::CrudService,
        storage::{filter::EntityFilter, traits::StorableEntity},
        types::api::{ApiError, ApiResponse, ApiResult},
    }
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

    async fn get_user_allowed_network_ids_filter(user: AuthenticatedUser, network_service: Arc<NetworkService>) -> Result<EntityFilter, ApiError> {
        let org_filter = EntityFilter::unfiltered().organization_id(&user.organization_id);

        let network_ids: Vec<Uuid> = network_service
            .get_all(org_filter)
            .await
            .map_err(|e| ApiError::internal_error(&e.to_string()))?
            .iter()
            .map(|n| n.id())
            .collect();

        Ok(EntityFilter::unfiltered().network_ids(&network_ids))
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
    _user: AuthenticatedUser,
    Json(request): Json<T>,
) -> ApiResult<Json<ApiResponse<T>>>
where
    T: CrudHandlers + 'static,
{
    if let Err(err) = request.validate() {
        return Err(ApiError::bad_request(&format!(
            "{} validation failed: {}",
            T::entity_name(),
            err
        )));
    }

    let service = T::get_service(&state);
    let created = service
        .create(request)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(created)))
}

pub async fn get_all_handler<T>(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> ApiResult<Json<ApiResponse<Vec<T>>>>
where
    T: CrudHandlers + 'static,
{
    let network_filter = T::get_user_allowed_network_ids_filter(user, state.services.network_service.clone()).await?;

    let service = T::get_service(&state);
    let entities = service
        .get_all(network_filter)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(entities)))
}

pub async fn get_by_id_handler<T>(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<T>>>
where
    T: CrudHandlers + 'static,
{
    let service = T::get_service(&state);
    let entity = service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found(format!("{} '{}' not found", T::entity_name(), id)))?;

    Ok(Json(ApiResponse::success(entity)))
}

pub async fn update_handler<T>(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Path(id): Path<Uuid>,
    Json(mut request): Json<T>,
) -> ApiResult<Json<ApiResponse<T>>>
where
    T: CrudHandlers + 'static,
{
    let service = T::get_service(&state);

    // Verify entity exists
    service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found(format!("{} '{}' not found", T::entity_name(), id)))?;

    let updated = service
        .update(&mut request)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(updated)))
}

pub async fn delete_handler<T>(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>>
where
    T: CrudHandlers + 'static,
{
    let service = T::get_service(&state);

    // Verify entity exists
    service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found(format!("{} '{}' not found", T::entity_name(), id)))?;

    service
        .delete(&id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(())))
}
