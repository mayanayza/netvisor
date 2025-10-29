use crate::server::{
    config::AppState,
    shared::types::api::{ApiError, ApiResponse, ApiResult},
    users::types::base::User,
};
use axum::{
    Router,
    extract::{Path, State},
    response::Json,
    routing::{delete, get, post, put},
};
use std::sync::Arc;
use uuid::Uuid;
use validator::Validate;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", get(get_users))
        .route("/", post(create_user))
        .route("/{id}", put(update_user))
        .route("/{id}", delete(delete_user))
        .route("/{id}", get(get_user))
}

async fn create_user(
    State(state): State<Arc<AppState>>,
    Json(request): Json<User>,
) -> ApiResult<Json<ApiResponse<User>>> {
    tracing::info!("Received user creation request: {:?}", request);

    if let Err(validation_errors) = request.base.validate() {
        tracing::error!("User validation failed: {:?}", validation_errors);
        return Err(ApiError::bad_request(&format!(
            "User validation failed: {}",
            validation_errors
        )));
    }

    let service = &state.services.user_service;
    let created_user = service.create_user(request).await?;

    Ok(Json(ApiResponse::success(created_user)))
}

async fn get_users(State(state): State<Arc<AppState>>) -> ApiResult<Json<ApiResponse<Vec<User>>>> {
    let users = state.services.user_service.get_all_users().await?;

    Ok(Json(ApiResponse::success(users)))
}

async fn get_user(
    State(state): State<Arc<AppState>>,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<User>>> {
    let service = &state.services.user_service;

    match service.get_user(&id).await? {
        Some(user) => Ok(Json(ApiResponse::success(user))),
        None => Err(ApiError::not_found(format!("User '{}' not found", &id))),
    }
}

async fn update_user(
    State(state): State<Arc<AppState>>,
    Path(id): Path<Uuid>,
    Json(request): Json<User>,
) -> ApiResult<Json<ApiResponse<User>>> {
    let service = &state.services.user_service;

    let mut user = service
        .get_user(&id)
        .await?
        .ok_or_else(|| ApiError::not_found(format!("User '{}' not found", &id)))?;

    user.base = request.base;

    let updated_user = service.update_user(user).await?;

    Ok(Json(ApiResponse::success(updated_user)))
}

async fn delete_user(
    State(state): State<Arc<AppState>>,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let service = &state.services.user_service;

    // Check if network exists
    if service.get_user(&id).await?.is_none() {
        return Err(ApiError::not_found(format!("User '{}' not found", &id)));
    }

    service.delete_user(&id).await?;

    Ok(Json(ApiResponse::success(())))
}
