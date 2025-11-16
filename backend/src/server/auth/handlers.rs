use crate::server::{
    api_keys,
    auth::{
        r#impl::api::{
            LoginRequest, OidcAuthorizeParams, OidcCallbackParams, RegisterRequest,
            UpdateEmailPasswordRequest,
        },
        oidc::OidcPendingAuth,
        service::hash_password,
    },
    config::AppState,
    organizations::handlers::process_pending_invite,
    shared::{
        services::traits::CrudService,
        types::api::{ApiError, ApiResponse, ApiResult},
    },
    users::r#impl::base::User,
};
use axum::{
    Router,
    extract::{Query, State},
    response::{Json, Redirect},
    routing::{get, post},
};
use std::sync::Arc;
use tower_sessions::Session;
use url::Url;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/register", post(register))
        .route("/login", post(login))
        .route("/logout", post(logout))
        .route("/me", post(get_current_user))
        .nest("/keys", api_keys::handlers::create_router())
        .route("/update", post(update_password_auth))
        .route("/oidc/authorize", get(oidc_authorize))
        .route("/oidc/callback", get(oidc_callback))
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

    if let Err(e) = process_pending_invite(&state, &session, user.id).await {
        tracing::error!(
            "Failed to process pending invite during registration: {}",
            e
        );
        // Don't fail registration, just log the error
    }

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

    if let Err(e) = process_pending_invite(&state, &session, user.id).await {
        tracing::error!(
            "Failed to process pending invite during registration: {}",
            e
        );
        // Don't fail registration, just log the error
    }

    session
        .insert("user_id", user.id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;

    Ok(Json(ApiResponse::success(user)))
}

async fn logout(session: Session) -> ApiResult<Json<ApiResponse<()>>> {
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
    let user_id: Uuid = session
        .get("user_id")
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to read session: {}", e)))?
        .ok_or_else(|| ApiError::unauthorized("Not authenticated".to_string()))?;

    let user = state
        .services
        .user_service
        .get_by_id(&user_id)
        .await?
        .ok_or_else(|| ApiError::not_found("User not found".to_string()))?;

    Ok(Json(ApiResponse::success(user)))
}

async fn update_password_auth(
    State(state): State<Arc<AppState>>,
    session: Session,
    Json(request): Json<UpdateEmailPasswordRequest>,
) -> ApiResult<Json<ApiResponse<User>>> {
    let user_id: Uuid = session
        .get("user_id")
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to read session: {}", e)))?
        .ok_or_else(|| ApiError::unauthorized("Not authenticated".to_string()))?;

    let mut user = state
        .services
        .user_service
        .get_by_id(&user_id)
        .await?
        .ok_or_else(|| ApiError::not_found("User not found".to_string()))?;

    if let Some(password) = request.password {
        user.set_password(hash_password(&password)?);
    }

    if let Some(email) = request.email {
        user.base.email = email
    }

    state.services.user_service.update(&mut user).await?;

    Ok(Json(ApiResponse::success(user)))
}

async fn oidc_authorize(
    State(state): State<Arc<AppState>>,
    session: Session,
    Query(params): Query<OidcAuthorizeParams>,
) -> ApiResult<Redirect> {
    let oidc_service = state
        .services
        .oidc_service
        .as_ref()
        .ok_or_else(|| ApiError::internal_error("OIDC not configured"))?;

    let (auth_url, pending_auth) = oidc_service
        .authorize_url()
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to generate auth URL: {}", e)))?;

    // Store OIDC flow state in session
    session
        .insert("oidc_pending_auth", pending_auth)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;
    session
        .insert("oidc_is_linking", params.link.unwrap_or(false))
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;
    session
        .insert(
            "oidc_return_url",
            params
                .return_url
                .ok_or_else(|| ApiError::bad_request("return_url parameter is required"))?,
        )
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;
    session
        .insert("oidc_organization_id", params.organization_id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;
    session
        .insert("oidc_permissions", params.permissions)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;

    Ok(Redirect::to(&auth_url))
}

async fn oidc_callback(
    State(state): State<Arc<AppState>>,
    session: Session,
    Query(params): Query<OidcCallbackParams>,
) -> Result<Redirect, Redirect> {
    let oidc_service = match state.services.oidc_service.as_ref() {
        Some(service) => service,
        None => {
            return Err(Redirect::to(&format!(
                "/error?message={}",
                urlencoding::encode("OIDC is not configured on this server")
            )));
        }
    };

    // Extract session data
    let return_url: String = session
        .get("oidc_return_url")
        .await
        .ok()
        .flatten()
        .ok_or_else(|| {
            Redirect::to(&format!(
                "/error?message={}",
                urlencoding::encode("Session error: Unable to determine return URL")
            ))
        })?;

    let pending_auth: OidcPendingAuth = session
        .get("oidc_pending_auth")
        .await
        .ok()
        .flatten()
        .ok_or_else(|| {
            Redirect::to(&format!(
                "{}?error={}",
                return_url,
                urlencoding::encode("No pending authentication found. Please try again.")
            ))
        })?;

    // Verify CSRF token
    if pending_auth.csrf_token != params.state {
        return Err(Redirect::to(&format!(
            "{}?error={}",
            return_url,
            urlencoding::encode("Invalid security token. Please try again.")
        )));
    }

    let is_linking: bool = session
        .get("oidc_is_linking")
        .await
        .ok()
        .flatten()
        .unwrap_or(false);
    let mut return_url_parsed = Url::parse(&return_url).map_err(|_| {
        Redirect::to(&format!(
            "/error?message={}",
            urlencoding::encode("Invalid return URL")
        ))
    })?;

    if is_linking {
        // LINK FLOW
        return_url_parsed
            .query_pairs_mut()
            .append_pair("auth_modal", "true");

        let user_id: Uuid = session.get("user_id").await.ok().flatten().ok_or_else(|| {
            let mut url = return_url_parsed.clone();
            url.query_pairs_mut()
                .append_pair("error", "You must be logged in to link an OIDC account.");
            Redirect::to(url.as_str())
        })?;

        match oidc_service
            .link_to_user(&user_id, &params.code, pending_auth)
            .await
        {
            Ok(_) => {
                // Clear session data
                let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;
                let _ = session.remove::<bool>("oidc_is_linking").await;
                let _ = session.remove::<String>("oidc_return_url").await;

                Ok(Redirect::to(return_url_parsed.as_str()))
            }
            Err(e) => {
                tracing::error!("Failed to link OIDC: {}", e);
                let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;
                let _ = session.remove::<bool>("oidc_is_linking").await;
                let _ = session.remove::<String>("oidc_return_url").await;

                return_url_parsed
                    .query_pairs_mut()
                    .append_pair("error", &format!("Failed to link OIDC account: {}", e));
                Err(Redirect::to(return_url_parsed.as_str()))
            }
        }
    } else {
        // LOGIN FLOW
        let organization_id: Option<Uuid> = session
            .remove("oidc_organization_id")
            .await
            .unwrap_or_default();
        let permissions = session.remove("oidc_permissions").await.unwrap_or_default();

        match oidc_service
            .login_or_register(&params.code, pending_auth, organization_id, permissions)
            .await
        {
            Ok(user) => {
                if let Err(e) = session.insert("user_id", user.id).await {
                    tracing::error!("Failed to save session: {}", e);
                    return Err(Redirect::to(&format!(
                        "{}?error={}",
                        return_url,
                        urlencoding::encode(&format!("Failed to create session: {}", e))
                    )));
                }

                if let Err(e) = process_pending_invite(&state, &session, user.id).await {
                    tracing::error!(
                        "Failed to process pending invite during registration: {}",
                        e
                    );
                    // Don't fail registration, just log the error
                }

                // Clear session data
                let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;
                let _ = session.remove::<bool>("oidc_is_linking").await;
                let _ = session.remove::<String>("oidc_return_url").await;

                Ok(Redirect::to(&return_url))
            }
            Err(e) => {
                tracing::error!("Failed to login/register via OIDC: {}", e);
                Err(Redirect::to(&format!(
                    "{}?error={}",
                    return_url,
                    urlencoding::encode(&format!("Failed to authenticate: {}", e))
                )))
            }
        }
    }
}

async fn unlink_oidc_account(
    State(state): State<Arc<AppState>>,
    session: Session,
) -> ApiResult<Json<ApiResponse<User>>> {
    let oidc_service = state
        .services
        .oidc_service
        .as_ref()
        .ok_or_else(|| ApiError::internal_error("OIDC not configured"))?;

    let user_id: Uuid = session
        .get("user_id")
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to read session: {}", e)))?
        .ok_or_else(|| ApiError::unauthorized("Not authenticated".to_string()))?;

    let updated_user = oidc_service
        .unlink_from_user(&user_id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to unlink OIDC: {}", e)))?;

    Ok(Json(ApiResponse::success(updated_user)))
}
