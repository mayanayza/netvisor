use crate::server::auth::middleware::auth::AuthError;
use crate::server::auth::middleware::auth::AuthenticatedEntity;
use crate::server::auth::middleware::auth::AuthenticatedUser;
use crate::server::{
    config::AppState, shared::types::api::ApiError, users::r#impl::permissions::UserOrgPermissions,
};
use axum::{extract::FromRequestParts, http::request::Parts};
use uuid::Uuid;

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
