use std::sync::Arc;

use axum::{
    Json, Router,
    extract::{Path, Query, State},
    http::{HeaderMap, header},
    response::{IntoResponse, Response},
    routing::{delete, get, post, put},
};
use serde::Deserialize;
use uuid::Uuid;

use crate::server::{
    auth::{middleware::permissions::RequireMember, service::hash_password},
    billing::types::base::BillingPlan,
    config::AppState,
    shared::{
        handlers::traits::{
            CrudHandlers, bulk_delete_handler, create_handler, delete_handler, get_all_handler,
            get_by_id_handler, update_handler,
        },
        services::traits::CrudService,
        storage::traits::Storage,
        types::api::{ApiError, ApiResponse, ApiResult},
    },
    shares::r#impl::{
        api::{CreateUpdateShareRequest, PublicShareMetadata, ShareWithTopology},
        base::Share,
    },
};

#[derive(Debug, Deserialize)]
pub struct ShareQuery {
    #[serde(default)]
    pub embed: bool,
}

#[derive(Debug, Deserialize)]
pub struct ShareTopologyRequest {
    #[serde(default)]
    pub password: Option<String>,
}

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        // Authenticated routes - use generic handlers where possible
        .route("/", post(create_share))
        .route("/", get(get_all_handler::<Share>))
        .route("/{id}", get(get_by_id_handler::<Share>))
        .route("/{id}", put(update_share))
        .route("/{id}", delete(delete_handler::<Share>))
        .route("/bulk-delete", post(bulk_delete_handler::<Share>))
        // Public routes (no auth required)
        .route("/public/{id}", get(get_public_share_metadata))
        .route("/public/{id}/verify", post(verify_share_password))
        .route("/public/{id}/topology", post(get_share_topology))
}

// ============================================================================
// Authenticated Routes
// ============================================================================

/// Create a new share
async fn create_share(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(CreateUpdateShareRequest {
        mut share,
        password,
    }): Json<CreateUpdateShareRequest>,
) -> ApiResult<Json<ApiResponse<Share>>> {
    // Hash password if provided
    if let Some(password) = password
        && !password.is_empty()
    {
        share.base.password_hash =
            Some(hash_password(&password).map_err(|e| ApiError::internal_error(&e.to_string()))?);
    }

    share.base.created_by = user.user_id;

    create_handler::<Share>(State(state), RequireMember(user), Json(share)).await
}

/// Update a share, handling password changes
async fn update_share(
    State(state): State<Arc<AppState>>,
    user: RequireMember,
    Path(id): Path<Uuid>,
    Json(CreateUpdateShareRequest {
        mut share,
        password,
    }): Json<CreateUpdateShareRequest>,
) -> ApiResult<Json<ApiResponse<Share>>> {
    // Fetch existing to handle password preservation
    let existing = Share::get_service(&state)
        .get_by_id(&id)
        .await?
        .ok_or_else(|| ApiError::not_found(format!("Share '{}' not found", id)))?;

    // Handle password field:
    // - None: preserve existing password_hash
    // - Some(""): remove password (clear password_hash)
    // - Some(value): hash and set new password
    match &password {
        None => {
            // Preserve existing password
            share.base.password_hash = existing.base.password_hash;
        }
        Some(password) if password.is_empty() => {
            // Remove password
            share.base.password_hash = None;
        }
        Some(password) => {
            // Set new password
            share.base.password_hash = Some(
                hash_password(password).map_err(|e| ApiError::internal_error(&e.to_string()))?,
            );
        }
    }

    // Delegate to generic handler
    update_handler::<Share>(State(state), user, Path(id), Json(share)).await
}

// ============================================================================
// Public Routes (No Authentication Required)
// ============================================================================

/// Helper to get the organization's plan for a share
async fn get_share_org_plan(state: &AppState, share: &Share) -> Result<BillingPlan, ApiError> {
    // Get network to find organization
    let network = state
        .services
        .network_service
        .storage()
        .get_by_id(&share.base.network_id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found("Network not found".to_string()))?;

    // Get organization to find plan
    let org = state
        .services
        .organization_service
        .get_by_id(&network.base.organization_id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found("Organization not found".to_string()))?;

    Ok(org.base.plan.unwrap_or_default())
}

/// Get public metadata about a share (no topology data)
async fn get_public_share_metadata(
    State(state): State<Arc<AppState>>,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<PublicShareMetadata>>> {
    let share = state
        .services
        .share_service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found("Share not found".to_string()))?;

    if !share.is_valid() {
        return Err(ApiError::not_found(
            "Share not found or expired".to_string(),
        ));
    }

    Ok(Json(ApiResponse::success(PublicShareMetadata::from(
        &share,
    ))))
}

/// Verify password for a password-protected share (returns success/failure only)
async fn verify_share_password(
    State(state): State<Arc<AppState>>,
    Path(id): Path<Uuid>,
    Json(password): Json<String>,
) -> ApiResult<Json<ApiResponse<bool>>> {
    let share = state
        .services
        .share_service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found("Share not found".to_string()))?;

    if !share.is_valid() {
        return Err(ApiError::not_found(
            "Share not found or expired".to_string(),
        ));
    }

    if !share.requires_password() {
        return Err(ApiError::bad_request("Share does not require a password"));
    }

    // Verify password - returns error if invalid
    state
        .services
        .share_service
        .verify_share_password(&share, &password)
        .map_err(|_| ApiError::unauthorized("Invalid password".to_string()))?;

    Ok(Json(ApiResponse::success(true)))
}

/// Get topology data for a public share
async fn get_share_topology(
    State(state): State<Arc<AppState>>,
    Path(id): Path<Uuid>,
    Query(query): Query<ShareQuery>,
    req_headers: HeaderMap,
    Json(body): Json<ShareTopologyRequest>,
) -> ApiResult<Response> {
    let share = state
        .services
        .share_service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found("Share not found".to_string()))?;

    if !share.is_valid() {
        return Err(ApiError::not_found("Share disabled or expired".to_string()));
    }

    // Get org's plan to check embed feature
    let plan = get_share_org_plan(&state, &share).await?;
    let has_embeds_feature = plan.features().embeds;

    // If requesting embed mode, check if org has embeds feature
    if query.embed && !has_embeds_feature {
        return Err(ApiError::payment_required(
            "Embed access requires a plan with embeds feature",
        ));
    }

    // Handle password-protected shares
    if share.requires_password() {
        match &body.password {
            Some(password) => {
                state
                    .services
                    .share_service
                    .verify_share_password(&share, password)
                    .map_err(|_| ApiError::unauthorized("Invalid password".to_string()))?;
            }
            None => {
                return Err(ApiError::unauthorized("Password required".to_string()));
            }
        }
    }

    // Validate allowed_domains only for embed requests
    if query.embed && share.has_domain_restrictions() {
        let referer = req_headers
            .get(header::REFERER)
            .and_then(|v| v.to_str().ok());

        if !state
            .services
            .share_service
            .validate_allowed_domains(&share, referer)
        {
            return Err(ApiError::forbidden("Domain not allowed"));
        }
    }

    // Get topology data
    let topology = state
        .services
        .topology_service
        .storage()
        .get_by_id(&share.base.topology_id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found("Topology not found".to_string()))?;

    let response_data = ShareWithTopology {
        share: PublicShareMetadata::from(&share),
        topology: serde_json::to_value(&topology)
            .map_err(|e| ApiError::internal_error(&e.to_string()))?,
    };

    // Build response with appropriate headers
    let mut response = Json(ApiResponse::success(response_data)).into_response();
    let headers = response.headers_mut();

    // Add cache header
    headers.insert(
        header::CACHE_CONTROL,
        "public, max-age=300".parse().unwrap(),
    );

    // Add X-Frame-Options: DENY if org doesn't have embeds feature
    // This prevents iframing the share even via the regular link URL
    if !has_embeds_feature {
        headers.insert(header::X_FRAME_OPTIONS, "DENY".parse().unwrap());
    }

    Ok(response)
}
