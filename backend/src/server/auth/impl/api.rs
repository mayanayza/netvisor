use std::sync::LazyLock;

use regex::Regex;
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use validator::Validate;

static USERNAME_REGEX: LazyLock<Regex> = LazyLock::new(|| Regex::new(r"^[a-zA-Z0-9_]+$").unwrap());

/// Login request from client
/// Note: 'name' is used as the username
#[derive(Debug, Clone, Serialize, Deserialize, Validate)]
pub struct LoginRequest {
    #[validate(length(min = 3, max = 50, message = "Name must be 3-50 characters"))]
    pub name: String,

    #[validate(length(min = 12, message = "Password must be at least 12 characters"))]
    pub password: String,
}

/// Registration request from client
/// Note: 'name' is used as the username
#[derive(Debug, Clone, Serialize, Deserialize, Validate)]
pub struct RegisterRequest {
    #[validate(length(min = 3, max = 50, message = "Name must be 3-50 characters"))]
    #[validate(regex(
        path = "USERNAME_REGEX",
        message = "Name can only contain letters, numbers, and underscores"
    ))]
    pub username: String,

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