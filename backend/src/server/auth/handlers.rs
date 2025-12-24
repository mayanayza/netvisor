use crate::server::{
    api_keys::{
        r#impl::base::{ApiKey, ApiKeyBase},
        service::generate_api_key_for_storage,
    },
    auth::{
        r#impl::{
            api::{
                DaemonSetupRequest, DaemonSetupResponse, ForgotPasswordRequest, LoginRequest,
                OidcAuthorizeParams, OidcCallbackParams, RegisterRequest, ResetPasswordRequest,
                SetupRequest, SetupResponse, UpdateEmailPasswordRequest,
            },
            base::{LoginRegisterParams, PendingDaemonSetup, PendingNetworkSetup, PendingSetup},
            oidc::{OidcFlow, OidcPendingAuth, OidcProviderMetadata, OidcRegisterParams},
        },
        middleware::{
            auth::{AuthenticatedEntity, AuthenticatedUser},
            features::{BlockedInDemoMode, RequireFeature},
        },
        oidc::OidcService,
    },
    config::AppState,
    invites::handlers::process_pending_invite,
    networks::r#impl::{Network, NetworkBase},
    shared::{
        events::types::{TelemetryEvent, TelemetryOperation},
        services::traits::CrudService,
        storage::traits::StorableEntity,
        types::api::{ApiError, ApiResponse, ApiResult},
    },
    topology::types::base::{Topology, TopologyBase},
    users::r#impl::base::User,
};
use axum::{
    Router,
    extract::{Path, Query, State},
    response::{Json, Redirect},
    routing::{get, post},
};
use axum_client_ip::ClientIp;
use axum_extra::{TypedHeader, extract::Host, headers::UserAgent};
use bad_email::is_email_unwanted;
use chrono::{DateTime, Utc};
use std::{net::IpAddr, sync::Arc};
use tower_sessions::Session;
use url::Url;
use uuid::Uuid;

pub const DEMO_HOST: &str = "demo.scanopy.net";

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/register", post(register))
        .route("/login", post(login))
        .route("/logout", post(logout))
        .route("/me", post(get_current_user))
        // Note: /keys routes are handled separately via OpenApiRouter in factory.rs
        .route("/update", post(update_password_auth))
        .route("/setup", post(setup))
        .route("/daemon-setup", post(daemon_setup))
        .route("/oidc/providers", get(list_oidc_providers))
        .route("/oidc/{slug}/authorize", get(oidc_authorize))
        .route("/oidc/{slug}/callback", get(oidc_callback))
        .route("/oidc/{slug}/unlink", post(unlink_oidc_account))
        .route("/forgot-password", post(forgot_password))
        .route("/reset-password", post(reset_password))
}

async fn register(
    State(state): State<Arc<AppState>>,
    Host(host): Host,
    ClientIp(ip): ClientIp,
    user_agent: Option<TypedHeader<UserAgent>>,
    session: Session,
    Json(request): Json<RegisterRequest>,
) -> ApiResult<Json<ApiResponse<User>>> {
    // Block registration on demo domain
    if host == DEMO_HOST {
        return Err(ApiError::forbidden(
            "Account creation is disabled on the demo site",
        ));
    }

    if state.config.disable_registration {
        return Err(ApiError::forbidden("User registration is disabled"));
    }

    let billing_enabled = state.config.stripe_secret.is_some();

    if billing_enabled && !request.terms_accepted {
        return Err(ApiError::bad_request(
            "Please accept terms and conditions to proceed",
        ));
    }

    if is_email_unwanted(request.email.as_str()) && request.email.domain() != "gmx.net" {
        return Err(ApiError::conflict(
            "Email address uses a disposable domain. Please register with a non-disposable email address.",
        ));
    }

    let user_agent = user_agent.map(|u| u.to_string());

    // Check for pending invite
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

    // Track if this is a new org (not an invite)
    let is_new_org = org_id.is_none();

    // Extract pending setup from session (only relevant for new orgs)
    let pending_setup = if is_new_org {
        extract_pending_setup(&session).await
    } else {
        None
    };

    // Extract pending daemon setups from session (supports multiple daemons)
    let pending_daemon_setups = if is_new_org {
        extract_pending_daemon_setups(&session).await
    } else {
        vec![]
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
            },
            pending_setup.clone(),
            billing_enabled,
        )
        .await?;

    session
        .insert("user_id", user.id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save session: {}", e)))?;

    // If this is a new org and setup was provided, create network/topology/daemon
    if is_new_org && let Some(setup) = pending_setup {
        // Apply setup: create networks, seed data, topologies, daemons
        apply_pending_setup(&state, &user, setup, pending_daemon_setups).await?;

        // Clear pending setup data from session
        clear_pending_setup(&session).await;
    }

    Ok(Json(ApiResponse::success(user)))
}

/// Store pre-registration setup data (org name, networks, seed preference) in session
async fn setup(
    session: Session,
    Json(request): Json<SetupRequest>,
) -> ApiResult<Json<ApiResponse<SetupResponse>>> {
    // Validate request
    if request.organization_name.trim().is_empty() {
        return Err(ApiError::bad_request("Organization name is required"));
    }
    if request.organization_name.len() > 100 {
        return Err(ApiError::bad_request(
            "Organization name must be 100 characters or less",
        ));
    }
    if request.networks.is_empty() {
        return Err(ApiError::bad_request("At least one network is required"));
    }

    // Validate and build network list with generated IDs
    let mut networks: Vec<PendingNetworkSetup> = Vec::with_capacity(request.networks.len());
    for network in &request.networks {
        let name = network.name.trim();
        if name.is_empty() {
            return Err(ApiError::bad_request("Network name cannot be empty"));
        }
        if name.len() > 100 {
            return Err(ApiError::bad_request(
                "Network name must be 100 characters or less",
            ));
        }
        networks.push(PendingNetworkSetup {
            name: name.to_string(),
            network_id: Uuid::new_v4(),
        });
    }

    let network_ids: Vec<Uuid> = networks.iter().map(|n| n.network_id).collect();

    // Store setup data in session
    let pending_setup = PendingSetup {
        org_name: request.organization_name.trim().to_string(),
        networks,
        seed_data: request.populate_seed_data,
    };

    session
        .insert("pending_setup", pending_setup)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to save setup data: {}", e)))?;

    Ok(Json(ApiResponse::success(SetupResponse { network_ids })))
}

/// Store pre-registration daemon setup data in session and generate provisional API key
/// Supports multiple calls to configure daemons for different networks
async fn daemon_setup(
    session: Session,
    Json(request): Json<DaemonSetupRequest>,
) -> ApiResult<Json<ApiResponse<DaemonSetupResponse>>> {
    // Validate request
    if request.daemon_name.trim().is_empty() {
        return Err(ApiError::bad_request("Daemon name is required"));
    }

    // Generate API key only if not installing later
    let api_key_raw = if request.install_later {
        None
    } else {
        let (raw_key, _) = crate::server::api_keys::service::generate_api_key_for_storage();
        Some(raw_key)
    };

    // Create new daemon setup entry
    let new_daemon_setup = PendingDaemonSetup {
        daemon_name: request.daemon_name.trim().to_string(),
        network_id: request.network_id,
        api_key_raw: api_key_raw.clone(),
    };

    // Get existing daemon setups from session or start with empty vec
    let mut daemon_setups: Vec<PendingDaemonSetup> = session
        .get("pending_daemon_setups")
        .await
        .ok()
        .flatten()
        .unwrap_or_default();

    // Remove any existing setup for the same network (allow overwriting)
    daemon_setups.retain(|d| d.network_id != request.network_id);

    // Add the new daemon setup
    daemon_setups.push(new_daemon_setup);

    // Store updated list in session
    session
        .insert("pending_daemon_setups", daemon_setups)
        .await
        .map_err(|e| {
            ApiError::internal_error(&format!("Failed to save daemon setup data: {}", e))
        })?;

    Ok(Json(ApiResponse::success(DaemonSetupResponse {
        api_key: api_key_raw,
    })))
}

/// Extract pending setup data from session
pub async fn extract_pending_setup(session: &Session) -> Option<PendingSetup> {
    session.get("pending_setup").await.ok().flatten()
}

/// Extract pending daemon setup data from session (supports multiple daemons)
pub async fn extract_pending_daemon_setups(session: &Session) -> Vec<PendingDaemonSetup> {
    session
        .get("pending_daemon_setups")
        .await
        .ok()
        .flatten()
        .unwrap_or_default()
}

/// Clear all pending setup data from session
pub async fn clear_pending_setup(session: &Session) {
    let _ = session.remove::<PendingSetup>("pending_setup").await;
    let _ = session
        .remove::<Vec<PendingDaemonSetup>>("pending_daemon_setups")
        .await;
}

/// Apply pending setup after user registration: create networks, topologies, seed data, and daemons
/// Org name, onboarding status, and billing plan are now set in provision_user
async fn apply_pending_setup(
    state: &Arc<AppState>,
    user: &User,
    setup: PendingSetup,
    daemon_setups: Vec<PendingDaemonSetup>,
) -> Result<(), ApiError> {
    let organization_id = user.base.organization_id;
    let auth_entity: AuthenticatedEntity = user.clone().into();

    // Track first network for integrated daemon and seed data
    let mut first_network_id: Option<Uuid> = None;

    // Create each network with its pre-generated ID
    for (i, pending_network) in setup.networks.iter().enumerate() {
        let mut network = Network::new(NetworkBase::new(organization_id));
        network.id = pending_network.network_id;
        network.base.name = pending_network.name.clone();

        let network = state
            .services
            .network_service
            .create(network, auth_entity.clone())
            .await
            .map_err(|e| ApiError::internal_error(&format!("Failed to create network: {}", e)))?;

        // Track the first network
        if i == 0 {
            first_network_id = Some(network.id);
        }

        // Seed default data only for the first network if requested
        if setup.seed_data {
            state
                .services
                .network_service
                .seed_default_data(network.id, auth_entity.clone())
                .await
                .map_err(|e| ApiError::internal_error(&format!("Failed to seed data: {}", e)))?;
        }

        // Create default topology for each network
        let topology = Topology::new(TopologyBase::new("My Topology".to_string(), network.id));
        state
            .services
            .topology_service
            .create(topology, auth_entity.clone())
            .await
            .map_err(|e| ApiError::internal_error(&format!("Failed to create topology: {}", e)))?;

        // Handle daemon setup for this network if present
        if let Some(daemon) = daemon_setups.iter().find(|d| d.network_id == network.id) {
            // Only create API key if user chose "Install Now" (api_key_raw is Some)
            // Note: Daemon will auto-register when it connects with the API key
            // No need to create daemon record here - it will be created on first registration
            if let Some(ref api_key_raw) = daemon.api_key_raw {
                let hashed_key = crate::server::api_keys::service::hash_api_key(api_key_raw);

                state
                    .services
                    .api_key_service
                    .create(
                        ApiKey::new(ApiKeyBase {
                            key: hashed_key,
                            name: format!("{} API Key", daemon.daemon_name),
                            last_used: None,
                            expires_at: None,
                            network_id: network.id,
                            is_enabled: true,
                            tags: Vec::new(),
                        }),
                        AuthenticatedEntity::System,
                    )
                    .await
                    .map_err(|e| {
                        ApiError::internal_error(&format!("Failed to create API key: {}", e))
                    })?;
            }
        }
    }

    // Handle integrated daemon if configured (attach to first network only)
    if let Some(integrated_daemon_url) = &state.config.integrated_daemon_url
        && let Some(network_id) = first_network_id
    {
        let (plaintext, hashed) = generate_api_key_for_storage();

        state
            .services
            .api_key_service
            .create(
                ApiKey::new(ApiKeyBase {
                    key: hashed,
                    name: "Integrated Daemon API Key".to_string(),
                    last_used: None,
                    expires_at: None,
                    network_id,
                    is_enabled: true,
                    tags: Vec::new(),
                }),
                AuthenticatedEntity::System,
            )
            .await
            .map_err(|e| {
                ApiError::internal_error(&format!("Failed to create integrated daemon key: {}", e))
            })?;

        state
            .services
            .daemon_service
            .initialize_local_daemon(integrated_daemon_url.clone(), network_id, plaintext)
            .await
            .map_err(|e| {
                ApiError::internal_error(&format!("Failed to initialize local daemon: {}", e))
            })?;
    }

    // Publish telemetry event
    state
        .services
        .event_bus
        .publish_telemetry(TelemetryEvent {
            id: Uuid::new_v4(),
            organization_id,
            operation: TelemetryOperation::OnboardingModalCompleted,
            timestamp: Utc::now(),
            authentication: auth_entity,
            metadata: serde_json::json!({
                "is_onboarding_step": true,
                "pre_registration_setup": true,
                "network_count": setup.networks.len()
            }),
        })
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to publish telemetry: {}", e)))?;

    Ok(())
}

async fn login(
    State(state): State<Arc<AppState>>,
    ClientIp(ip): ClientIp,
    Host(host): Host,
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

    // Check if user is trying to log into demo account on non-demo and visa versa
    if let Some(organization) = state
        .services
        .organization_service
        .get_by_id(&user.base.organization_id)
        .await?
        && let Some(plan) = organization.base.plan
    {
        if plan.is_demo() && host != DEMO_HOST {
            return Err(ApiError::forbidden(
                "You can't log in to the demo account on this instance.",
            ));
        } else if !plan.is_demo() && host == DEMO_HOST {
            return Err(ApiError::forbidden(
                "You can only log in to the demo account on this instance.",
            ));
        }

    // Couldn't get organization for some reason and user is on demo site - block login
    } else if host == DEMO_HOST {
        return Err(ApiError::forbidden(
            "You can only log in to the demo account on this instance.",
        ));
    }

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
    _demo_check: RequireFeature<BlockedInDemoMode>,
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
    Host(host): Host,
    Path(slug): Path<String>,
    session: Session,
    Query(params): Query<OidcAuthorizeParams>,
) -> ApiResult<Redirect> {
    let billing_enabled = state.config.stripe_secret.is_some();

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
        Some("register") => {
            // Block registration on demo domain
            if host == DEMO_HOST {
                return Err(ApiError::forbidden(
                    "Account creation is disabled on the demo site",
                ));
            }

            if state.config.disable_registration {
                return Err(ApiError::forbidden("User registration is disabled"));
            }

            let terms_accepted = params.terms_accepted.unwrap_or(false);

            if billing_enabled && !terms_accepted {
                return Err(ApiError::bad_request(
                    "Please accept terms and conditions to proceed",
                ));
            }

            OidcFlow::Register
        }
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

    // Store registration flags if present

    if let Some(terms_accepted) = params.terms_accepted {
        session
            .insert("oidc_terms_accepted", terms_accepted)
            .await
            .map_err(|e| {
                ApiError::internal_error(&format!("Failed to save terms_accepted_at: {}", e))
            })?;
    }

    Ok(Redirect::to(&auth_url))
}

async fn oidc_callback(
    State(state): State<Arc<AppState>>,
    Host(host): Host,
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
                host,
            })
            .await
        }
        OidcFlow::Login => {
            handle_login_flow(
                state.clone(),
                HandleLinkFlowParams {
                    oidc_service,
                    slug: &slug,
                    code: &params.code,
                    pending_auth,
                    ip,
                    user_agent,
                    session,
                    return_url: return_url_parsed,
                    host,
                },
            )
            .await
        }
        OidcFlow::Register => {
            // Get terms_accepted_at flag from session
            let terms_accepted: bool = session
                .get("oidc_terms_accepted")
                .await
                .ok()
                .flatten()
                .unwrap_or(false);

            let terms_accepted_at = if terms_accepted {
                Some(Utc::now())
            } else {
                None
            };

            handle_register_flow(
                state.clone(),
                terms_accepted_at,
                HandleLinkFlowParams {
                    oidc_service,
                    slug: &slug,
                    code: &params.code,
                    pending_auth,
                    ip,
                    user_agent,
                    session,
                    return_url: return_url_parsed,
                    host,
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
    host: String,
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
        host: _,
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

            Ok(Redirect::to(return_url.as_str()))
        }
        Err(e) => {
            tracing::error!("Failed to link OIDC: {}", e);

            // Clear session data
            let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;
            let _ = session.remove::<String>("oidc_provider_slug").await;
            let _ = session.remove::<String>("oidc_return_url").await;

            return_url
                .query_pairs_mut()
                .append_pair("error", &format!("Failed to link OIDC account: {}", e));
            Err(Redirect::to(return_url.as_str()))
        }
    }
}

async fn handle_login_flow(
    state: Arc<AppState>,
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
        host,
    } = params;

    // Login user
    match oidc_service
        .login(slug, code, pending_auth, ip, user_agent)
        .await
    {
        Ok(user) => {
            // Validate host matches user's org plan (same as regular login)
            if let Ok(Some(organization)) = state
                .services
                .organization_service
                .get_by_id(&user.base.organization_id)
                .await
                && let Some(plan) = organization.base.plan
            {
                if plan.is_demo() && host != DEMO_HOST {
                    return Err(Redirect::to(&format!(
                        "{}?error={}",
                        return_url,
                        urlencoding::encode(
                            "You can't log in to the demo account on this instance."
                        )
                    )));
                } else if !plan.is_demo() && host == DEMO_HOST {
                    return Err(Redirect::to(&format!(
                        "{}?error={}",
                        return_url,
                        urlencoding::encode(
                            "You can only log in to the demo account on this instance."
                        )
                    )));
                }
            } else if host == DEMO_HOST {
                // Couldn't get organization - block login on demo site
                return Err(Redirect::to(&format!(
                    "{}?error={}",
                    return_url,
                    urlencoding::encode(
                        "You can only log in to the demo account on this instance."
                    )
                )));
            }

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
    terms_accepted_at: Option<DateTime<Utc>>,
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
        host: _,
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

    // Track if this is a new org (not an invite)
    let is_new_org = org_id.is_none();

    // Extract pending setup from session (only relevant for new orgs)
    let pending_setup = if is_new_org {
        extract_pending_setup(&session).await
    } else {
        None
    };

    // Extract pending daemon setups from session (supports multiple daemons)
    let pending_daemon_setups = if is_new_org {
        extract_pending_daemon_setups(&session).await
    } else {
        vec![]
    };

    let billing_enabled = state.config.stripe_secret.is_some();

    // Register user
    match oidc_service
        .register(
            pending_auth,
            LoginRegisterParams {
                org_id,
                permissions,
                ip,
                user_agent,
                network_ids,
            },
            OidcRegisterParams {
                terms_accepted_at,
                billing_enabled,
                provider_slug: slug,
                code,
            },
            pending_setup.clone(),
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

            // If this is a new org and setup was provided, apply it
            if is_new_org {
                if let Some(setup) = pending_setup
                    && let Err(e) =
                        apply_pending_setup(&state, &user, setup, pending_daemon_setups).await
                {
                    tracing::error!("Failed to apply pending setup: {:?}", e);
                    // Don't fail registration, just log the error
                    // The user can complete onboarding manually
                }

                // Clear pending setup data from session
                clear_pending_setup(&session).await;
            }

            // Clear OIDC session data
            let _ = session.remove::<OidcPendingAuth>("oidc_pending_auth").await;
            let _ = session.remove::<String>("oidc_provider_slug").await;
            let _ = session.remove::<String>("oidc_return_url").await;
            let _ = session.remove::<bool>("oidc_terms_accepted").await;

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
    _demo_check: RequireFeature<BlockedInDemoMode>,
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
