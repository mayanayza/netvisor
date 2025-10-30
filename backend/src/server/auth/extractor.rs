use crate::server::shared::types::api::ApiError;
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

/// Simple extractor - validates authentication and extracts user_id
pub struct AuthenticatedUser {
    pub user_id: Uuid,
}

impl<S> FromRequestParts<S> for AuthenticatedUser
where
    S: Send + Sync,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        // Extract session
        let session = match Session::from_request_parts(parts, state).await {
            Ok(s) => s,
            Err(_) => return Err(AuthError(ApiError::internal_error("Failed to get session"))),
        };

        // Get user_id from session
        let user_id: Uuid = match session.get("user_id").await {
            Ok(Some(id)) => id,
            Ok(None) => {
                return Err(AuthError(ApiError::unauthorized(
                    "Not authenticated".to_string(),
                )));
            }
            Err(_) => {
                return Err(AuthError(ApiError::internal_error(
                    "Failed to read session",
                )));
            }
        };

        Ok(AuthenticatedUser { user_id })
    }
}
