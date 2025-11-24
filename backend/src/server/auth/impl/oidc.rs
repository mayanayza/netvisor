use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct OidcUserInfo {
    pub subject: String,
    pub email: Option<String>,
    pub name: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct OidcPendingAuth {
    pub pkce_verifier: String,
    pub nonce: String,
    pub csrf_token: String,
}
