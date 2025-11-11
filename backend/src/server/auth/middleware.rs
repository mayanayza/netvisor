use crate::server::{
    config::AppState,
    shared::{services::traits::CrudService, storage::filter::EntityFilter, types::api::ApiError},
    users::r#impl::base::UserOrgPermissions,
};
use axum::{
    extract::FromRequestParts,
    http::request::Parts,
    response::{IntoResponse, Response},
};
use chrono::Utc;
use tower_sessions::Session;
use uuid::Uuid;

pub struct AuthError(ApiError);

impl IntoResponse for AuthError {
    fn into_response(self) -> Response {
        self.0.into_response()
    }
}

/// Represents either an authenticated user or daemon
#[derive(Debug, Clone)]
pub enum AuthenticatedEntity {
    User {
        user_id: Uuid,
        organization_id: Uuid,
        permissions: UserOrgPermissions,
    },
    Daemon(Uuid), // network_id
}

impl AuthenticatedEntity {
    /// Get the user_id if this is a User, otherwise None
    pub fn user_id(&self) -> Option<Uuid> {
        match self {
            AuthenticatedEntity::User { user_id, .. } => Some(*user_id),
            _ => None,
        }
    }

    /// Get the network_id if this is a Daemon, otherwise None
    pub fn network_id(&self) -> Option<Uuid> {
        match self {
            AuthenticatedEntity::Daemon(id) => Some(*id),
            _ => None,
        }
    }

    /// Check if this is a user
    pub fn is_user(&self) -> bool {
        matches!(self, AuthenticatedEntity::User { .. })
    }

    /// Check if this is a daemon
    pub fn is_daemon(&self) -> bool {
        matches!(self, AuthenticatedEntity::Daemon(_))
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

                // Check expiration
                if let Some(expires_at) = api_key.base.expires_at
                    && chrono::Utc::now() > expires_at
                {
                    // Update enabled asynchronously (don't block auth)
                    api_key.base.is_enabled = false;
                    tokio::spawn(async move {
                        let _ = service.update(&mut api_key).await;
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
                    let _ = service.update(&mut api_key).await;
                });

                return Ok(AuthenticatedEntity::Daemon(network_id));
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

        Ok(AuthenticatedEntity::User {
            user_id: user.id,
            organization_id: user.base.organization_id,
            permissions: user.base.permissions,
        })
    }
}

/// Extractor that only accepts authenticated users (rejects daemons)
pub struct AuthenticatedUser {
    pub user_id: Uuid,
    pub organization_id: Uuid,
    pub permissions: UserOrgPermissions,
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
            } => Ok(AuthenticatedUser {
                user_id,
                organization_id,
                permissions,
            }),
            AuthenticatedEntity::Daemon(_) => Err(AuthError(ApiError::unauthorized(
                "User authentication required".to_string(),
            ))),
        }
    }
}

/// Extractor that only accepts authenticated daemons (rejects users)
pub struct AuthenticatedDaemon(pub Uuid);

impl<S> FromRequestParts<S> for AuthenticatedDaemon
where
    S: Send + Sync + AsRef<AppState>,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let entity = AuthenticatedEntity::from_request_parts(parts, state).await?;

        match entity {
            AuthenticatedEntity::Daemon(network_id) => Ok(AuthenticatedDaemon(network_id)),
            AuthenticatedEntity::User { .. } => Err(AuthError(ApiError::unauthorized(
                "Daemon authentication required".to_string(),
            ))),
        }
    }
}
