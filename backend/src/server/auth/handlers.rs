use crate::server::{
    auth::types::api::{LoginRequest, RegisterRequest},
    config::AppState,
    shared::types::api::{ApiError, ApiResponse, ApiResult},
    users::types::base::User,
};
use axum::{Router, extract::State, response::Json, routing::post};
use std::sync::Arc;
use tower_sessions::Session;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/register", post(register))
        .route("/login", post(login))
        .route("/logout", post(logout))
        .route("/me", post(get_current_user))
}

async fn register(
    State(state): State<Arc<AppState>>,
    session: Session,
    Json(request): Json<RegisterRequest>,
) -> ApiResult<Json<ApiResponse<User>>> {
    let user = state.services.auth_service.register(request).await?;

    // Store user_id in session
    session
        .insert("user_id", user.id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;

    Ok(Json(ApiResponse::success(user)))
}

async fn login(
    State(state): State<Arc<AppState>>,
    session: Session,
    Json(request): Json<LoginRequest>,
) -> ApiResult<Json<ApiResponse<User>>> {
    let user = state.services.auth_service.login(request).await?;

    // Store user_id in session
    session
        .insert("user_id", user.id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;

    Ok(Json(ApiResponse::success(user)))
}

async fn logout(session: Session) -> ApiResult<Json<ApiResponse<()>>> {
    // Delete the entire session
    session
        .delete()
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to delete session: {}", e)))?;

    Ok(Json(ApiResponse::success(())))
}

async fn get_current_user(
    State(state): State<Arc<AppState>>,
    session: Session,
) -> ApiResult<Json<ApiResponse<User>>> {
    // Get user_id from session
    let user_id: Uuid = session
        .get("user_id")
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to read session: {}", e)))?
        .ok_or_else(|| ApiError::unauthorized("Not authenticated".to_string()))?;

    // Get full user data
    let user = state
        .services
        .user_service
        .get_user(&user_id)
        .await?
        .ok_or_else(|| ApiError::not_found("User not found".to_string()))?;

    Ok(Json(ApiResponse::success(user)))
}