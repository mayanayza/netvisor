use std::fmt::Display;

use crate::server::{
    billing::types::base::BillingPlan,
    config::AppState,
    organizations::r#impl::base::Organization,
    shared::{services::traits::CrudService, storage::filter::EntityFilter, types::api::ApiError},
    users::r#impl::{base::User, permissions::UserOrgPermissions},
};
use async_trait::async_trait;
use axum::{
    extract::FromRequestParts,
    http::request::Parts,
    response::{IntoResponse, Response},
};
use chrono::Utc;
use email_address::EmailAddress;
use serde::Deserialize;
use serde::Serialize;
use tower_sessions::Session;
use uuid::Uuid;

pub struct AuthError(ApiError);

impl IntoResponse for AuthError {
    fn into_response(self) -> Response {
        self.0.into_response()
    }
}

/// Represents either an authenticated user or daemon
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum AuthenticatedEntity {
    User {
        user_id: Uuid,
        organization_id: Uuid,
        permissions: UserOrgPermissions,
        network_ids: Vec<Uuid>,
        email: EmailAddress,
    },
    Daemon {
        network_id: Uuid,
        api_key_id: Uuid,
    }, // network_id
    System,
    Anonymous,
}

impl Display for AuthenticatedEntity {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            AuthenticatedEntity::Anonymous => write!(f, "Anonymous"),
            AuthenticatedEntity::System => write!(f, "System"),
            AuthenticatedEntity::Daemon { .. } => write!(f, "Daemon"),
            AuthenticatedEntity::User {
                user_id,
                permissions,
                ..
            } => write!(
                f,
                "User {{ user_id: {}, permissions: {} }}",
                user_id, permissions
            ),
        }
    }
}

impl AuthenticatedEntity {
    /// Get the user_id if this is a User, otherwise None
    pub fn user_id(&self) -> Option<Uuid> {
        match self {
            AuthenticatedEntity::User { user_id, .. } => Some(*user_id),
            _ => None,
        }
    }

    pub fn entity_id(&self) -> String {
        match self {
            AuthenticatedEntity::User { user_id, .. } => user_id.to_string(),
            AuthenticatedEntity::Daemon {
                network_id,
                api_key_id,
            } => format!(
                "Daemon for network {} using API key {}",
                network_id, api_key_id
            ),
            AuthenticatedEntity::System => "System".to_string(),
            AuthenticatedEntity::Anonymous => "Anonymous".to_string(),
        }
    }

    /// Get network_ids that daemon / user have access to
    pub fn network_ids(&self) -> Vec<Uuid> {
        match self {
            AuthenticatedEntity::Daemon { network_id, .. } => vec![*network_id],
            AuthenticatedEntity::User { network_ids, .. } => network_ids.clone(),
            AuthenticatedEntity::System => vec![],
            AuthenticatedEntity::Anonymous => vec![],
        }
    }

    /// Check if this is a user
    pub fn is_user(&self) -> bool {
        matches!(self, AuthenticatedEntity::User { .. })
    }

    /// Check if this is a daemon
    pub fn is_daemon(&self) -> bool {
        matches!(self, AuthenticatedEntity::Daemon { .. })
    }
}

impl From<User> for AuthenticatedEntity {
    fn from(value: User) -> Self {
        AuthenticatedEntity::User {
            user_id: value.id,
            organization_id: value.base.organization_id,
            permissions: value.base.permissions,
            network_ids: vec![],
            email: value.base.email,
        }
    }
}

// Generic authenticated entity extractor - accepts both users and daemons
impl<S> FromRequestParts<S> for AuthenticatedEntity
where
    S: Send + Sync + AsRef<AppState>,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let app_state = state.as_ref();

        // Try daemon authentication first (Authorization header)
        if let Some(auth_header) = parts.headers.get(axum::http::header::AUTHORIZATION)
            && let Ok(auth_str) = auth_header.to_str()
            && let Some(api_key) = auth_str.strip_prefix("Bearer ")
        {
            let api_key_filter = EntityFilter::unfiltered().api_key(api_key.to_owned());
            // Get API key record by key
            if let Ok(Some(mut api_key)) = app_state
                .services
                .api_key_service
                .get_one(api_key_filter)
                .await
            {
                let network_id = api_key.base.network_id;
                let service = app_state.services.api_key_service.clone();
                let api_key_id = api_key.id;
                // Check expiration
                if let Some(expires_at) = api_key.base.expires_at
                    && chrono::Utc::now() > expires_at
                {
                    // Update enabled asynchronously (don't block auth)
                    api_key.base.is_enabled = false;
                    tokio::spawn(async move {
                        let _ = service
                            .update(&mut api_key, AuthenticatedEntity::System)
                            .await;
                    });
                    return Err(AuthError(ApiError::unauthorized(
                        "API key has expired".to_string(),
                    )));
                }

                if !api_key.base.is_enabled {
                    return Err(AuthError(ApiError::unauthorized(
                        "API key is not enabled".to_string(),
                    )));
                }

                // Update last used asynchronously (don't block auth)
                api_key.base.last_used = Some(Utc::now());
                tokio::spawn(async move {
                    let _ = service
                        .update(&mut api_key, AuthenticatedEntity::System)
                        .await;
                });

                return Ok(AuthenticatedEntity::Daemon {
                    network_id,
                    api_key_id,
                });
            }
            // Invalid API key
            return Err(AuthError(ApiError::unauthorized(
                "Invalid API key".to_string(),
            )));
        }

        // Try user authentication (session cookie)
        let session = Session::from_request_parts(parts, state)
            .await
            .map_err(|_| AuthError(ApiError::unauthorized("Not authenticated".to_string())))?;

        let user_id: Uuid = session
            .get("user_id")
            .await
            .map_err(|_| AuthError(ApiError::unauthorized("Not authenticated".to_string())))?
            .ok_or_else(|| AuthError(ApiError::unauthorized("Not authenticated".to_string())))?;

        let user = app_state
            .services
            .user_service
            .get_by_id(&user_id)
            .await
            .map_err(|_| AuthError(ApiError::unauthorized("User not found".to_string())))?
            .ok_or_else(|| AuthError(ApiError::unauthorized("User not found".to_string())))?;

        let network_ids: Vec<Uuid> = if matches!(
            user.base.permissions,
            UserOrgPermissions::Owner | UserOrgPermissions::Admin
        ) {
            let org_filter = EntityFilter::unfiltered().organization_id(&user.base.organization_id);

            app_state
                .services
                .network_service
                .get_all(org_filter)
                .await
                .map_err(|_| AuthError(ApiError::internal_error("Failed to load networks")))?
                .iter()
                .map(|n| n.id)
                .collect()
        } else {
            user.base.network_ids
        };

        Ok(AuthenticatedEntity::User {
            user_id: user.id,
            organization_id: user.base.organization_id,
            permissions: user.base.permissions,
            network_ids,
            email: user.base.email,
        })
    }
}

/// Extractor that only accepts authenticated users (rejects daemons)
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct AuthenticatedUser {
    pub user_id: Uuid,
    pub organization_id: Uuid,
    pub permissions: UserOrgPermissions,
    pub network_ids: Vec<Uuid>,
    pub email: EmailAddress,
}

impl From<AuthenticatedUser> for AuthenticatedEntity {
    fn from(value: AuthenticatedUser) -> Self {
        AuthenticatedEntity::User {
            user_id: value.user_id,
            organization_id: value.organization_id,
            permissions: value.permissions,
            network_ids: value.network_ids,
            email: value.email,
        }
    }
}

impl<S> FromRequestParts<S> for AuthenticatedUser
where
    S: Send + Sync + AsRef<AppState>,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let entity = AuthenticatedEntity::from_request_parts(parts, state).await?;

        match entity {
            AuthenticatedEntity::User {
                user_id,
                organization_id,
                permissions,
                network_ids,
                email,
            } => Ok(AuthenticatedUser {
                user_id,
                organization_id,
                permissions,
                network_ids,
                email,
            }),
            _ => Err(AuthError(ApiError::unauthorized(
                "User authentication required".to_string(),
            ))),
        }
    }
}

/// Extractor that only accepts authenticated daemons (rejects users)
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Copy)]
pub struct AuthenticatedDaemon {
    pub network_id: Uuid,
    pub api_key_id: Uuid,
}

impl From<AuthenticatedDaemon> for AuthenticatedEntity {
    fn from(value: AuthenticatedDaemon) -> Self {
        AuthenticatedEntity::Daemon {
            network_id: value.network_id,
            api_key_id: value.api_key_id,
        }
    }
}

impl<S> FromRequestParts<S> for AuthenticatedDaemon
where
    S: Send + Sync + AsRef<AppState>,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let entity = AuthenticatedEntity::from_request_parts(parts, state).await?;

        match entity {
            AuthenticatedEntity::Daemon {
                network_id,
                api_key_id,
            } => Ok(AuthenticatedDaemon {
                network_id,
                api_key_id,
            }),
            _ => Err(AuthError(ApiError::unauthorized(
                "Daemon authentication required".to_string(),
            ))),
        }
    }
}

/// Extractor that accepts either a Member+ user OR a daemon
/// Returns the network IDs the authenticated entity has access to
pub struct MemberOrDaemon {
    pub network_ids: Vec<Uuid>,
    pub entity: AuthenticatedEntity,
}

impl<S> FromRequestParts<S> for MemberOrDaemon
where
    S: Send + Sync + AsRef<AppState>,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        // Get the authenticated entity (works for both users and daemons)
        let entity = AuthenticatedEntity::from_request_parts(parts, state).await?;

        match entity {
            AuthenticatedEntity::User { .. } => {
                // For users, check they're at least Member level
                let member = RequireMember::from_request_parts(parts, state).await?;
                let user: AuthenticatedUser = member.into();

                Ok(MemberOrDaemon {
                    network_ids: user.network_ids.clone(),
                    entity: user.into(),
                })
            }
            AuthenticatedEntity::Daemon { network_id, .. } => {
                // Daemons only have access to their single network
                Ok(MemberOrDaemon {
                    network_ids: vec![network_id],
                    entity,
                })
            }
            _ => Err(AuthError(ApiError::forbidden(
                "Member or Daemon permission required",
            ))),
        }
    }
}

/// Extractor that requires the user to be at least an Owner
pub struct RequireOwner(pub AuthenticatedUser);

impl From<RequireOwner> for AuthenticatedUser {
    fn from(value: RequireOwner) -> Self {
        value.0
    }
}

impl<S> FromRequestParts<S> for RequireOwner
where
    S: Send + Sync + AsRef<AppState>,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let user = AuthenticatedUser::from_request_parts(parts, state).await?;

        if user.permissions < UserOrgPermissions::Owner {
            return Err(AuthError(ApiError::forbidden("Owner permission required")));
        }

        Ok(RequireOwner(user))
    }
}

/// Extractor that requires the user to be at least an Admin
pub struct RequireAdmin(pub AuthenticatedUser);

impl From<RequireAdmin> for AuthenticatedUser {
    fn from(value: RequireAdmin) -> Self {
        value.0
    }
}

impl From<RequireOwner> for RequireAdmin {
    fn from(value: RequireOwner) -> Self {
        RequireAdmin(value.0)
    }
}

impl<S> FromRequestParts<S> for RequireAdmin
where
    S: Send + Sync + AsRef<AppState>,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let user = AuthenticatedUser::from_request_parts(parts, state).await?;

        if user.permissions < UserOrgPermissions::Admin {
            return Err(AuthError(ApiError::forbidden("Admin permission required")));
        }

        Ok(RequireAdmin(user))
    }
}

/// Extractor that requires the user to be at least a Member
pub struct RequireMember(pub AuthenticatedUser);

impl From<RequireMember> for AuthenticatedUser {
    fn from(value: RequireMember) -> Self {
        value.0
    }
}

impl From<RequireOwner> for RequireMember {
    fn from(value: RequireOwner) -> Self {
        RequireMember(value.0)
    }
}

impl From<RequireAdmin> for RequireMember {
    fn from(value: RequireAdmin) -> Self {
        RequireMember(value.0)
    }
}

impl<S> FromRequestParts<S> for RequireMember
where
    S: Send + Sync + AsRef<AppState>,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let user = AuthenticatedUser::from_request_parts(parts, state).await?;

        if user.permissions < UserOrgPermissions::Member {
            return Err(AuthError(ApiError::forbidden("Member permission required")));
        }

        Ok(RequireMember(user))
    }
}

/// Context available for feature/quota checks
pub struct FeatureCheckContext<'a> {
    pub organization: &'a Organization,
    pub plan: BillingPlan,
    pub app_state: &'a AppState,
}

pub enum FeatureCheckResult {
    Allowed,
    Denied { message: String },
}

impl FeatureCheckResult {
    pub fn denied(msg: impl Into<String>) -> Self {
        Self::Denied {
            message: msg.into(),
        }
    }

    pub fn is_allowed(&self) -> bool {
        matches!(self, Self::Allowed)
    }
}

#[async_trait]
pub trait FeatureCheck: Send + Sync + Default {
    async fn check(&self, ctx: &FeatureCheckContext<'_>) -> FeatureCheckResult;
}

// ============ Extractor ============

pub struct RequireFeature<T: FeatureCheck> {
    pub permissions: UserOrgPermissions,
    pub plan: BillingPlan,
    pub organization: Organization,
    pub _phantom: std::marker::PhantomData<T>,
}

impl<S, T> FromRequestParts<S> for RequireFeature<T>
where
    S: Send + Sync + AsRef<AppState>,
    T: FeatureCheck + Default,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let AuthenticatedUser {
            permissions,
            organization_id,
            ..
        } = AuthenticatedUser::from_request_parts(parts, state).await?;

        let app_state = state.as_ref();

        let organization = app_state
            .services
            .organization_service
            .get_by_id(&organization_id)
            .await
            .map_err(|_| AuthError(ApiError::internal_error("Failed to load organization")))?
            .ok_or_else(|| AuthError(ApiError::forbidden("Organization not found")))?;

        let plan = organization.base.plan.unwrap_or_default();

        let ctx = FeatureCheckContext {
            organization: &organization,
            plan,
            app_state,
        };

        let checker = T::default();
        match checker.check(&ctx).await {
            FeatureCheckResult::Allowed => Ok(RequireFeature {
                permissions,
                plan,
                organization,
                _phantom: std::marker::PhantomData,
            }),
            FeatureCheckResult::Denied { message } => Err(AuthError(ApiError::forbidden(&message))),
        }
    }
}

// ============ Concrete Checkers ============

#[derive(Default)]
pub struct InviteUsersFeature;

#[async_trait]
impl FeatureCheck for InviteUsersFeature {
    async fn check(&self, ctx: &FeatureCheckContext<'_>) -> FeatureCheckResult {
        let features = ctx.plan.features();

        if !features.share_views {
            return FeatureCheckResult::denied(
                "Your plan does not include team collaboration features",
            );
        }

        // Check seat quota if there's a limit and user doesn't have a plan that lets them buy more seats
        if let Some(max_seats) = ctx.plan.config().included_seats
            && ctx.plan.config().seat_cents.is_none()
        {
            let org_filter = EntityFilter::unfiltered().organization_id(&ctx.organization.id);

            let current_members = ctx
                .app_state
                .services
                .user_service
                .get_all(org_filter)
                .await
                .unwrap_or_default()
                .iter()
                .filter(|u| u.base.permissions.counts_towards_seats())
                .count();

            let pending_invites = ctx
                .app_state
                .services
                .organization_service
                .get_org_invites(&ctx.organization.id)
                .await
                .unwrap_or_default()
                .iter()
                .filter(|i| i.permissions.counts_towards_seats())
                .count();

            let total_seats_used = current_members + pending_invites;

            if total_seats_used >= max_seats as usize {
                return FeatureCheckResult::denied(format!(
                    "Seat limit reached ({}/{}). Upgrade your plan for more seats, or delete any unused pending invites.",
                    total_seats_used, max_seats
                ));
            }
        }

        FeatureCheckResult::Allowed
    }
}

#[derive(Default)]
pub struct CreateNetworkFeature;

#[async_trait]
impl FeatureCheck for CreateNetworkFeature {
    async fn check(&self, ctx: &FeatureCheckContext<'_>) -> FeatureCheckResult {
        // Check networks quota if there's a limit and user doesn't have a plan that lets them buy more networks
        if let Some(max_networks) = ctx.plan.config().included_networks
            && ctx.plan.config().network_cents.is_none()
        {
            let org_filter = EntityFilter::unfiltered().organization_id(&ctx.organization.id);

            let current_networks = ctx
                .app_state
                .services
                .network_service
                .get_all(org_filter)
                .await
                .map(|o| o.len())
                .unwrap_or(0);

            if current_networks >= max_networks as usize {
                return FeatureCheckResult::denied(format!(
                    "Network limit reached ({}/{}). Upgrade your plan for more networks.",
                    current_networks, max_networks
                ));
            }
        }

        FeatureCheckResult::Allowed
    }
}
