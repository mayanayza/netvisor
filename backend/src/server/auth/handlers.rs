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
    shared::{
        services::traits::CrudService,
        storage::filter::EntityFilter,
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
use email_address::EmailAddress;
use std::{str::FromStr, sync::Arc};
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
    let oidc_client = state
        .oidc_client
        .as_ref()
        .ok_or_else(|| ApiError::internal_error("OIDC not configured"))?;

    let (auth_url, pending_auth) = oidc_client
        .authorize_url()
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to generate auth URL: {}", e)))?;

    // Store whether this is a link operation
    let is_linking = params.link.unwrap_or(false);

    session
        .insert("oidc_pending_auth", pending_auth)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;

    session
        .insert("oidc_is_linking", is_linking)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;

    // Get return URL from params or error if not provided
    let return_url = params
        .return_url
        .ok_or_else(|| ApiError::bad_request("return_url parameter is required"))?;

    session
        .insert("oidc_return_url", return_url)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;

    Ok(Redirect::to(&auth_url))
}

async fn oidc_callback(
    State(state): State<Arc<AppState>>,
    session: Session,
    Query(params): Query<OidcCallbackParams>,
) -> Result<Redirect, Redirect> {
    // Get return URL from session
    let return_url: String = match session.get("oidc_return_url").await {
        Ok(Some(url)) => url,
        _ => {
            // No return URL in session - redirect to error page
            return Err(Redirect::to(&format!(
                "/error?message={}",
                urlencoding::encode(
                    "Session error: Unable to determine return URL. Please try logging in again."
                )
            )));
        }
    };

    let oidc_client = match state.oidc_client.as_ref() {
        Some(client) => client,
        None => {
            return Err(Redirect::to(&format!(
                "{}?error={}",
                return_url,
                urlencoding::encode("OIDC is not configured on this server")
            )));
        }
    };

    // Retrieve pending auth from session
    let pending_auth: OidcPendingAuth = match session.get("oidc_pending_auth").await {
        Ok(Some(auth)) => auth,
        _ => {
            return Err(Redirect::to(&format!(
                "{}?error={}",
                return_url,
                urlencoding::encode("No pending authentication found. Please try again.")
            )));
        }
    };

    // Verify CSRF token
    if pending_auth.csrf_token != params.state {
        return Err(Redirect::to(&format!(
            "{}?error={}",
            return_url,
            urlencoding::encode("Invalid security token. Please try again.")
        )));
    }

    // Exchange code for user info
    let user_info = match oidc_client.exchange_code(&params.code, pending_auth).await {
        Ok(info) => info,
        Err(e) => {
            tracing::error!("Failed to exchange OIDC code: {}", e);
            return Err(Redirect::to(&format!(
                "{}?error={}",
                return_url,
                urlencoding::encode(&format!(
                    "Failed to authenticate with OIDC provider. Please try again. Error: {}",
                    e
                ))
            )));
        }
    };

    // Check if this is a link operation
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
        // Add auth_modal parameter
        return_url_parsed
            .query_pairs_mut()
            .append_pair("auth_modal", "true");

        // LINK FLOW
        let user_id: Uuid = match session.get("user_id").await {
            Ok(Some(id)) => id,
            _ => {
                return_url_parsed
                    .query_pairs_mut()
                    .append_pair("error", "You must be logged in to link an OIDC account.");
                return Err(Redirect::to(return_url_parsed.as_str()));
            }
        };

        // Check if this OIDC account is already linked to another user
        if let Ok(Some(existing_user)) = state
            .services
            .user_service
            .get_user_by_oidc(&user_info.subject)
            .await
        {
            if existing_user.id != user_id {
                // Clear session data
                let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;
                let _ = session.remove::<bool>("oidc_is_linking").await;
                let _ = session.remove::<String>("oidc_return_url").await;

                return_url_parsed.query_pairs_mut().append_pair("error", "This OIDC account is already linked to another user. Please unlink it first or use a different account.");
                return Err(Redirect::to(return_url_parsed.as_str()));
            }
        } else {
            // Link OIDC to current user
            if let Err(e) = state
                .services
                .user_service
                .link_oidc(
                    &user_id,
                    user_info.subject,
                    state.config.oidc_provider_name.clone(),
                )
                .await
            {
                tracing::error!("Failed to link OIDC: {}", e);
                let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;
                let _ = session.remove::<bool>("oidc_is_linking").await;
                let _ = session.remove::<String>("oidc_return_url").await;

                return_url_parsed.query_pairs_mut().append_pair(
                    "error",
                    &format!(
                        "Failed to link OIDC account. Please try again. Error: {}",
                        e
                    ),
                );
                return Err(Redirect::to(return_url_parsed.as_str()));
            }
        }

        // Clear pending auth
        let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;
        let _ = session.remove::<bool>("oidc_is_linking").await;
        let _ = session.remove::<String>("oidc_return_url").await;

        Ok(Redirect::to(return_url_parsed.as_str()))
    } else {
        // LOGIN FLOW
        let existing_user = match state
            .services
            .user_service
            .get_user_by_oidc(&user_info.subject)
            .await
        {
            Ok(user) => user,
            Err(e) => {
                tracing::error!("Failed to query user: {}", e);
                return Err(Redirect::to(&format!(
                    "{}?error={}",
                    return_url,
                    urlencoding::encode(&format!(
                        "Failed to process authentication. Please try again. Error: {}",
                        e
                    ))
                )));
            }
        };

        if let Some(user) = existing_user {
            // User exists - log them in
            if let Err(e) = session.insert("user_id", user.id).await {
                tracing::error!("Failed to save session: {}", e);
                return Err(Redirect::to(&format!(
                    "{}?error={}",
                    return_url,
                    urlencoding::encode(&format!(
                        "Failed to create session. Please try again. Error: {}",
                        e
                    ))
                )));
            }
        } else {
            // Check for seed user and create new user
            let all_users = match state
                .services
                .user_service
                .get_all(EntityFilter::unfiltered())
                .await
            {
                Ok(users) => users,
                Err(e) => {
                    tracing::error!("Failed to get users: {}", e);
                    return Err(Redirect::to(&format!(
                        "{}?error={}",
                        return_url,
                        urlencoding::encode(&format!(
                            "Failed to process authentication. Please try again. Error: {}",
                            e
                        ))
                    )));
                }
            };

            let seed_user: Option<User> = all_users
                .iter()
                .find(|u| u.base.password_hash.is_none() && u.base.oidc_subject.is_none())
                .cloned();

            let fallback_email_str = format!("user{}@example.com", &user_info.subject[..8]);

            let email_str = user_info
                .email
                .clone()
                .unwrap_or_else(|| fallback_email_str.clone());

            let email = EmailAddress::from_str(&email_str)
                .or_else(|_| Ok(EmailAddress::new_unchecked(fallback_email_str)))?;

            let new_user = if let Some(mut seed_user) = seed_user {
                tracing::info!("First user (OIDC) - claiming seed user");

                seed_user.base.email = email;
                seed_user.base.oidc_subject = Some(user_info.subject.clone());
                seed_user.base.oidc_provider = state.config.oidc_provider_name.clone();
                seed_user.base.oidc_linked_at = Some(chrono::Utc::now());

                match state.services.user_service.update(&mut seed_user).await {
                    Ok(user) => user,
                    Err(e) => {
                        tracing::error!("Failed to update seed user: {}", e);
                        return Err(Redirect::to(&format!(
                            "{}?error={}",
                            return_url,
                            urlencoding::encode(&format!(
                                "Failed to create user account. Please try again. Error: {}",
                                e
                            ))
                        )));
                    }
                }
            } else {
                match state
                    .services
                    .user_service
                    .create_user_with_oidc(
                        email,
                        user_info.subject.clone(),
                        state.config.oidc_provider_name.clone(),
                    )
                    .await
                {
                    Ok(user) => user,
                    Err(e) => {
                        tracing::error!("Failed to create user: {}", e);
                        return Err(Redirect::to(&format!(
                            "{}?error={}",
                            return_url,
                            urlencoding::encode(&format!(
                                "Failed to create user account. Please try again. Error: {}",
                                e
                            ))
                        )));
                    }
                }
            };

            if let Err(e) = session.insert("user_id", new_user.id).await {
                tracing::error!("Failed to save session: {}", e);
                return Err(Redirect::to(&format!(
                    "{}?error={}",
                    return_url,
                    urlencoding::encode(&format!(
                        "Failed to create session. Please try again. Error: {}",
                        e
                    ))
                )));
            }
        }

        // Clear pending auth
        let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;
        let _ = session.remove::<bool>("oidc_is_linking").await;
        let _ = session.remove::<String>("oidc_return_url").await;

        Ok(Redirect::to(&return_url))
    }
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
