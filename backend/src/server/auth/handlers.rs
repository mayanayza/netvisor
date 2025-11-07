use crate::server::{
    api_keys,
    auth::{r#impl::api::{LinkOidcRequest, LoginRequest, OidcCallbackParams, RegisterRequest}, oidc::OidcPendingAuth},
    config::AppState,
    shared::{
        services::traits::CrudService, storage::filter::EntityFilter, types::api::{ApiError, ApiResponse, ApiResult}
    },
    users::r#impl::base::User,
};
use axum::{Router, extract::{Query, State}, response::{Json, Redirect}, routing::{get, post}};
use std::sync::Arc;
use tower_sessions::Session;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/register", post(register))
        .route("/login", post(login))
        .route("/logout", post(logout))
        .route("/me", post(get_current_user))
        .nest("/keys", api_keys::handlers::create_router())
        .route("/oidc/authorize", get(oidc_authorize))
        .route("/oidc/callback", get(oidc_callback))
        .route("/oidc/link", post(link_oidc_account))
        .route("/oidc/unlink", post(unlink_oidc_account))
}

async fn register(
    State(state): State<Arc<AppState>>,
    session: Session,
    Json(request): Json<RegisterRequest>,
) -> ApiResult<Json<ApiResponse<User>>> {
    if state.config.disable_registration {
        return Err(ApiError::forbidden("User registration is disabled"));
    }

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
        .get_by_id(&user_id)
        .await?
        .ok_or_else(|| ApiError::not_found("User not found".to_string()))?;

    Ok(Json(ApiResponse::success(user)))
}

async fn oidc_authorize(
    State(state): State<Arc<AppState>>,
    session: Session,
) -> ApiResult<Redirect> {
    let oidc_client = state
        .oidc_client
        .as_ref()
        .ok_or_else(|| ApiError::internal_error("OIDC not configured"))?;

    let (auth_url, pending_auth) = oidc_client
        .authorize_url()
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to generate auth URL: {}", e)))?;

    // Store pending auth in session for callback verification
    session
        .insert("oidc_pending_auth", pending_auth)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;

    Ok(Redirect::to(&auth_url))
}

async fn oidc_callback(
    State(state): State<Arc<AppState>>,
    session: Session,
    Query(params): Query<OidcCallbackParams>,
) -> ApiResult<Redirect> {
    let oidc_client = state
        .oidc_client
        .as_ref()
        .ok_or_else(|| ApiError::internal_error("OIDC not configured"))?;

    // Retrieve pending auth from session
    let pending_auth: OidcPendingAuth = session
        .get("oidc_pending_auth")
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to read session: {}", e)))?
        .ok_or_else(|| ApiError::unauthorized("No pending OIDC authentication".to_string()))?;

    // Verify CSRF token
    if pending_auth.csrf_token != params.state {
        return Err(ApiError::unauthorized("Invalid CSRF token".to_string()));
    }

    // Exchange code for user info
    let user_info = oidc_client
        .exchange_code(&params.code, pending_auth)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to exchange code: {}", e)))?;

    // Check if OIDC account already linked to a user
    let existing_user = state
        .services
        .user_service
        .get_user_by_oidc(&user_info.subject)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to query user: {}", e)))?;

    if let Some(user) = existing_user {
        // User exists - log them in
        session
            .insert("user_id", user.id)
            .await
            .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;

        // Clear pending auth
        let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;

        Ok(Redirect::to("/"))
    } else {
        // New user - create account
        let username = user_info
            .email
            .clone()
            .unwrap_or_else(|| format!("oidc_{}", &user_info.subject[..8]));

        let all_users = state.services.user_service.get_all(EntityFilter::unfiltered()).await?;
        let seed_user: Option<User> = all_users.iter()
            .find(|u| u.base.password_hash.is_none() && u.base.oidc_subject.is_none())
            .cloned();
        
        let new_user = if let Some(mut seed_user) = seed_user {
            // First user ever - claim seed user
            tracing::info!("First user (OIDC) - claiming seed user");
            seed_user.base.username = username;
            seed_user.base.oidc_subject = Some(user_info.subject.clone());
            seed_user.base.oidc_provider = state.config.oidc_provider_name.clone();
            seed_user.base.oidc_linked_at = Some(chrono::Utc::now());
            state.services.user_service.update(&mut seed_user).await?
        } else {
            // Not first user - create new
            state.services.user_service
                .create_user_with_oidc(username, user_info.subject.clone(), state.config.oidc_provider_name.clone())
                .await?
        };

        session
            .insert("user_id", new_user.id)
            .await
            .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;

        // Clear pending auth
        let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;

        Ok(Redirect::to("/"))
    }
}

async fn link_oidc_account(
    State(state): State<Arc<AppState>>,
    session: Session,
    Json(request): Json<LinkOidcRequest>,
) -> ApiResult<Json<ApiResponse<User>>> {
    // Get authenticated user from session
    let user_id: Uuid = session
        .get("user_id")
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to read session: {}", e)))?
        .ok_or_else(|| ApiError::unauthorized("Not authenticated".to_string()))?;

    let oidc_client = state
        .oidc_client
        .as_ref()
        .ok_or_else(|| ApiError::internal_error("OIDC not configured"))?;

    // Retrieve pending auth from session
    let pending_auth: OidcPendingAuth = session
        .get("oidc_pending_auth")
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to read session: {}", e)))?
        .ok_or_else(|| ApiError::unauthorized("No pending OIDC authentication".to_string()))?;

    // Verify CSRF token
    if pending_auth.csrf_token != request.state {
        return Err(ApiError::unauthorized("Invalid CSRF token".to_string()));
    }

    // Exchange code for user info
    let user_info = oidc_client
        .exchange_code(&request.code, pending_auth)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to exchange code: {}", e)))?;

    // Check if this OIDC account is already linked to another user
    if let Some(existing_user) = state
        .services
        .user_service
        .get_user_by_oidc(&user_info.subject)
        .await?
    {
        if existing_user.id != user_id {
            return Err(ApiError::bad_request(
                "This OIDC account is already linked to another user",
            ));
        }
        // Already linked to this user, just return success
        return Ok(Json(ApiResponse::success(existing_user)));
    }

    // Link OIDC to user
    let updated_user = state
        .services
        .user_service
        .link_oidc(&user_id, user_info.subject, state.config.oidc_provider_name.clone())
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to link OIDC: {}", e)))?;

    // Clear pending auth
    let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;

    Ok(Json(ApiResponse::success(updated_user)))
}

async fn unlink_oidc_account(
    State(state): State<Arc<AppState>>,
    session: Session,
) -> ApiResult<Json<ApiResponse<User>>> {
    // Get authenticated user from session
    let user_id: Uuid = session
        .get("user_id")
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to read session: {}", e)))?
        .ok_or_else(|| ApiError::unauthorized("Not authenticated".to_string()))?;

    let updated_user = state
        .services
        .user_service
        .unlink_oidc(&user_id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to unlink OIDC: {}", e)))?;

    Ok(Json(ApiResponse::success(updated_user)))
}