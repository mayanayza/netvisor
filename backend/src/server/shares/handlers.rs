use std::sync::Arc;

use axum::{
    Json, Router,
    extract::{Path, State},
    http::{HeaderMap, header},
    response::IntoResponse,
    routing::{delete, get, post, put},
};
use uuid::Uuid;

use crate::server::{
    auth::{
        middleware::{
            features::{EmbedsFeature, RequireFeature},
            permissions::RequireMember,
        },
        service::hash_password,
    },
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
        .route("/public/{id}/topology", get(get_share_topology))
}

// ============================================================================
// Authenticated Routes
// ============================================================================

/// Create a new share
async fn create_share(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    RequireFeature { plan, .. }: RequireFeature<EmbedsFeature>,
    Json(CreateUpdateShareRequest {
        mut share,
        password,
    }): Json<CreateUpdateShareRequest>,
) -> ApiResult<Json<ApiResponse<Share>>> {
    if !plan.features().embeds && share.is_embed_share() {
        return Err(ApiError::payment_required(
            "Your plan does not include embed shares",
        ));
    }

    // Hash password if provided
    if let Some(password) = password
        && !password.is_empty()
    {
        share.base.has_password = true;
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
            share.base.has_password = false;
            share.base.password_hash = None;
        }
        Some(password) => {
            // Set new password
            share.base.has_password = true;
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
        return Err(ApiError::not_found(format!(
            "{} not found or expired",
            share.base.share_type
        )));
    }

    Ok(Json(ApiResponse::success(PublicShareMetadata::from(
        &share,
    ))))
}

/// Verify password for a password-protected share
async fn verify_share_password(
    State(state): State<Arc<AppState>>,
    Path(id): Path<Uuid>,
    Json(password): Json<String>,
) -> ApiResult<impl IntoResponse> {
    let share = state
        .services
        .share_service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found("Share not found".to_string()))?;

    if !share.is_valid() {
        return Err(ApiError::not_found(format!(
            "{} not found or expired",
            share.base.share_type
        )));
    }

    if !share.requires_password() {
        return Err(ApiError::bad_request(&format!(
            "{} does not require a password",
            share.base.share_type
        )));
    }

    // Verify password
    state
        .services
        .share_service
        .verify_share_password(&share, &password)
        .map_err(|_| ApiError::unauthorized("Invalid password".to_string()))?;

    // Get topology data
    let topology = state
        .services
        .topology_service
        .storage()
        .get_by_id(&share.base.topology_id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found("Topology not found".to_string()))?;

    let response = ShareWithTopology {
        share: PublicShareMetadata::from(&share),
        topology: serde_json::to_value(&topology)
            .map_err(|e| ApiError::internal_error(&e.to_string()))?,
    };

    // Return with cache headers
    Ok((
        [(header::CACHE_CONTROL, "public, max-age=300")],
        Json(ApiResponse::success(response)),
    ))
}

/// Get topology data for a public share (non-password-protected)
async fn get_share_topology(
    State(state): State<Arc<AppState>>,
    Path(id): Path<Uuid>,
    headers: HeaderMap,
) -> ApiResult<impl IntoResponse> {
    let share = state
        .services
        .share_service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| ApiError::not_found("Share not found".to_string()))?;

    if !share.is_valid() {
        return Err(ApiError::not_found(format!(
            "{} not found or expired",
            share.base.share_type
        )));
    }

    // Password-protected shares must use the verify endpoint
    if share.requires_password() {
        return Err(ApiError::unauthorized("Password required".to_string()));
    }

    // For embed shares, validate the domain
    if share.is_embed_share() {
        let referer = headers.get(header::REFERER).and_then(|v| v.to_str().ok());

        if !state
            .services
            .share_service
            .validate_embed_domain(&share, referer)
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

    let response = ShareWithTopology {
        share: PublicShareMetadata::from(&share),
        topology: serde_json::to_value(&topology)
            .map_err(|e| ApiError::internal_error(&e.to_string()))?,
    };

    // Return with cache headers (5 minute cache)
    Ok((
        [(header::CACHE_CONTROL, "public, max-age=300")],
        Json(ApiResponse::success(response)),
    ))
}
