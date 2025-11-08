use email_address::EmailAddress;
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use validator::Validate;

/// Login request from client
/// Note: 'name' is used as the username
#[derive(Debug, Clone, Serialize, Deserialize, Validate)]
pub struct LoginRequest {
    pub email: EmailAddress,

    #[validate(length(min = 12, message = "Password must be at least 12 characters"))]
    pub password: String,
}

/// Registration request from client
/// Note: 'name' is used as the username
#[derive(Debug, Clone, Serialize, Deserialize, Validate)]
pub struct RegisterRequest {
    pub email: EmailAddress,

    #[validate(length(min = 12, message = "Password must be at least 12 characters"))]
    #[validate(custom(function = "validate_password_complexity"))]
    pub password: String,
}

/// Validate password complexity requirements
fn validate_password_complexity(password: &str) -> Result<(), validator::ValidationError> {
    let has_uppercase = password.chars().any(|c| c.is_uppercase());
    let has_lowercase = password.chars().any(|c| c.is_lowercase());
    let has_digit = password.chars().any(|c| c.is_numeric());
    let has_special = password.chars().any(|c| !c.is_alphanumeric());

    if !has_uppercase || !has_lowercase || !has_digit || !has_special {
        let mut err = validator::ValidationError::new("password_complexity");
        err.message = Some(
            "Password must contain uppercase, lowercase, number, and special character".into(),
        );
        return Err(err);
    }

    Ok(())
}

/// Session user info (stored in session, not in database)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SessionUser {
    pub user_id: Uuid,
    pub name: String,
}

#[derive(Debug, Deserialize)]
pub struct OidcCallbackParams {
    pub code: String,
    pub state: String,
}

#[derive(Debug, Deserialize)]
pub struct SetPasswordRequest {
    pub password: String,
}

// Query params for authorize
#[derive(Debug, Deserialize)]
pub struct OidcAuthorizeParams {
    pub link: Option<bool>,
    pub return_url: Option<String>,
}
