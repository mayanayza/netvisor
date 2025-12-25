use email_address::EmailAddress;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

/// Login request from client
#[derive(Debug, Clone, Serialize, Deserialize, Validate, ToSchema)]
pub struct LoginRequest {
    #[schema(value_type = String, format = "email")]
    pub email: EmailAddress,

    #[validate(length(min = 10, message = "Password must be at least 10 characters"))]
    pub password: String,
}

/// Registration request from client
#[derive(Debug, Clone, Serialize, Deserialize, Validate, ToSchema)]
pub struct RegisterRequest {
    #[schema(value_type = String, format = "email")]
    pub email: EmailAddress,

    #[validate(length(min = 10, message = "Password must be at least 10 characters"))]
    #[validate(custom(function = "validate_password_complexity"))]
    pub password: String,
    pub terms_accepted: bool,
}

/// Validate password complexity requirements
fn validate_password_complexity(password: &str) -> Result<(), validator::ValidationError> {
    let has_uppercase = password.chars().any(|c| c.is_uppercase());
    let has_lowercase = password.chars().any(|c| c.is_lowercase());
    let has_digit = password.chars().any(|c| c.is_numeric());

    if !has_uppercase || !has_lowercase || !has_digit {
        let mut err = validator::ValidationError::new("password_complexity");
        err.message = Some("Password must contain uppercase, lowercase, and number".into());
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

#[derive(Debug, Deserialize, ToSchema)]
pub struct UpdateEmailPasswordRequest {
    pub password: Option<String>,
    #[schema(value_type = Option<String>, format = "email")]
    pub email: Option<EmailAddress>,
}

#[derive(Debug, Deserialize)]
pub struct OidcAuthorizeParams {
    pub flow: Option<String>, // "login", "register", or "link"
    pub return_url: Option<String>,
    pub terms_accepted: Option<bool>,
}

#[derive(Debug, Deserialize, ToSchema)]
pub struct ForgotPasswordRequest {
    #[schema(value_type = String, format = "email")]
    pub email: EmailAddress,
}

#[derive(Debug, Deserialize, ToSchema)]
pub struct ResetPasswordRequest {
    pub token: String,
    pub password: String,
}

/// Network configuration for setup
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct NetworkSetup {
    pub name: String,
}

/// Setup request for pre-registration org/network configuration
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct SetupRequest {
    pub organization_name: String,
    pub networks: Vec<NetworkSetup>,
}

/// Response from setup endpoint
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct SetupResponse {
    pub network_ids: Vec<Uuid>,
}

/// Daemon setup request for pre-registration daemon configuration
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct DaemonSetupRequest {
    pub daemon_name: String,
    pub network_id: Uuid,
    #[serde(default)]
    pub install_later: bool,
}

/// Response from daemon setup endpoint
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct DaemonSetupResponse {
    pub api_key: Option<String>,
}
