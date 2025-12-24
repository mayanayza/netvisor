use crate::server::auth::middleware::auth::AuthenticatedEntity;
use crate::server::auth::middleware::{
    features::{BlockedInDemoMode, InviteUsersFeature, RequireFeature},
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
use axum::extract::Path;
use axum::extract::State;
use axum::response::Redirect;
use axum::routing::get;
use std::sync::Arc;
use tower_sessions::Session;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(get_invites, create_invite))
        .routes(routes!(get_invite, revoke_invite))
        // Accept invite link - no OpenAPI docs (redirect endpoint)
        .route("/{id}/accept", get(accept_invite_link))
}

/// Create an organization invite
#[utoipa::path(
    post,
    path = "",
    tag = "invites",
    request_body = CreateInviteRequest,
    responses(
        (status = 200, description = "Invite created", body = Invite),
        (status = 403, description = "Seat limit reached or insufficient permissions"),
        (status = 400, description = "User already has an account"),
    ),
    security(("session" = []))
)]
async fn create_invite(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    RequireFeature { plan, .. }: RequireFeature<InviteUsersFeature>,
    _demo_check: RequireFeature<BlockedInDemoMode>,
    Json(request): Json<CreateInviteRequest>,
) -> ApiResult<Json<ApiResponse<Invite>>> {
    // Seat limit check
    if let Some(max_seats) = plan.config().included_seats
        && plan.config().seat_cents.is_none()
    {
        let org_filter = EntityFilter::unfiltered().organization_id(&user.organization_id);

        let current_members = state
            .services
            .user_service
            .get_all(org_filter)
            .await
            .unwrap_or_default()
            .len();

        let pending_invites = state
            .services
            .invite_service
            .get_org_invites(&user.organization_id)
            .await
            .unwrap_or_default()
            .len();

        let total_seats_used = current_members + pending_invites;

        if total_seats_used >= max_seats as usize {
            return Err(ApiError::forbidden(&format!(
                "Seat limit reached ({}/{}). Upgrade your plan for more seats, or delete any unused pending invites.",
                total_seats_used, max_seats
            )));
        }
    }

    if user.permissions < UserOrgPermissions::Admin {
        return Err(ApiError::forbidden(
            "Only admins and above can invite users to this organization",
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

/// Get an invite by ID
#[utoipa::path(
    get,
    path = "/{id}",
    tag = "invites",
    params(("id" = Uuid, Path, description = "Invite ID")),
    responses(
        (status = 200, description = "Invite details", body = Invite),
        (status = 400, description = "Invalid or expired invite"),
    ),
    security(("session" = []))
)]
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

/// List all invites for organization
#[utoipa::path(
    get,
    path = "",
    tag = "invites",
    responses(
        (status = 200, description = "List of active invites", body = Vec<Invite>),
    ),
    security(("session" = []))
)]
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

/// Revoke an invite
#[utoipa::path(
    delete,
    path = "/{id}/revoke",
    tag = "invites",
    params(("id" = Uuid, Path, description = "Invite ID")),
    responses(
        (status = 200, description = "Invite revoked"),
        (status = 400, description = "Invalid invite"),
        (status = 403, description = "Cannot revoke this invite"),
    ),
    security(("session" = []))
)]
async fn revoke_invite(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    _demo_check: RequireFeature<BlockedInDemoMode>,
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
