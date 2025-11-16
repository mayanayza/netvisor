use anyhow::{Error, Result, anyhow};
use email_address::EmailAddress;
use openidconnect::{
    AuthenticationFlow, AuthorizationCode, ClientId, ClientSecret, CsrfToken, IssuerUrl, Nonce,
    PkceCodeChallenge, PkceCodeVerifier, RedirectUrl, Scope, TokenResponse,
    core::{CoreClient, CoreProviderMetadata, CoreResponseType},
    reqwest::Client as ReqwestClient,
};
use serde::{Deserialize, Serialize};
use std::{str::FromStr, sync::Arc};
use uuid::Uuid;

use crate::server::{
    auth::service::AuthService,
    users::r#impl::{base::User, permissions::UserOrgPermissions},
};

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

#[derive(Clone)]
pub struct OidcService {
    issuer_url: String,
    client_id: String,
    client_secret: String,
    redirect_url: String,
    provider_name: String,
    auth_service: Arc<AuthService>,
}

impl OidcService {
    pub fn new(
        issuer_url: String,
        client_id: String,
        client_secret: String,
        redirect_url: String,
        provider_name: String,
        auth_service: Arc<AuthService>,
    ) -> Self {
        Self {
            issuer_url,
            client_id,
            client_secret,
            redirect_url,
            provider_name,
            auth_service,
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
    async fn exchange_code(
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
            name: claims
                .name()
                .and_then(|n| n.get(None).map(|s| s.to_string())),
        })
    }

    /// Link OIDC account to existing user
    pub async fn link_to_user(
        &self,
        user_id: &Uuid,
        code: &str,
        pending_auth: OidcPendingAuth,
    ) -> Result<User> {
        let user_info = self.exchange_code(code, pending_auth).await?;

        // Check if this OIDC account is already linked to another user
        if let Some(existing_user) = self
            .auth_service
            .user_service
            .get_user_by_oidc(&user_info.subject)
            .await?
        {
            if existing_user.id != *user_id {
                return Err(anyhow!(
                    "This OIDC account is already linked to another user"
                ));
            }
            // Already linked to this user
            return Ok(existing_user);
        }

        // Link OIDC to current user
        self.auth_service
            .user_service
            .link_oidc(user_id, user_info.subject, self.provider_name.clone())
            .await
    }

    /// Login or register user via OIDC
    pub async fn login_or_register(
        &self,
        code: &str,
        pending_auth: OidcPendingAuth,
        org_id: Option<Uuid>,
        permissions: Option<UserOrgPermissions>,
    ) -> Result<User> {
        let user_info = self.exchange_code(code, pending_auth).await?;

        // Check if user exists with this OIDC account
        if let Some(user) = self
            .auth_service
            .user_service
            .get_user_by_oidc(&user_info.subject)
            .await?
        {
            return Ok(user);
        }

        // Parse or create fallback email
        let fallback_email_str = format!("user{}@example.com", &user_info.subject[..8]);
        let email_str = user_info
            .email
            .clone()
            .unwrap_or_else(|| fallback_email_str.clone());

        let email = EmailAddress::from_str(&email_str).or_else(|_| {
            Ok::<EmailAddress, Error>(EmailAddress::new_unchecked(fallback_email_str))
        })?;

        // Register new user via OIDC
        self.auth_service
            .register_with_oidc(
                email,
                user_info.subject,
                self.provider_name.clone(),
                org_id,
                permissions,
            )
            .await
    }

    /// Unlink OIDC from user
    pub async fn unlink_from_user(&self, user_id: &Uuid) -> Result<User> {
        self.auth_service.user_service.unlink_oidc(user_id).await
    }
}
