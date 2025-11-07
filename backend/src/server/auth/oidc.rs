use anyhow::Result;
use openidconnect::{
    reqwest::Client as ReqwestClient,
    core::{CoreClient, CoreProviderMetadata, CoreResponseType},
    AuthenticationFlow, AuthorizationCode, ClientId, ClientSecret, CsrfToken, IssuerUrl,
    Nonce, PkceCodeChallenge, PkceCodeVerifier, RedirectUrl, Scope, TokenResponse,
};
use serde::{Deserialize, Serialize};

#[derive(Clone)]
pub struct OidcClient {
    issuer_url: String,
    client_id: String,
    client_secret: String,
    redirect_url: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct OidcUserInfo {
    pub subject: String,
    pub email: Option<String>,
    pub name: Option<String>,
}

// Store this in tower-sessions
#[derive(Debug, Serialize, Deserialize)]
pub struct OidcPendingAuth {
    pub pkce_verifier: String,
    pub nonce: String,
    pub csrf_token: String,
}

impl OidcClient {
    pub fn new(
        issuer_url: String,
        client_id: String,
        client_secret: String,
        redirect_url: String,
    ) -> Self {
        Self {
            issuer_url,
            client_id,
            client_secret,
            redirect_url,
        }
    }

    /// Generate authorization URL for user to visit
    /// Returns: (auth_url, pending_auth to store in session)
    pub async fn authorize_url(&self) -> Result<(String, OidcPendingAuth)> {
        let http_client = ReqwestClient::builder()
            .redirect(reqwest::redirect::Policy::none())
            .build()?;

        let provider_metadata = CoreProviderMetadata::discover_async(
            IssuerUrl::new(self.issuer_url.clone())?,
            &http_client,
        )
        .await?;

        let client = CoreClient::from_provider_metadata(
            provider_metadata,
            ClientId::new(self.client_id.clone()),
            Some(ClientSecret::new(self.client_secret.clone())),
        )
        .set_redirect_uri(RedirectUrl::new(self.redirect_url.clone())?);

        let (pkce_challenge, pkce_verifier) = PkceCodeChallenge::new_random_sha256();

        let (auth_url, csrf_token, nonce) = client
            .authorize_url(
                AuthenticationFlow::<CoreResponseType>::AuthorizationCode,
                CsrfToken::new_random,
                Nonce::new_random,
            )
            .add_scope(Scope::new("openid".to_string()))
            .add_scope(Scope::new("email".to_string()))
            .add_scope(Scope::new("profile".to_string()))
            .set_pkce_challenge(pkce_challenge)
            .url();

        let pending_auth = OidcPendingAuth {
            pkce_verifier: pkce_verifier.secret().clone(),
            nonce: nonce.secret().clone(),
            csrf_token: csrf_token.secret().clone(),
        };

        Ok((auth_url.to_string(), pending_auth))
    }

    /// Exchange authorization code for user info
    pub async fn exchange_code(
        &self,
        code: &str,
        pending_auth: OidcPendingAuth,
    ) -> Result<OidcUserInfo> {
        let http_client = ReqwestClient::builder()
            .redirect(reqwest::redirect::Policy::none())
            .build()?;

        let provider_metadata = CoreProviderMetadata::discover_async(
            IssuerUrl::new(self.issuer_url.clone())?,
            &http_client,
        )
        .await?;

        let client = CoreClient::from_provider_metadata(
            provider_metadata,
            ClientId::new(self.client_id.clone()),
            Some(ClientSecret::new(self.client_secret.clone())),
        )
        .set_redirect_uri(RedirectUrl::new(self.redirect_url.clone())?);

        let pkce_verifier = PkceCodeVerifier::new(pending_auth.pkce_verifier);
        let nonce = Nonce::new(pending_auth.nonce);

        let token_response = client
            .exchange_code(AuthorizationCode::new(code.to_string()))?
            .set_pkce_verifier(pkce_verifier)
            .request_async(&http_client)
            .await?;

        let id_token = token_response
            .id_token()
            .ok_or_else(|| anyhow::anyhow!("No ID token in response"))?;

        let claims = id_token.claims(&client.id_token_verifier(), &nonce)?;

        Ok(OidcUserInfo {
            subject: claims.subject().to_string(),
            email: claims.email().map(|e| e.to_string()),
            name: claims.name().and_then(|n| n.get(None).map(|s| s.to_string())),
        })
    }
}