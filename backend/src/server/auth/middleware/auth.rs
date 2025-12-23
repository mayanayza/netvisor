use std::fmt::Display;

use crate::server::{
    api_keys::service::hash_api_key,
    config::AppState,
    shared::{services::traits::CrudService, storage::filter::EntityFilter, types::api::ApiError},
    users::r#impl::{base::User, permissions::UserOrgPermissions},
};
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

pub struct AuthError(pub ApiError);

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
        daemon_id: Uuid,
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
            AuthenticatedEntity::Daemon { daemon_id, .. } => daemon_id.to_string(),
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
            && let Some(daemon_id) = parts
                .headers
                .get("X-Daemon-ID")
                .and_then(|h| h.to_str().ok())
                .and_then(|s| Uuid::parse_str(s).ok())
        {
            let hashed_key = hash_api_key(api_key);
            let api_key_filter = EntityFilter::unfiltered().api_key(hashed_key);
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
                    daemon_id,
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
            // Load network_ids from junction table for non-admin users
            app_state
                .services
                .user_service
                .get_network_ids(&user.id)
                .await
                .map_err(|_| AuthError(ApiError::internal_error("Failed to load user networks")))?
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
    pub daemon_id: Uuid,
}

impl From<AuthenticatedDaemon> for AuthenticatedEntity {
    fn from(value: AuthenticatedDaemon) -> Self {
        AuthenticatedEntity::Daemon {
            network_id: value.network_id,
            api_key_id: value.api_key_id,
            daemon_id: value.daemon_id,
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
                daemon_id,
            } => Ok(AuthenticatedDaemon {
                network_id,
                api_key_id,
                daemon_id,
            }),
            _ => Err(AuthError(ApiError::unauthorized(
                "Daemon authentication required".to_string(),
            ))),
        }
    }
}
