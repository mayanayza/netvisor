use crate::server::{
    api_keys::r#impl::{api::ApiKeyResponse, base::ApiKey},
    auth::middleware::AuthenticatedUser,
    config::AppState,
    shared::{
        handlers::traits::{CrudHandlers, delete_handler, get_all_handler, get_by_id_handler},
        services::traits::CrudService,
        types::api::{ApiError, ApiResponse, ApiResult},
    },
};
use axum::{
    Json, Router,
    extract::{Path, State},
    routing::{delete, get, post, put},
};
use std::sync::Arc;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", get(get_all_handler::<ApiKey>))
        .route("/", post(create_handler))
        .route("/{id}/rotate", post(rotate_key_handler))
        .route("/{id}", put(update_handler))
        .route("/{id}", delete(delete_handler::<ApiKey>))
        .route("/{id}", get(get_by_id_handler::<ApiKey>))
}

pub async fn create_handler(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Json(api_key): Json<ApiKey>,
) -> ApiResult<Json<ApiResponse<ApiKeyResponse>>> {
    let service = ApiKey::get_service(&state);
    let api_key = service.create(api_key).await?;

    Ok(Json(ApiResponse::success(ApiKeyResponse {
        key: api_key.base.key.clone(),
        api_key,
    })))
}

pub async fn rotate_key_handler(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Path(api_key_id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<String>>> {
    let service = ApiKey::get_service(&state);
    let key = service.rotate_key(api_key_id).await?;

    Ok(Json(ApiResponse::success(key)))
}

pub async fn update_handler(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Path(id): Path<Uuid>,
    Json(mut request): Json<ApiKey>,
) -> ApiResult<Json<ApiResponse<ApiKey>>> {
    let service = ApiKey::get_service(&state);

    // Verify entity exists
    let existing = service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found(format!("Api Key '{}' not found", id)))?;

    request.base.key = existing.base.key;

    let updated = service
        .update(&mut request)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(updated)))
}
