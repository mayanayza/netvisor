use crate::server::auth::middleware::auth::AuthenticatedEntity;
use crate::server::auth::middleware::{
    features::{InviteUsersFeature, RequireFeature},
    permissions::RequireMember,
};
use crate::server::config::AppState;
use crate::server::invites::r#impl::base::Invite;
use crate::server::organizations::r#impl::api::CreateInviteRequest;
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::types::api::ApiError;
use crate::server::shared::types::api::ApiResponse;
use crate::server::shared::types::api::ApiResult;
use crate::server::users::r#impl::permissions::UserOrgPermissions;
use anyhow::Error;
use axum::Json;
use axum::Router;
use axum::extract::Path;
use axum::extract::State;
use axum::response::Redirect;
use axum::routing::{delete, get, post};
use std::sync::Arc;
use tower_sessions::Session;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", post(create_invite))
        .route("/", get(get_invites))
        .route("/{id}", get(get_invite))
        .route("/{id}/revoke", delete(revoke_invite))
        .route("/{id}/accept", get(accept_invite_link))
}

/// Create a new organization invite link
async fn create_invite(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    RequireFeature { plan, .. }: RequireFeature<InviteUsersFeature>,
    Json(request): Json<CreateInviteRequest>,
) -> ApiResult<Json<ApiResponse<Invite>>> {
    // Seat limit check - only applies if permissions count towards seats
    if request.permissions.counts_towards_seats()
        && let Some(max_seats) = plan.config().included_seats
        && plan.config().seat_cents.is_none()
    {
        let org_filter = EntityFilter::unfiltered().organization_id(&user.organization_id);

        let current_members = state
            .services
            .user_service
            .get_all(org_filter)
            .await
            .unwrap_or_default()
            .iter()
            .filter(|u| u.base.permissions.counts_towards_seats())
            .count();

        let pending_invites = state
            .services
            .invite_service
            .get_org_invites(&user.organization_id)
            .await
            .unwrap_or_default()
            .iter()
            .filter(|i| i.base.permissions.counts_towards_seats())
            .count();

        let total_seats_used = current_members + pending_invites;

        if total_seats_used >= max_seats as usize {
            return Err(ApiError::forbidden(&format!(
                "Seat limit reached ({}/{}). Upgrade your plan for more seats, or delete any unused pending invites.",
                total_seats_used, max_seats
            )));
        }
    }

    if user.permissions < request.permissions {
        return Err(ApiError::forbidden(
            "Users can only create invites with permissions lower than their permission level",
        ));
    }

    // Check if invited user already has an account
    if let Some(ref send_to) = request.send_to {
        let all_users = state
            .services
            .user_service
            .get_all(EntityFilter::unfiltered())
            .await
            .unwrap_or_default();

        if all_users.iter().any(|u| &u.base.email == send_to) {
            return Err(ApiError::bad_request(
                "A user with this email already has an account. They must delete their account before joining a new organization.",
            ));
        }
    }

    let send_to = request.send_to.clone();
    let from_user = user.email.clone();
    let expiration_hours = request.expiration_hours.unwrap_or(168); // Default 7 days

    let invite = Invite::with_expiration(
        user.organization_id,
        state.config.public_url.clone(),
        user.user_id,
        expiration_hours,
        request.permissions,
        request.network_ids,
        send_to.clone(),
    );

    let invite = state
        .services
        .invite_service
        .create(invite, user.clone().into())
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    if let Some(send_to) = send_to
        && let Some(email_service) = &state.services.email_service
    {
        let url = format!(
            "{}/api/invites/{}/accept",
            invite.base.url.clone(),
            invite.id
        );
        email_service.send_invite(send_to, from_user, url).await?;
    }

    Ok(Json(ApiResponse::success(invite)))
}

/// Get information about an invite (for display purposes)
async fn get_invite(
    State(state): State<Arc<AppState>>,
    RequireMember(_user): RequireMember,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<Invite>>> {
    let invite = state
        .services
        .invite_service
        .get_valid_invite(id)
        .await
        .map_err(|e| ApiError::bad_request(&e.to_string()))?;

    Ok(Json(ApiResponse::success(invite)))
}

/// Get all invites for the user's organization
async fn get_invites(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
) -> ApiResult<Json<ApiResponse<Vec<Invite>>>> {
    // Show user invites that they created or created for users with permissions lower than them
    let invites = state
        .services
        .invite_service
        .list_active_invites(&user.organization_id)
        .await
        .into_iter()
        .filter(|i| {
            i.base.created_by == user.user_id
                || i.base.permissions < user.permissions
                || user.permissions == UserOrgPermissions::Owner
        })
        .collect();

    Ok(Json(ApiResponse::success(invites)))
}

/// Revoke an invite link
async fn revoke_invite(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    // Get the invite to verify ownership
    let invite = state
        .services
        .invite_service
        .get_valid_invite(id)
        .await
        .map_err(|e| ApiError::bad_request(&e.to_string()))?;

    if invite.base.organization_id != user.organization_id {
        return Err(ApiError::forbidden(
            "Cannot revoke invites from other organizations",
        ));
    }

    // Verify user can revoke this invite
    if !(user.user_id == invite.base.created_by
        || invite.base.permissions < user.permissions
        || user.permissions == UserOrgPermissions::Owner)
    {
        return Err(ApiError::forbidden(
            "You can only revoke invites that you created or invites for users with lower permissions than you",
        ));
    }

    state
        .services
        .invite_service
        .delete(&id, user.into())
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(())))
}

/// Accept an invite link - redirects to registration/login with pending org invite in session
async fn accept_invite_link(
    State(state): State<Arc<AppState>>,
    session: Session,
    Path(id): Path<Uuid>,
) -> Result<Redirect, Redirect> {
    // Validate the invite and get organization_id
    let invite = match state.services.invite_service.get_valid_invite(id).await {
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
        .get_by_id(&invite.base.organization_id)
        .await
        .unwrap_or_default()
        .map(|o| o.base.name)
        .unwrap_or("Unknown Organization".to_string());
    let inviting_user_email = state
        .services
        .user_service
        .get_by_id(&invite.base.created_by)
        .await
        .unwrap_or_default()
        .map(|u| u.base.email.to_string())
        .unwrap_or("Unknown User".to_string());

    // Store the pending invite in the session
    if let Err(e) = session
        .insert("pending_org_invite", invite.base.organization_id)
        .await
    {
        tracing::error!("Failed to save pending invite to session: {}", e);
        return Err(Redirect::to(&format!(
            "/?error={}",
            urlencoding::encode("Failed to process invite. Please try again.")
        )));
    }

    if let Err(e) = session.insert("pending_invite_id", id).await {
        tracing::error!("Failed to save invite token to session: {}", e);
        return Err(Redirect::to(&format!(
            "/?error={}",
            urlencoding::encode("Failed to process invite. Please try again.")
        )));
    };

    if let Err(e) = session
        .insert("pending_invite_permissions", invite.base.permissions)
        .await
    {
        tracing::error!("Failed to save invite permissions to session: {}", e);
        return Err(Redirect::to(&format!(
            "/?error={}",
            urlencoding::encode("Failed to process invite. Please try again.")
        )));
    };

    if let Err(e) = session
        .insert("pending_network_ids", invite.base.network_ids.clone())
        .await
    {
        tracing::error!("Failed to save invite network_ids to session: {}", e);
        return Err(Redirect::to(&format!(
            "/?error={}",
            urlencoding::encode("Failed to process invite. Please try again.")
        )));
    };

    // Check if user is already logged in
    if let Ok(Some(user_id)) = session.get::<uuid::Uuid>("user_id").await {
        // Check if user is already in an organization - they must leave first
        if let Ok(Some(_user)) = state.services.user_service.get_by_id(&user_id).await {
            // User already belongs to an org - revoke invite and redirect to error
            if let Err(e) = state
                .services
                .invite_service
                .delete(&id, AuthenticatedEntity::System)
                .await
            {
                tracing::warn!("Failed to revoke invite {}: {}", id, e);
            }
            return Err(Redirect::to(&format!(
                "/error?type=already_in_org&message={}",
                urlencoding::encode(
                    "You are already a member of an organization. Please leave your current organization before accepting this invite."
                )
            )));
        }

        // User is logged in but not in an org - add them to the organization immediately
        if let Some((org_id, permissions, network_ids)) = process_pending_invite(&state, &session)
            .await
            .map_err(|e| {
                tracing::error!("Failed to process invite for logged-in user: {}", e);
                Redirect::to(&format!("/?error={}", urlencoding::encode(&e.to_string())))
            })?
        {
            let mut user = state
                .services
                .user_service
                .get_by_id(&user_id)
                .await
                .map_err(|_| {
                    Redirect::to(&format!(
                        "/?error={}",
                        urlencoding::encode(&format!(
                            "Failed get user to update organization {}",
                            user_id
                        ))
                    ))
                })?
                .ok_or_else(|| {
                    Redirect::to(&format!(
                        "/?error={}",
                        urlencoding::encode(&format!(
                            "Failed to update organization for user {}",
                            user_id
                        ))
                    ))
                })?;

            user.base.organization_id = org_id;
            user.base.permissions = permissions;
            user.base.network_ids = network_ids;
            // Update user's organization
            state
                .services
                .user_service
                .update(&mut user, AuthenticatedEntity::System)
                .await
                .map_err(|_| {
                    Redirect::to(&format!(
                        "/?error={}",
                        urlencoding::encode(&format!(
                            "Failed update user organization {}",
                            user_id
                        ))
                    ))
                })?;
        }

        // Redirect to home
        return Ok(Redirect::to("/"));
    }

    // User is not logged in - redirect to onboarding/registration with invite params
    Ok(Redirect::to(&format!(
        "/onboarding?org_name={}&invited_by={}",
        org_name, inviting_user_email
    )))
}

pub async fn process_pending_invite(
    state: &Arc<AppState>,
    session: &Session,
) -> Result<Option<(Uuid, UserOrgPermissions, Vec<Uuid>)>, Error> {
    // Check for pending invite in session
    let pending_org_id = match session.get::<Uuid>("pending_org_invite").await {
        Ok(Some(org_id)) => org_id,
        _ => return Ok(None), // No pending invite
    };

    let invite_id = match session.get::<Uuid>("pending_invite_id").await {
        Ok(Some(token)) => token,
        _ => return Ok(None), // No token stored
    };

    let permissions = match session
        .get::<UserOrgPermissions>("pending_invite_permissions")
        .await
    {
        Ok(Some(permissions)) => permissions,
        _ => return Ok(None), // No permissions stored
    };

    let network_ids = match session.get::<Vec<Uuid>>("pending_network_ids").await {
        Ok(Some(network_ids)) => network_ids,
        _ => return Ok(None), // No network ids
    };

    // Mark invite as used
    if let Err(e) = state.services.invite_service.use_invite(invite_id).await {
        tracing::error!("Failed to mark invite as used: {}", e);
    }

    // Clear session data
    let _ = session.remove::<Uuid>("pending_org_invite").await;
    let _ = session.remove::<String>("pending_invite_id").await;
    let _ = session.remove::<String>("pending_invite_permissions").await;
    let _ = session.remove::<String>("pending_network_ids").await;

    Ok(Some((pending_org_id, permissions, network_ids)))
}
