use axum::{Json, http::StatusCode, response::Response};
use serde::{Deserialize, Deserializer, Serialize, Serializer, de::DeserializeOwned};
use utoipa::ToSchema;

pub type ApiResult<T> = Result<T, ApiError>;

#[derive(Debug, Serialize, Deserialize, ToSchema)]
pub struct ApiResponse<T> {
    pub success: bool,
    pub data: Option<T>,
    pub error: Option<String>,
}

pub type EmptyApiResponse = ApiResponse<()>;

/// Error response type for API errors (no data field)
#[derive(Debug, Serialize, Deserialize, ToSchema)]
pub struct ApiErrorResponse {
    pub success: bool,
    pub error: Option<String>,
}

impl<T> ApiResponse<T> {
    pub fn success(data: T) -> Self {
        Self {
            success: true,
            data: Some(data),
            error: None,
        }
    }

    pub fn error(message: String) -> Self {
        Self {
            success: false,
            data: None,
            error: Some(message),
        }
    }
}

#[derive(Debug)]
pub struct ApiError {
    pub status: StatusCode,
    pub message: String,
}

impl ApiError {
    pub fn new(status: StatusCode, message: String) -> Self {
        Self { status, message }
    }

    pub fn conflict(message: &str) -> Self {
        Self::new(StatusCode::CONFLICT, message.to_string())
    }

    pub fn forbidden(message: &str) -> Self {
        Self::new(StatusCode::FORBIDDEN, message.to_string())
    }

    pub fn internal_error(message: &str) -> Self {
        Self::new(StatusCode::INTERNAL_SERVER_ERROR, message.to_string())
    }

    pub fn bad_request(message: &str) -> Self {
        Self::new(StatusCode::BAD_REQUEST, message.to_string())
    }

    pub fn not_found(message: String) -> Self {
        Self::new(StatusCode::NOT_FOUND, message.to_string())
    }

    pub fn unauthorized(message: String) -> Self {
        Self::new(StatusCode::UNAUTHORIZED, message.to_string())
    }

    pub fn bad_gateway(message: String) -> Self {
        Self::new(StatusCode::BAD_GATEWAY, message.to_string())
    }

    pub fn too_many_requests(message: String) -> Self {
        Self::new(StatusCode::TOO_MANY_REQUESTS, message.to_string())
    }

    pub fn payment_required(message: &str) -> Self {
        Self::new(StatusCode::PAYMENT_REQUIRED, message.to_string())
    }
}

impl axum::response::IntoResponse for ApiError {
    fn into_response(self) -> Response {
        let response = ApiResponse::<()>::error(self.message);
        (self.status, Json(response)).into_response()
    }
}

impl From<anyhow::Error> for ApiError {
    fn from(err: anyhow::Error) -> Self {
        tracing::error!("Internal error: {}", err);
        Self::internal_error(&err.to_string())
    }
}

impl From<sqlx::Error> for ApiError {
    fn from(err: sqlx::Error) -> Self {
        tracing::error!("Database error: {}", err);
        match err {
            sqlx::Error::RowNotFound => Self::not_found("Row not found".to_string()),
            _ => Self::internal_error("Database operation failed"),
        }
    }
}

impl From<serde_json::Error> for ApiError {
    fn from(err: serde_json::Error) -> Self {
        tracing::error!("JSON serialization error: {}", err);
        Self::bad_request("Invalid JSON data")
    }
}

pub trait EmptyToOption<T> {
    fn empty_to_option(self) -> Option<T>;
}

// Implement for common types that can be "empty"
impl EmptyToOption<String> for String {
    fn empty_to_option(self) -> Option<String> {
        if self.is_empty() { None } else { Some(self) }
    }
}

impl EmptyToOption<String> for Option<String> {
    fn empty_to_option(self) -> Option<String> {
        match self {
            Some(s) if s.is_empty() => None,
            other => other,
        }
    }
}

impl<T> EmptyToOption<Vec<T>> for Vec<T> {
    fn empty_to_option(self) -> Option<Vec<T>> {
        if self.is_empty() { None } else { Some(self) }
    }
}

pub fn serialize_sensitive_info<S>(_key: &String, serializer: S) -> Result<S::Ok, S::Error>
where
    S: Serializer,
{
    serializer.serialize_str("**********")
}

pub fn serialize_optional_sensitive_info<S>(
    _key: &Option<String>,
    serializer: S,
) -> Result<S::Ok, S::Error>
where
    S: Serializer,
{
    serializer.serialize_str("**********")
}

pub fn deserialize_empty_string_as_none<'de, D>(deserializer: D) -> Result<Option<String>, D::Error>
where
    D: Deserializer<'de>,
{
    let opt = Option::<String>::deserialize(deserializer)?;
    Ok(opt.and_then(|s| if s.is_empty() { None } else { Some(s) }))
}

pub fn deserialize_empty_vec_as_none<'de, D, T>(deserializer: D) -> Result<Option<Vec<T>>, D::Error>
where
    D: Deserializer<'de>,
    T: DeserializeOwned,
{
    let opt = Option::<Vec<T>>::deserialize(deserializer)?;
    Ok(opt.and_then(|vec| if vec.is_empty() { None } else { Some(vec) }))
}
