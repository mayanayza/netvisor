use crate::server::{
    api_keys::r#impl::{api::ApiKeyResponse, base::ApiKey},
    auth::middleware::RequireMember,
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
    RequireMember(user): RequireMember,
    Json(api_key): Json<ApiKey>,
) -> ApiResult<Json<ApiResponse<ApiKeyResponse>>> {
    tracing::debug!(
        api_key_name = %api_key.base.name,
        network_id = %api_key.base.network_id,
        user_id = %user.user_id,
        "API key create request received"
    );

    let service = ApiKey::get_service(&state);
    let api_key = service
        .create(api_key, user.clone().into())
        .await
        .map_err(|e| {
            tracing::error!(
                error = %e,
                user_id = %user.user_id,
                "Failed to create API key"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    tracing::info!(
        api_key_id = %api_key.id,
        api_key_name = %api_key.base.name,
        user_id = %user.user_id,
        "API key created via API (key shown to user)"
    );

    Ok(Json(ApiResponse::success(ApiKeyResponse {
        key: api_key.base.key.clone(),
        api_key,
    })))
}

pub async fn rotate_key_handler(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(api_key_id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<String>>> {
    tracing::info!(
        api_key_id = %api_key_id,
        user_id = %user.user_id,
        "API key rotation request received"
    );

    let service = ApiKey::get_service(&state);
    let key = service
        .rotate_key(api_key_id, user.clone().into())
        .await
        .map_err(|e| {
            tracing::error!(
                api_key_id = %api_key_id,
                user_id = %user.user_id,
                error = %e,
                "Failed to rotate API key"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    tracing::info!(
        api_key_id = %api_key_id,
        user_id = %user.user_id,
        "API key rotated via API (new key shown to user)"
    );

    Ok(Json(ApiResponse::success(key)))
}

pub async fn update_handler(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
    Json(mut request): Json<ApiKey>,
) -> ApiResult<Json<ApiResponse<ApiKey>>> {
    tracing::debug!(
        api_key_id = %id,
        user_id = %user.user_id,
        "API key update request received"
    );

    let service = ApiKey::get_service(&state);

    // Verify entity exists
    let existing = service
        .get_by_id(&id)
        .await
        .map_err(|e| {
            tracing::error!(
                api_key_id = %id,
                user_id = %user.user_id,
                error = %e,
                "Failed to fetch API key for update"
            );
            ApiError::internal_error(&e.to_string())
        })?
        .ok_or_else(|| {
            tracing::warn!(
                api_key_id = %id,
                user_id = %user.user_id,
                "API key not found for update"
            );
            ApiError::not_found(format!("Api Key '{}' not found", id))
        })?;

    // Preserve the key - don't allow it to be changed via update
    request.base.key = existing.base.key;

    let updated = service
        .update(&mut request, user.clone().into())
        .await
        .map_err(|e| {
            tracing::error!(
                api_key_id = %id,
                user_id = %user.user_id,
                error = %e,
                "Failed to update API key"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    tracing::info!(
        api_key_id = %id,
        api_key_name = %updated.base.name,
        user_id = %user.user_id,
        "API key updated via API"
    );

    Ok(Json(ApiResponse::success(updated)))
}
