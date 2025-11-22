use crate::server::{
    api_keys,
    auth::{
        r#impl::api::{
            ForgotPasswordRequest, LoginRequest, OidcAuthorizeParams, OidcCallbackParams,
            RegisterRequest, ResetPasswordRequest, UpdateEmailPasswordRequest,
        },
        middleware::AuthenticatedUser,
        oidc::OidcPendingAuth,
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
    extract::{ConnectInfo, Query, State},
    response::{Json, Redirect},
    routing::{get, post},
};
use axum_extra::{TypedHeader, headers::UserAgent};
use std::{net::SocketAddr, sync::Arc};
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
        .route("/forgot-password", post(forgot_password))
        .route("/reset-password", post(reset_password))
}

async fn register(
    State(state): State<Arc<AppState>>,
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
    user_agent: Option<TypedHeader<UserAgent>>,
    session: Session,
    Json(request): Json<RegisterRequest>,
) -> ApiResult<Json<ApiResponse<User>>> {
    if state.config.disable_registration {
        return Err(ApiError::forbidden("User registration is disabled"));
    }

    let ip = addr.ip();
    let user_agent = user_agent.map(|u| u.to_string());

    let (org_id, permissions) = match process_pending_invite(&state, &session).await {
        Ok(Some((org_id, permissions))) => (Some(org_id), Some(permissions)),
        Ok(_) => (None, None),
        Err(e) => {
            return Err(ApiError::internal_error(&format!(
                "Failed to process invite: {}",
                e
            )));
        }
    };

    let user = state
        .services
        .auth_service
        .register(request, org_id, permissions, ip, user_agent)
        .await?;

    session
        .insert("user_id", user.id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;

    Ok(Json(ApiResponse::success(user)))
}

async fn login(
    State(state): State<Arc<AppState>>,
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
    user_agent: Option<TypedHeader<UserAgent>>,
    session: Session,
    Json(request): Json<LoginRequest>,
) -> ApiResult<Json<ApiResponse<User>>> {
    let ip = addr.ip();
    let user_agent = user_agent.map(|u| u.to_string());

    let user = state
        .services
        .auth_service
        .login(request, ip, user_agent)
        .await?;

    session
        .insert("user_id", user.id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;

    Ok(Json(ApiResponse::success(user)))
}

async fn logout(
    State(state): State<Arc<AppState>>,
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
    user_agent: Option<TypedHeader<UserAgent>>,
    session: Session,
) -> ApiResult<Json<ApiResponse<()>>> {
    if let Ok(Some(user_id)) = session.get::<Uuid>("user_id").await {
        let ip = addr.ip();
        let user_agent = user_agent.map(|u| u.to_string());

        state
            .services
            .auth_service
            .logout(user_id, ip, user_agent)
            .await?;
    }

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
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
    user_agent: Option<TypedHeader<UserAgent>>,
    auth_user: AuthenticatedUser,
    Json(request): Json<UpdateEmailPasswordRequest>,
) -> ApiResult<Json<ApiResponse<User>>> {
    let user_id: Uuid = session
        .get("user_id")
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to read session: {}", e)))?
        .ok_or_else(|| ApiError::unauthorized("Not authenticated".to_string()))?;

    let ip = addr.ip();
    let user_agent = user_agent.map(|u| u.to_string());

    let user = state
        .services
        .auth_service
        .update_password(
            user_id,
            request.password,
            request.email,
            ip,
            user_agent,
            auth_user,
        )
        .await?;

    Ok(Json(ApiResponse::success(user)))
}

async fn forgot_password(
    State(state): State<Arc<AppState>>,
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
    user_agent: Option<TypedHeader<UserAgent>>,
    Json(request): Json<ForgotPasswordRequest>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let ip = addr.ip();
    let user_agent = user_agent.map(|u| u.to_string());

    state
        .services
        .auth_service
        .initiate_password_reset(
            &request.email,
            state.config.public_url.clone(),
            ip,
            user_agent,
        )
        .await?;

    Ok(Json(ApiResponse::success(())))
}

async fn reset_password(
    State(state): State<Arc<AppState>>,
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
    user_agent: Option<TypedHeader<UserAgent>>,
    session: Session,
    Json(request): Json<ResetPasswordRequest>,
) -> ApiResult<Json<ApiResponse<User>>> {
    let ip = addr.ip();
    let user_agent = user_agent.map(|u| u.to_string());

    let user = state
        .services
        .auth_service
        .complete_password_reset(&request.token, &request.password, ip, user_agent)
        .await?;

    session
        .insert("user_id", user.id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;

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

    Ok(Redirect::to(&auth_url))
}

async fn oidc_callback(
    State(state): State<Arc<AppState>>,
    session: Session,
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
    user_agent: Option<TypedHeader<UserAgent>>,
    Query(params): Query<OidcCallbackParams>,
) -> Result<Redirect, Redirect> {
    let ip = addr.ip();
    let user_agent = user_agent.map(|u| u.to_string());

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
            .link_to_user(&user_id, &params.code, pending_auth, ip, user_agent)
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
        let (org_id, permissions) = match process_pending_invite(&state, &session).await {
            Ok(Some((org_id, permissions))) => (Some(org_id), Some(permissions)),
            Ok(_) => (None, None),
            Err(e) => {
                return Err(Redirect::to(&format!(
                    "{}?error={}",
                    return_url,
                    urlencoding::encode(&format!("Failed to process invite: {}", e))
                )));
            }
        };

        match oidc_service
            .login_or_register(
                &params.code,
                pending_auth,
                org_id,
                permissions,
                ip,
                user_agent,
            )
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
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
    user_agent: Option<TypedHeader<UserAgent>>,
) -> ApiResult<Json<ApiResponse<User>>> {
    let ip = addr.ip();
    let user_agent = user_agent.map(|u| u.to_string());

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
        .unlink_from_user(&user_id, ip, user_agent)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to unlink OIDC: {}", e)))?;

    Ok(Json(ApiResponse::success(updated_user)))
}
