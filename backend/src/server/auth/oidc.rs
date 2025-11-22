use anyhow::{Error, Result, anyhow};
use chrono::Utc;
use email_address::EmailAddress;
use openidconnect::{
    AuthenticationFlow, AuthorizationCode, ClientId, ClientSecret, CsrfToken, IssuerUrl, Nonce,
    PkceCodeChallenge, PkceCodeVerifier, RedirectUrl, Scope, TokenResponse,
    core::{CoreClient, CoreProviderMetadata, CoreResponseType},
    reqwest::Client as ReqwestClient,
};
use serde::{Deserialize, Serialize};
use std::{net::IpAddr, str::FromStr, sync::Arc};
use uuid::Uuid;

use crate::server::{
    auth::{middleware::AuthenticatedEntity, service::AuthService},
    shared::{
        events::{
            bus::EventBus,
            types::{AuthEvent, AuthOperation},
        },
        services::traits::CrudService,
    },
    users::{
        r#impl::{base::User, permissions::UserOrgPermissions},
        service::UserService,
    },
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
    pub issuer_url: String,
    pub client_id: String,
    pub client_secret: String,
    pub redirect_url: String,
    pub provider_name: String,
    pub auth_service: Arc<AuthService>,
    pub user_service: Arc<UserService>,
    pub event_bus: Arc<EventBus>,
}

impl OidcService {
    pub fn new(params: OidcService) -> Self {
        params
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
        ip: IpAddr,
        user_agent: Option<String>,
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

        let mut user = self
            .user_service
            .get_by_id(user_id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("User not found"))?;

        user.base.oidc_provider = Some(self.provider_name.clone());
        user.base.oidc_subject = Some(user_info.subject);
        user.base.oidc_linked_at = Some(chrono::Utc::now());

        let authentication: AuthenticatedEntity = user.clone().into();

        self.event_bus
            .publish_auth(AuthEvent {
                id: Uuid::new_v4(),
                user_id: Some(user.id),
                organization_id: Some(user.base.organization_id),
                timestamp: Utc::now(),
                operation: AuthOperation::OidcLinked,
                ip_address: ip,
                user_agent,
                metadata: serde_json::json!({
                    "method": "oidc",
                    "provider": self.provider_name
                }),
                authentication: authentication.clone(),
            })
            .await?;

        self.user_service.update(&mut user, authentication).await
    }

    /// Login or register user via OIDC
    pub async fn login_or_register(
        &self,
        code: &str,
        pending_auth: OidcPendingAuth,
        org_id: Option<Uuid>,
        permissions: Option<UserOrgPermissions>,
        ip: IpAddr,
        user_agent: Option<String>,
    ) -> Result<User> {
        let user_info = self.exchange_code(code, pending_auth).await?;

        // Check if user exists with this OIDC account, login if so
        if let Some(user) = self
            .auth_service
            .user_service
            .get_user_by_oidc(&user_info.subject)
            .await?
        {
            self.event_bus
                .publish_auth(AuthEvent {
                    id: Uuid::new_v4(),
                    user_id: Some(user.id),
                    organization_id: Some(user.base.organization_id),
                    timestamp: Utc::now(),
                    operation: AuthOperation::LoginSuccess,
                    ip_address: ip,
                    user_agent,
                    metadata: serde_json::json!({
                        "method": "oidc",
                        "provider": self.provider_name
                    }),
                    authentication: user.clone().into(),
                })
                .await?;

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

        // Register new user
        let user = self
            .auth_service
            .provision_user(
                email,
                None,
                Some(user_info.subject),
                Some(self.provider_name.clone()),
                org_id,
                permissions,
            )
            .await?;

        self.event_bus
            .publish_auth(AuthEvent {
                id: Uuid::new_v4(),
                user_id: Some(user.id),
                organization_id: Some(user.base.organization_id),
                timestamp: Utc::now(),
                operation: AuthOperation::Register,
                ip_address: ip,
                user_agent,
                metadata: serde_json::json!({
                    "method": "oidc",
                    "provider": self.provider_name
                }),
                authentication: user.clone().into(),
            })
            .await?;

        Ok(user)
    }

    /// Unlink OIDC from user
    pub async fn unlink_from_user(
        &self,
        user_id: &Uuid,
        ip: IpAddr,
        user_agent: Option<String>,
    ) -> Result<User> {
        let mut user = self
            .user_service
            .get_by_id(user_id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("User not found"))?;

        // Require password before unlinking
        if user.base.password_hash.is_none() {
            return Err(anyhow::anyhow!(
                "Cannot unlink OIDC - no password set. Set a password first."
            ));
        }

        user.base.oidc_provider = None;
        user.base.oidc_subject = None;
        user.base.oidc_linked_at = None;
        user.updated_at = chrono::Utc::now();

        let authentication: AuthenticatedEntity = user.clone().into();

        self.event_bus
            .publish_auth(AuthEvent {
                id: Uuid::new_v4(),
                user_id: Some(user.id),
                organization_id: Some(user.base.organization_id),
                timestamp: Utc::now(),
                operation: AuthOperation::OidcUnlinked,
                ip_address: ip,
                user_agent,
                metadata: serde_json::json!({
                    "method": "oidc",
                    "provider": self.provider_name
                }),
                authentication: authentication.clone(),
            })
            .await?;

        self.user_service.update(&mut user, authentication).await
    }
}
