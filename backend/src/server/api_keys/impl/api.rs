use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

use crate::server::api_keys::r#impl::base::ApiKey;

#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct ApiKeyResponse {
    pub api_key: ApiKey,
    pub key: String,
}
