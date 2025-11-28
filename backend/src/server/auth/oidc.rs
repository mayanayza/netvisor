use anyhow::{Error, Result, anyhow};
use bad_email::is_email_unwanted;
use chrono::Utc;
use email_address::EmailAddress;
use std::{collections::HashMap, net::IpAddr, str::FromStr, sync::Arc};
use uuid::Uuid;

use crate::server::{
    auth::{
        r#impl::{
            base::{LoginRegisterParams, ProvisionUserParams},
            oidc::{OidcPendingAuth, OidcProvider, OidcProviderConfig, OidcProviderMetadata},
        },
        middleware::AuthenticatedEntity,
        service::AuthService,
    },
    shared::{
        events::{
            bus::EventBus,
            types::{AuthEvent, AuthOperation},
        },
        services::traits::CrudService,
    },
    users::{r#impl::base::User, service::UserService},
};

pub struct OidcService {
    providers: HashMap<String, Arc<OidcProvider>>,
    auth_service: Arc<AuthService>,
    user_service: Arc<UserService>,
    event_bus: Arc<EventBus>,
}

impl OidcService {
    pub fn new(
        configs: Vec<OidcProviderConfig>,
        public_url: &str,
        auth_service: Arc<AuthService>,
        user_service: Arc<UserService>,
        event_bus: Arc<EventBus>,
    ) -> Self {
        let mut providers = HashMap::new();

        for config in configs {
            // Build provider-specific callback URL
            let redirect_url = format!("{}/api/auth/oidc/{}/callback", public_url, config.slug);

            let provider = OidcProvider::new(
                config.slug.clone(),
                config.name.clone(),
                config.logo.clone(),
                config.issuer_url.clone(),
                config.client_id.clone(),
                config.client_secret.clone(),
                redirect_url,
            );

            providers.insert(config.slug.clone(), Arc::new(provider));
        }

        Self {
            providers,
            auth_service,
            user_service,
            event_bus,
        }
    }

    pub fn get_provider(&self, slug: &str) -> Option<&Arc<OidcProvider>> {
        self.providers.get(slug)
    }

    pub fn list_providers(&self) -> Vec<OidcProviderMetadata> {
        self.providers
            .values()
            .map(|provider| OidcProviderMetadata {
                name: provider.name.clone(),
                slug: provider.slug.clone(),
                logo: provider.logo.clone(),
            })
            .collect()
    }

    pub fn is_empty(&self) -> bool {
        self.providers.is_empty()
    }

    /// Register new user via OIDC (fails if account already exists)
    pub async fn register(
        &self,
        provider_slug: &str,
        code: &str,
        pending_auth: OidcPendingAuth,
        params: LoginRegisterParams,
    ) -> Result<User> {
        let provider = self
            .get_provider(provider_slug)
            .ok_or_else(|| anyhow!("Provider '{}' not found", provider_slug))?;

        let LoginRegisterParams {
            org_id,
            permissions,
            ip,
            user_agent,
            network_ids,
            subscribed,
        } = params;

        // Exchange code for user info using provider
        let user_info = provider.exchange_code(code, &pending_auth).await?;

        // Check if user already exists with this OIDC account
        if let Some(_existing_user) = self
            .user_service
            .get_user_by_oidc(&user_info.subject)
            .await?
        {
            return Err(anyhow!(
                "An account with this {} login already exists. Please use the login flow instead.",
                provider.name
            ));
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

        if is_email_unwanted(email.as_str()) {
            return Err(anyhow!(
                "Email address uses a disposable domain. Please register with a non-disposable email address."
            ));
        }

        // Register new user
        let user = self
            .auth_service
            .provision_user(ProvisionUserParams {
                email,
                password_hash: None,
                oidc_subject: Some(user_info.subject),
                oidc_provider: Some(provider.slug.clone()),
                org_id,
                permissions,
                network_ids,
                subscribed,
            })
            .await?;

        // Publish event
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
                    "provider": provider.slug,
                    "provider_name": provider.name
                }),
                authentication: user.clone().into(),
            })
            .await?;

        Ok(user)
    }

    /// Login existing user via OIDC (fails if account doesn't exist)
    pub async fn login(
        &self,
        provider_slug: &str,
        code: &str,
        pending_auth: OidcPendingAuth,
        ip: IpAddr,
        user_agent: Option<String>,
    ) -> Result<User> {
        let provider = self
            .get_provider(provider_slug)
            .ok_or_else(|| anyhow!("Provider '{}' not found", provider_slug))?;

        // Exchange code for user info using provider
        let user_info = provider.exchange_code(code, &pending_auth).await?;

        // Check if user exists with this OIDC account
        let user = self
            .user_service
            .get_user_by_oidc(&user_info.subject)
            .await?
            .ok_or_else(|| {
                anyhow!(
                    "No account found with this {} login. Please register first.",
                    provider.name
                )
            })?;

        // Publish event
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
                    "provider": provider.slug,
                    "provider_name": provider.name
                }),
                authentication: user.clone().into(),
            })
            .await?;

        Ok(user)
    }

    /// Link OIDC account to existing user
    pub async fn link_to_user(
        &self,
        provider_slug: &str,
        user_id: &Uuid,
        code: &str,
        pending_auth: OidcPendingAuth,
        ip: IpAddr,
        user_agent: Option<String>,
    ) -> Result<User> {
        let provider = self
            .get_provider(provider_slug)
            .ok_or_else(|| anyhow!("Provider '{}' not found", provider_slug))?;

        // Exchange code for user info using provider
        let user_info = provider.exchange_code(code, &pending_auth).await?;

        // Check if this OIDC account is already linked to another user
        if let Some(existing_user) = self
            .user_service
            .get_user_by_oidc(&user_info.subject)
            .await?
        {
            if existing_user.id != *user_id {
                return Err(anyhow!(
                    "This {} account is already linked to another user",
                    provider.name
                ));
            }
            // Already linked to this user
            return Ok(existing_user);
        }

        // Get and update user
        let mut user = self
            .user_service
            .get_by_id(user_id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("User not found"))?;

        // ERROR if user already has a different OIDC provider linked
        if let Some(existing_provider) = &user.base.oidc_provider
            && existing_provider != provider_slug
        {
            let existing_provider_name = self
                .get_provider(existing_provider)
                .map(|p| p.name.as_str())
                .unwrap_or(existing_provider);

            return Err(anyhow!(
                "You already have {} linked to your account. Please unlink it first before linking {}.",
                existing_provider_name,
                provider.name
            ));
        }

        user.base.oidc_provider = Some(provider.slug.clone());
        user.base.oidc_subject = Some(user_info.subject);
        user.base.oidc_linked_at = Some(chrono::Utc::now());

        let authentication: AuthenticatedEntity = user.clone().into();

        // Publish event
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
                    "provider": provider.slug,
                    "provider_name": provider.name
                }),
                authentication: authentication.clone(),
            })
            .await?;

        self.user_service.update(&mut user, authentication).await
    }

    /// Unlink OIDC from user
    pub async fn unlink_from_user(
        &self,
        provider_slug: &str,
        user_id: &Uuid,
        ip: IpAddr,
        user_agent: Option<String>,
    ) -> Result<User> {
        let provider = self
            .get_provider(provider_slug)
            .ok_or_else(|| anyhow!("Provider '{}' not found", provider_slug))?;

        // Get user
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

        // Publish event
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
                    "provider": provider.slug,
                    "provider_name": provider.name
                }),
                authentication: authentication.clone(),
            })
            .await?;

        self.user_service.update(&mut user, authentication).await
    }
}
