use crate::server::auth::middleware::{
    AuthenticatedUser, InviteUsersFeature, RequireFeature, RequireMember,
};
use crate::server::config::AppState;
use crate::server::organizations::r#impl::api::CreateInviteRequest;
use crate::server::organizations::r#impl::base::Organization;
use crate::server::organizations::r#impl::invites::OrganizationInvite;
use crate::server::shared::handlers::traits::{CrudHandlers, update_handler};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::types::api::ApiError;
use crate::server::shared::types::api::ApiResponse;
use crate::server::shared::types::api::ApiResult;
use crate::server::users::r#impl::permissions::UserOrgPermissions;
use anyhow::{Error, anyhow};
use axum::Json;
use axum::Router;
use axum::extract::Path;
use axum::extract::State;
use axum::response::Redirect;
use axum::routing::{delete, get, post, put};
use std::sync::Arc;
use tower_sessions::Session;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/{id}", put(update_handler::<Organization>))
        .route("/", get(get_by_id_handler))
        .route("/invites", post(create_invite))
        .route("/invites/{token}", get(get_invite))
        .route("/invites/{token}/revoke", delete(revoke_invite))
        .route("/invites/{token}/accept", get(accept_invite_link))
        .route("/invites", get(get_invites))
}

pub async fn get_by_id_handler(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> ApiResult<Json<ApiResponse<Organization>>> {
    let service = Organization::get_service(&state);
    let entity = service
        .get_by_id(&user.organization_id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| {
            ApiError::not_found(format!("Organization '{}' not found", user.organization_id))
        })?;

    Ok(Json(ApiResponse::success(entity)))
}

/// Create a new organization invite link
async fn create_invite(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    RequireFeature { plan, .. }: RequireFeature<InviteUsersFeature>,
    Json(request): Json<CreateInviteRequest>,
) -> ApiResult<Json<ApiResponse<OrganizationInvite>>> {
    // We know they have either team_members or share_views enabled
    if !plan.features().team_members && request.permissions > UserOrgPermissions::Viewer {
        return Err(ApiError::forbidden(
            "You can only create Viewer invites on your current plan. Please upgrade to a Team plan to add Members and Admins.",
        ));
    }

    if user.permissions < request.permissions {
        return Err(ApiError::forbidden(
            "Users can only create invites with permissions lower than their permission level",
        ));
    }

    let invite = state
        .services
        .organization_service
        .create_invite(request, user.organization_id, user.user_id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(invite)))
}

/// Get information about an invite (for display purposes)
async fn get_invite(
    State(state): State<Arc<AppState>>,
    RequireMember(_user): RequireMember,
    Path(token): Path<String>,
) -> ApiResult<Json<ApiResponse<OrganizationInvite>>> {
    let invite = state
        .services
        .organization_service
        .get_invite(&token)
        .await
        .map_err(|e| ApiError::bad_request(&e.to_string()))?;

    Ok(Json(ApiResponse::success(invite)))
}

/// Get all invites
async fn get_invites(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
) -> ApiResult<Json<ApiResponse<Vec<OrganizationInvite>>>> {
    // Show user invites that they created or created for users with permissions lower than them
    let invites = state
        .services
        .organization_service
        .list_invites(&user.organization_id)
        .await
        .into_iter()
        .filter(|i| i.created_by == user.user_id || i.permissions < user.permissions)
        .collect();

    Ok(Json(ApiResponse::success(invites)))
}

/// Revoke an invite link
async fn revoke_invite(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(token): Path<String>,
) -> ApiResult<Json<ApiResponse<()>>> {
    // Get the invite to verify ownership
    let invite = state
        .services
        .organization_service
        .get_invite(&token)
        .await
        .map_err(|e| ApiError::bad_request(&e.to_string()))?;

    if invite.organization_id != user.organization_id {
        return Err(ApiError::forbidden(
            "Cannot revoke invites from other organizations",
        ));
    }

    // Verify user
    if !(user.user_id == invite.created_by && invite.permissions < user.permissions) {
        return Err(ApiError::forbidden(
            "You can only revoke invites that you created or that users with lower permissions than you created",
        ));
    }

    state
        .services
        .organization_service
        .revoke_invite(&token)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(())))
}

/// Accept an invite link - redirects to registration/login with pending org invite in session
async fn accept_invite_link(
    State(state): State<Arc<AppState>>,
    session: Session,
    Path(token): Path<String>,
) -> Result<Redirect, Redirect> {
    // Validate the invite and get organization_id
    let invite = match state.services.organization_service.get_invite(&token).await {
        Ok(invite) => invite,
        Err(e) => {
            tracing::warn!("Invalid invite token: {}", e);
            return Err(Redirect::to(&format!(
                "/?error={}",
                urlencoding::encode("Invalid or expired invite link")
            )));
        }
    };

    let org_name = state
        .services
        .organization_service
        .get_by_id(&invite.organization_id)
        .await
        .unwrap_or_default()
        .map(|o| o.base.name)
        .unwrap_or("Unknown Organization".to_string());
    let inviting_user_email = state
        .services
        .user_service
        .get_by_id(&invite.created_by)
        .await
        .unwrap_or_default()
        .map(|u| u.base.email.to_string())
        .unwrap_or("Unknown User".to_string());

    // Store the pending invite in the session
    if let Err(e) = session
        .insert("pending_org_invite", invite.organization_id)
        .await
    {
        tracing::error!("Failed to save pending invite to session: {}", e);
        return Err(Redirect::to(&format!(
            "/?error={}",
            urlencoding::encode("Failed to process invite. Please try again.")
        )));
    }

    if let Err(e) = session.insert("pending_invite_token", token.clone()).await {
        tracing::error!("Failed to save invite token to session: {}", e);
        return Err(Redirect::to(&format!(
            "/?error={}",
            urlencoding::encode("Failed to process invite. Please try again.")
        )));
    };

    if let Err(e) = session
        .insert("pending_invite_permissions", invite.permissions)
        .await
    {
        tracing::error!("Failed to save invite permissions to session: {}", e);
        return Err(Redirect::to(&format!(
            "/?error={}",
            urlencoding::encode("Failed to process invite. Please try again.")
        )));
    };

    // Check if user is already logged in
    if let Ok(Some(user_id)) = session.get::<uuid::Uuid>("user_id").await {
        // User is logged in - add them to the organization immediately
        if let Err(e) = process_pending_invite(&state, &session, user_id).await {
            tracing::error!("Failed to process invite for logged-in user: {}", e);
            return Err(Redirect::to(&format!(
                "/?error={}",
                urlencoding::encode(&e.to_string())
            )));
        };

        // Mark invite as used
        if let Err(e) = state.services.organization_service.use_invite(&token).await {
            tracing::error!("Failed to mark invite as used: {}", e);
        }

        // Clear pending invite from session
        let _ = session.remove::<uuid::Uuid>("pending_org_invite").await;
        let _ = session.remove::<String>("pending_invite_token").await;
        let _ = session.remove::<String>("pending_invite_permissions").await;

        // Redirect to home
        return Ok(Redirect::to("/"));
    }

    // User is not logged in - redirect to registration with message
    Ok(Redirect::to(&format!(
        "/?org_name={}&invited_by={}",
        org_name, inviting_user_email
    )))
}

pub async fn process_pending_invite(
    state: &Arc<AppState>,
    session: &Session,
    user_id: Uuid,
) -> Result<(), Error> {
    // Check for pending invite in session
    let pending_org_id = match session.get::<Uuid>("pending_org_invite").await {
        Ok(Some(org_id)) => org_id,
        _ => return Ok(()), // No pending invite
    };

    let invite_token = match session.get::<String>("pending_invite_token").await {
        Ok(Some(token)) => token,
        _ => return Ok(()), // No token stored
    };

    let permissions = match session
        .get::<UserOrgPermissions>("pending_invite_permissions")
        .await
    {
        Ok(Some(permissions)) => permissions,
        _ => return Ok(()), // No token stored
    };

    tracing::info!(
        "Processing pending invite for user {} to organization {}",
        user_id,
        pending_org_id
    );

    let mut user = state
        .services
        .user_service
        .get_by_id(&user_id)
        .await?
        .ok_or_else(|| anyhow!("Failed to update organization for user {}", user_id))?;

    user.base.organization_id = pending_org_id;
    user.base.permissions = permissions;
    // Update user's organization
    state
        .services
        .user_service
        .update(&mut user)
        .await
        .map_err(|e| anyhow!("Failed to add user to organization: {}", e))?;

    // Mark invite as used
    if let Err(e) = state
        .services
        .organization_service
        .use_invite(&invite_token)
        .await
    {
        tracing::error!("Failed to mark invite as used: {}", e);
        // Don't fail the whole operation if we can't mark it as used
    }

    // Clear session data
    let _ = session.remove::<Uuid>("pending_org_invite").await;
    let _ = session.remove::<String>("pending_invite_token").await;

    Ok(())
}
