use crate::server::{
    api_keys,
    auth::{
        r#impl::{
            api::{
                ForgotPasswordRequest, LoginRequest, OidcAuthorizeParams, OidcCallbackParams,
                RegisterRequest, ResetPasswordRequest, UpdateEmailPasswordRequest,
            },
            base::LoginRegisterParams,
            oidc::{OidcFlow, OidcPendingAuth, OidcProviderMetadata},
        },
        middleware::AuthenticatedUser,
        oidc::OidcService,
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
    extract::{Path, Query, State},
    response::{Json, Redirect},
    routing::{get, post},
};
use axum_client_ip::ClientIp;
use axum_extra::{TypedHeader, headers::UserAgent};
use bad_email::is_email_unwanted;
use std::{net::IpAddr, sync::Arc};
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
        .route("/oidc/providers", get(list_oidc_providers))
        .route("/oidc/{slug}/authorize", get(oidc_authorize))
        .route("/oidc/{slug}/callback", get(oidc_callback))
        .route("/oidc/{slug}/unlink", post(unlink_oidc_account))
        .route("/forgot-password", post(forgot_password))
        .route("/reset-password", post(reset_password))
}

async fn register(
    State(state): State<Arc<AppState>>,
    ClientIp(ip): ClientIp,
    user_agent: Option<TypedHeader<UserAgent>>,
    session: Session,
    Json(request): Json<RegisterRequest>,
) -> ApiResult<Json<ApiResponse<User>>> {
    if state.config.disable_registration {
        return Err(ApiError::forbidden("User registration is disabled"));
    }

    if is_email_unwanted(request.email.as_str()) {
        return Err(ApiError::conflict(
            "Email address uses a disposable domain. Please register with a non-disposable email address.",
        ));
    }

    let subscribed = request.subscribed;

    let user_agent = user_agent.map(|u| u.to_string());

    let (org_id, permissions, network_ids) = match process_pending_invite(&state, &session).await {
        Ok(Some((org_id, permissions, network_ids))) => {
            (Some(org_id), Some(permissions), network_ids)
        }
        Ok(_) => (None, None, vec![]),
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
        .register(
            request,
            LoginRegisterParams {
                org_id,
                permissions,
                ip,
                user_agent,
                network_ids,
                subscribed,
            },
        )
        .await?;

    session
        .insert("user_id", user.id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;

    Ok(Json(ApiResponse::success(user)))
}

async fn login(
    State(state): State<Arc<AppState>>,
    ClientIp(ip): ClientIp,
    user_agent: Option<TypedHeader<UserAgent>>,
    session: Session,
    Json(request): Json<LoginRequest>,
) -> ApiResult<Json<ApiResponse<User>>> {
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
    ClientIp(ip): ClientIp,
    user_agent: Option<TypedHeader<UserAgent>>,
    session: Session,
) -> ApiResult<Json<ApiResponse<()>>> {
    if let Ok(Some(user_id)) = session.get::<Uuid>("user_id").await {
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
    ClientIp(ip): ClientIp,
    user_agent: Option<TypedHeader<UserAgent>>,
    auth_user: AuthenticatedUser,
    Json(request): Json<UpdateEmailPasswordRequest>,
) -> ApiResult<Json<ApiResponse<User>>> {
    let user_id: Uuid = session
        .get("user_id")
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to read session: {}", e)))?
        .ok_or_else(|| ApiError::unauthorized("Not authenticated".to_string()))?;

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
    ClientIp(ip): ClientIp,
    user_agent: Option<TypedHeader<UserAgent>>,
    Json(request): Json<ForgotPasswordRequest>,
) -> ApiResult<Json<ApiResponse<()>>> {
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
    ClientIp(ip): ClientIp,
    user_agent: Option<TypedHeader<UserAgent>>,
    session: Session,
    Json(request): Json<ResetPasswordRequest>,
) -> ApiResult<Json<ApiResponse<User>>> {
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

async fn list_oidc_providers(
    State(state): State<Arc<AppState>>,
) -> ApiResult<Json<ApiResponse<Vec<OidcProviderMetadata>>>> {
    let oidc_service = state
        .services
        .oidc_service
        .as_ref()
        .ok_or_else(|| ApiError::internal_error("OIDC not configured"))?;

    Ok(Json(ApiResponse::success(oidc_service.list_providers())))
}

async fn oidc_authorize(
    State(state): State<Arc<AppState>>,
    Path(slug): Path<String>,
    session: Session,
    Query(params): Query<OidcAuthorizeParams>,
) -> ApiResult<Redirect> {
    let oidc_service = state
        .services
        .oidc_service
        .as_ref()
        .ok_or_else(|| ApiError::internal_error("OIDC not configured"))?;

    // Verify provider exists
    let provider = oidc_service
        .get_provider(&slug)
        .ok_or_else(|| ApiError::not_found(format!("OIDC provider '{}' not found", slug)))?;

    // Parse and validate flow parameter
    let flow = match params.flow.as_deref() {
        Some("login") => OidcFlow::Login,
        Some("register") => OidcFlow::Register,
        Some("link") => OidcFlow::Link,
        Some(other) => {
            return Err(ApiError::bad_request(&format!(
                "Invalid flow '{}'. Must be 'login', 'register', or 'link'",
                other
            )));
        }
        None => {
            return Err(ApiError::bad_request(
                "flow parameter is required (login, register, or link)",
            ));
        }
    };

    // Validate return_url is present
    let return_url = params
        .return_url
        .ok_or_else(|| ApiError::bad_request("return_url parameter is required"))?;

    // Generate authorization URL using provider
    let (auth_url, pending_auth) = provider
        .authorize_url(flow)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to generate auth URL: {}", e)))?;

    // Store OIDC flow state in session
    session
        .insert("oidc_pending_auth", pending_auth)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save pending auth: {}", e)))?;

    session
        .insert("oidc_provider_slug", slug)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save provider slug: {}", e)))?;

    session
        .insert("oidc_return_url", return_url)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save return URL: {}", e)))?;

    // Store subscribed flag if present
    if let Some(subscribed) = params.subscribed {
        session
            .insert("oidc_subscribed", subscribed)
            .await
            .map_err(|e| ApiError::internal_error(&format!("Failed to save subscribed: {}", e)))?;
    }

    Ok(Redirect::to(&auth_url))
}

async fn oidc_callback(
    State(state): State<Arc<AppState>>,
    Path(slug): Path<String>,
    session: Session,
    ClientIp(ip): ClientIp,
    user_agent: Option<TypedHeader<UserAgent>>,
    Query(params): Query<OidcCallbackParams>,
) -> Result<Redirect, Redirect> {
    let user_agent = user_agent.map(|u| u.to_string());

    // Verify OIDC is configured
    let oidc_service = match state.services.oidc_service.as_ref() {
        Some(service) => service,
        None => {
            return Err(Redirect::to(&format!(
                "/error?message={}",
                urlencoding::encode("OIDC is not configured on this server")
            )));
        }
    };

    // Verify provider exists
    if oidc_service.get_provider(&slug).is_none() {
        return Err(Redirect::to(&format!(
            "/error?message={}",
            urlencoding::encode(&format!("OIDC provider '{}' not found", slug))
        )));
    }

    // Extract and validate session data
    let return_url: String = session
        .get("oidc_return_url")
        .await
        .ok()
        .flatten()
        .ok_or_else(|| {
            Redirect::to(&format!(
                "/error?message={}",
                urlencoding::encode("Session error: No return URL found")
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

    let session_slug: String = session
        .get("oidc_provider_slug")
        .await
        .ok()
        .flatten()
        .ok_or_else(|| {
            Redirect::to(&format!(
                "{}?error={}",
                return_url,
                urlencoding::encode("Session error: No provider slug found")
            ))
        })?;

    // Verify provider slug matches
    if session_slug != slug {
        return Err(Redirect::to(&format!(
            "{}?error={}",
            return_url,
            urlencoding::encode("Provider mismatch in callback")
        )));
    }

    // Verify CSRF token
    if pending_auth.csrf_token != params.state {
        return Err(Redirect::to(&format!(
            "{}?error={}",
            return_url,
            urlencoding::encode("Invalid security token. Please try again.")
        )));
    }

    // Get subscribed flag from session
    let subscribed: bool = session
        .get("oidc_subscribed")
        .await
        .ok()
        .flatten()
        .unwrap_or(false);

    // Parse return URL for error handling
    let return_url_parsed = Url::parse(&return_url).map_err(|_| {
        Redirect::to(&format!(
            "/error?message={}",
            urlencoding::encode("Invalid return URL")
        ))
    })?;

    // Handle different flows
    match pending_auth.flow {
        OidcFlow::Link => {
            handle_link_flow(HandleLinkFlowParams {
                oidc_service,
                slug: &slug,
                code: &params.code,
                pending_auth,
                ip,
                user_agent,
                session,
                return_url: return_url_parsed,
            })
            .await
        }
        OidcFlow::Login => {
            handle_login_flow(HandleLinkFlowParams {
                oidc_service,
                slug: &slug,
                code: &params.code,
                pending_auth,
                ip,
                user_agent,
                session,
                return_url: return_url_parsed,
            })
            .await
        }
        OidcFlow::Register => {
            handle_register_flow(
                state.clone(),
                subscribed,
                HandleLinkFlowParams {
                    oidc_service,
                    slug: &slug,
                    code: &params.code,
                    pending_auth,
                    ip,
                    user_agent,
                    session,
                    return_url: return_url_parsed,
                },
            )
            .await
        }
    }
}

struct HandleLinkFlowParams<'a> {
    oidc_service: &'a OidcService,
    slug: &'a str,
    code: &'a str,
    pending_auth: OidcPendingAuth,
    ip: IpAddr,
    user_agent: Option<String>,
    session: Session,
    return_url: Url,
}

async fn handle_link_flow(params: HandleLinkFlowParams<'_>) -> Result<Redirect, Redirect> {
    let HandleLinkFlowParams {
        oidc_service,
        slug,
        code,
        pending_auth,
        ip,
        user_agent,
        session,
        mut return_url,
    } = params;

    // Add auth_modal query param to return URL
    return_url
        .query_pairs_mut()
        .append_pair("auth_modal", "true");

    // Verify user is logged in
    let user_id: Uuid = session.get("user_id").await.ok().flatten().ok_or_else(|| {
        let mut url = return_url.clone();
        url.query_pairs_mut()
            .append_pair("error", "You must be logged in to link an OIDC account.");
        Redirect::to(url.as_str())
    })?;

    // Link OIDC account to user
    match oidc_service
        .link_to_user(slug, &user_id, code, pending_auth, ip, user_agent)
        .await
    {
        Ok(_) => {
            // Clear session data
            let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;
            let _ = session.remove::<String>("oidc_provider_slug").await;
            let _ = session.remove::<String>("oidc_return_url").await;
            let _ = session.remove::<bool>("oidc_subscribed").await;

            Ok(Redirect::to(return_url.as_str()))
        }
        Err(e) => {
            tracing::error!("Failed to link OIDC: {}", e);

            // Clear session data
            let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;
            let _ = session.remove::<String>("oidc_provider_slug").await;
            let _ = session.remove::<String>("oidc_return_url").await;
            let _ = session.remove::<bool>("oidc_subscribed").await;

            return_url
                .query_pairs_mut()
                .append_pair("error", &format!("Failed to link OIDC account: {}", e));
            Err(Redirect::to(return_url.as_str()))
        }
    }
}

async fn handle_login_flow(params: HandleLinkFlowParams<'_>) -> Result<Redirect, Redirect> {
    let HandleLinkFlowParams {
        oidc_service,
        slug,
        code,
        pending_auth,
        ip,
        user_agent,
        session,
        return_url,
    } = params;

    // Login user
    match oidc_service
        .login(slug, code, pending_auth, ip, user_agent)
        .await
    {
        Ok(user) => {
            // Save user_id to session
            if let Err(e) = session.insert("user_id", user.id).await {
                tracing::error!("Failed to save session: {}", e);
                return Err(Redirect::to(&format!(
                    "{}?error={}",
                    return_url,
                    urlencoding::encode(&format!("Failed to create session: {}", e))
                )));
            }

            // Clear OIDC session data
            let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;
            let _ = session.remove::<String>("oidc_provider_slug").await;
            let _ = session.remove::<String>("oidc_return_url").await;
            let _ = session.remove::<bool>("oidc_subscribed").await;

            Ok(Redirect::to(return_url.as_str()))
        }
        Err(e) => {
            tracing::error!("Failed to login via OIDC: {}", e);
            Err(Redirect::to(&format!(
                "{}?error={}",
                return_url,
                urlencoding::encode(&format!("Failed to login: {}", e))
            )))
        }
    }
}

async fn handle_register_flow(
    state: Arc<AppState>,
    subscribed: bool,
    params: HandleLinkFlowParams<'_>,
) -> Result<Redirect, Redirect> {
    let HandleLinkFlowParams {
        oidc_service,
        slug,
        code,
        pending_auth,
        ip,
        user_agent,
        session,
        return_url,
    } = params;

    // Process pending invite if present
    let (org_id, permissions, network_ids) = match process_pending_invite(&state, &session).await {
        Ok(Some((org_id, permissions, network_ids))) => {
            (Some(org_id), Some(permissions), network_ids)
        }
        Ok(_) => (None, None, vec![]),
        Err(e) => {
            return Err(Redirect::to(&format!(
                "{}?error={}",
                return_url,
                urlencoding::encode(&format!("Failed to process invite: {}", e))
            )));
        }
    };

    // Register user
    match oidc_service
        .register(
            slug,
            code,
            pending_auth,
            LoginRegisterParams {
                org_id,
                permissions,
                ip,
                user_agent,
                network_ids,
                subscribed,
            },
        )
        .await
    {
        Ok(user) => {
            // Save user_id to session
            if let Err(e) = session.insert("user_id", user.id).await {
                tracing::error!("Failed to save session: {}", e);
                return Err(Redirect::to(&format!(
                    "{}?error={}",
                    return_url,
                    urlencoding::encode(&format!("Failed to create session: {}", e))
                )));
            }

            // Clear OIDC session data
            let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;
            let _ = session.remove::<String>("oidc_provider_slug").await;
            let _ = session.remove::<String>("oidc_return_url").await;
            let _ = session.remove::<bool>("oidc_subscribed").await;

            Ok(Redirect::to(return_url.as_str()))
        }
        Err(e) => {
            tracing::error!("Failed to register via OIDC: {}", e);
            Err(Redirect::to(&format!(
                "{}?error={}",
                return_url,
                urlencoding::encode(&format!("Failed to register: {}", e))
            )))
        }
    }
}

async fn unlink_oidc_account(
    State(state): State<Arc<AppState>>,
    Path(slug): Path<String>,
    session: Session,
    ClientIp(ip): ClientIp,
    user_agent: Option<TypedHeader<UserAgent>>,
) -> ApiResult<Json<ApiResponse<User>>> {
    let user_agent = user_agent.map(|u| u.to_string());

    let oidc_service = state
        .services
        .oidc_service
        .as_ref()
        .ok_or_else(|| ApiError::internal_error("OIDC not configured"))?;

    // Verify provider exists
    if oidc_service.get_provider(&slug).is_none() {
        return Err(ApiError::not_found(format!(
            "OIDC provider '{}' not found",
            slug
        )));
    }

    // Get user_id from session
    let user_id: Uuid = session
        .get("user_id")
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to read session: {}", e)))?
        .ok_or_else(|| ApiError::unauthorized("Not authenticated".to_string()))?;

    // Unlink OIDC account
    let updated_user = oidc_service
        .unlink_from_user(&slug, &user_id, ip, user_agent)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to unlink OIDC: {}", e)))?;

    Ok(Json(ApiResponse::success(updated_user)))
}
