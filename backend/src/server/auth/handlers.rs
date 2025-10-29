use crate::server::{
    auth::types::api::{LoginRequest, RegisterRequest},
    config::AppState,
    shared::types::api::{ApiError, ApiResponse, ApiResult},
    users::types::base::User,
};
use axum::{Router, extract::State, response::Json, routing::post};
use axum_extra::extract::cookie::{Cookie, CookieJar};
use std::sync::Arc;
use time::Duration;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/register", post(register))
        .route("/login", post(login))
        .route("/logout", post(logout))
        .route("/me", post(get_current_user))
}

async fn register(
    State(state): State<Arc<AppState>>,
    jar: CookieJar,
    Json(request): Json<RegisterRequest>,
) -> ApiResult<(CookieJar, Json<ApiResponse<User>>)> {
    let (user, session_id) = state.services.auth_service.register(request).await?;

    // Create session cookie
    let cookie = Cookie::build(("session_id", session_id))
        .path("/")
        .http_only(true)
        .secure(true) // Set to true in production with HTTPS
        .same_site(axum_extra::extract::cookie::SameSite::Lax)
        .max_age(Duration::days(30))
        .build();

    Ok((jar.add(cookie), Json(ApiResponse::success(user))))
}

async fn login(
    State(state): State<Arc<AppState>>,
    jar: CookieJar,
    Json(request): Json<LoginRequest>,
) -> ApiResult<(CookieJar, Json<ApiResponse<User>>)> {
    let max_age = if request.remember_me {
        Duration::days(30)
    } else {
        Duration::days(1)
    };

    let (user, session_id) = state.services.auth_service.login(request).await?;

    let cookie = Cookie::build(("session_id", session_id))
        .path("/")
        .http_only(true)
        .secure(true) // Set to true in production with HTTPS
        .same_site(axum_extra::extract::cookie::SameSite::Lax)
        .max_age(max_age)
        .build();

    Ok((jar.add(cookie), Json(ApiResponse::success(user))))
}

async fn logout(
    State(state): State<Arc<AppState>>,
    jar: CookieJar,
) -> ApiResult<(CookieJar, Json<ApiResponse<()>>)> {
    // Get session_id from cookie
    if let Some(cookie) = jar.get("session_id") {
        let session_id = cookie.value();
        state.services.auth_service.logout(session_id).await?;
    }

    // Remove session cookie
    let cookie = Cookie::build(("session_id", ""))
        .path("/")
        .max_age(Duration::seconds(0))
        .build();

    Ok((jar.add(cookie), Json(ApiResponse::success(()))))
}

async fn get_current_user(
    State(state): State<Arc<AppState>>,
    jar: CookieJar,
) -> ApiResult<Json<ApiResponse<User>>> {
    // Get session_id from cookie
    let session_id = jar
        .get("session_id")
        .map(|c| c.value())
        .ok_or_else(|| ApiError::unauthorized("Not authenticated".to_string()))?;

    // Validate session
    let session_user = state
        .services
        .auth_service
        .validate_session(session_id)
        .await
        .map_err(|_| ApiError::unauthorized("Invalid or expired session".to_string()))?;

    // Get full user data
    let user = state
        .services
        .user_service
        .get_user(&session_user.user_id)
        .await?
        .ok_or_else(|| ApiError::not_found("User not found".to_string()))?;

    Ok(Json(ApiResponse::success(user)))
}
