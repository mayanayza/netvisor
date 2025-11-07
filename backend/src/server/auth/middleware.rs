use crate::server::{
    config::AppState,
    shared::{services::traits::CrudService, storage::filter::EntityFilter, types::api::ApiError},
};
use axum::{
    extract::FromRequestParts,
    http::request::Parts,
    response::{IntoResponse, Response},
};
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
    User(Uuid),   // user_id
    Daemon(Uuid), // network_id
}

impl AuthenticatedEntity {
    /// Get the user_id if this is a User, otherwise None
    pub fn user_id(&self) -> Option<Uuid> {
        match self {
            AuthenticatedEntity::User(id) => Some(*id),
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
        matches!(self, AuthenticatedEntity::User(_))
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
            // Look up daemon by API key
            if let Ok(Some(daemon)) = app_state
                .services
                .daemon_service
                .get_one(api_key_filter)
                .await
            {
                return Ok(AuthenticatedEntity::Daemon(daemon.base.network_id));
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

        Ok(AuthenticatedEntity::User(user_id))
    }
}

/// Extractor that only accepts authenticated users (rejects daemons)
pub struct AuthenticatedUser(pub Uuid);

impl<S> FromRequestParts<S> for AuthenticatedUser
where
    S: Send + Sync + AsRef<AppState>,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let entity = AuthenticatedEntity::from_request_parts(parts, state).await?;

        match entity {
            AuthenticatedEntity::User(user_id) => Ok(AuthenticatedUser(user_id)),
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
            AuthenticatedEntity::User(_) => Err(AuthError(ApiError::unauthorized(
                "Daemon authentication required".to_string(),
            ))),
        }
    }
}
