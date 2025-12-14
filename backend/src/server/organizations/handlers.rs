use crate::server::auth::middleware::auth::AuthenticatedEntity;
use crate::server::auth::middleware::permissions::RequireOwner;
use crate::server::auth::middleware::{
    auth::AuthenticatedUser, features::InviteUsersFeature, features::RequireFeature,
    permissions::RequireMember,
};
use crate::server::config::AppState;
use crate::server::organizations::r#impl::api::CreateInviteRequest;
use crate::server::organizations::r#impl::base::Organization;
use crate::server::organizations::r#impl::invites::Invite;
use crate::server::shared::handlers::traits::{CrudHandlers, update_handler};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::types::api::ApiError;
use crate::server::shared::types::api::ApiResponse;
use crate::server::shared::types::api::ApiResult;
use crate::server::users::r#impl::permissions::UserOrgPermissions;
use anyhow::Error;
use anyhow::anyhow;
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
        .route("/{id}", put(update_org_name))
        .route("/", get(get_by_id_handler))
        .route("/invites", post(create_invite))
        .route("/invites/{id}", get(get_invite))
        .route("/invites/{id}/revoke", delete(revoke_invite))
        .route("/invites/{id}/accept", get(accept_invite_link))
        .route("/invites", get(get_invites))
}

pub async fn update_org_name(
    State(state): State<Arc<AppState>>,
    RequireOwner(user): RequireOwner,
    Path(id): Path<Uuid>,
    Json(mut org): Json<Organization>,
) -> ApiResult<Json<ApiResponse<Organization>>> {
    if id != org.id {
        return Err(ApiError::bad_request("Org ID must match path ID"));
    }

    let current_org = state
        .services
        .organization_service
        .get_by_id(&org.id)
        .await?
        .ok_or_else(|| anyhow!("Could not find org"))?;

    org.base.onboarding = current_org.base.onboarding;
    org.base.plan = current_org.base.plan;
    org.base.stripe_customer_id = current_org.base.stripe_customer_id;
    org.base.plan_status = current_org.base.plan_status;

    update_handler::<Organization>(
        axum::extract::State(state),
        RequireMember(user),
        axum::extract::Path(id),
        axum::extract::Json(org),
    )
    .await
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
            .organization_service
            .get_org_invites(&user.organization_id)
            .await
            .unwrap_or_default()
            .iter()
            .filter(|i| i.permissions.counts_towards_seats())
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

    let invite = state
        .services
        .organization_service
        .create_invite(
            request,
            user.organization_id,
            user.user_id,
            state.config.public_url.clone(),
            user.into(),
            send_to.clone(),
        )
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    if let Some(send_to) = send_to
        && let Some(email_service) = &state.services.email_service
    {
        let url = format!(
            "{}/api/organizations/invites/{}/accept",
            invite.url.clone(),
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
        .organization_service
        .get_invite(id)
        .await
        .map_err(|e| ApiError::bad_request(&e.to_string()))?;

    Ok(Json(ApiResponse::success(invite)))
}

/// Get all invites
async fn get_invites(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
) -> ApiResult<Json<ApiResponse<Vec<Invite>>>> {
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
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    // Get the invite to verify ownership
    let invite = state
        .services
        .organization_service
        .get_invite(id)
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
        .revoke_invite(id, user.into())
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
    let invite = match state.services.organization_service.get_invite(id).await {
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

    if let Err(e) = session.insert("pending_invite_id", id).await {
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

    if let Err(e) = session
        .insert("pending_network_ids", invite.network_ids)
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
        // User is logged in - add them to the organization immediately
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
    if let Err(e) = state
        .services
        .organization_service
        .use_invite(invite_id)
        .await
    {
        tracing::error!("Failed to mark invite as used: {}", e);
    }

    // Clear session data
    let _ = session.remove::<Uuid>("pending_org_invite").await;
    let _ = session.remove::<String>("pending_invite_id").await;
    let _ = session.remove::<String>("pending_invite_permissions").await;
    let _ = session.remove::<String>("pending_network_ids").await;

    Ok(Some((pending_org_id, permissions, network_ids)))
}
