use crate::server::shared::events::types::TelemetryOperation;
use crate::server::{
    auth::{
        r#impl::{
            api::{LoginRequest, RegisterRequest},
            base::{LoginRegisterParams, PendingSetup, ProvisionUserParams},
        },
        middleware::auth::{AuthenticatedEntity, AuthenticatedUser},
    },
    email::traits::EmailService,
    organizations::{
        r#impl::base::{Organization, OrganizationBase},
        service::OrganizationService,
    },
    shared::{
        events::{
            bus::EventBus,
            types::{AuthEvent, AuthOperation, TelemetryEvent},
        },
        services::traits::CrudService,
        storage::{filter::EntityFilter, traits::StorableEntity},
    },
    users::{
        r#impl::{
            base::{User, UserBase},
            permissions::UserOrgPermissions,
        },
        service::UserService,
    },
};
use anyhow::{Result, anyhow};
use argon2::{
    Argon2,
    password_hash::{PasswordHash, PasswordHasher, PasswordVerifier, SaltString, rand_core::OsRng},
};
use chrono::Utc;
use email_address::EmailAddress;
use std::{collections::HashMap, net::IpAddr, sync::Arc, time::Instant};
use tokio::sync::RwLock;
use uuid::Uuid;
use validator::Validate;

pub struct AuthService {
    pub user_service: Arc<UserService>,
    organization_service: Arc<OrganizationService>,
    email_service: Option<Arc<EmailService>>,
    login_attempts: Arc<RwLock<HashMap<EmailAddress, (u32, Instant)>>>,
    password_reset_tokens: Arc<RwLock<HashMap<String, (Uuid, Instant)>>>,
    event_bus: Arc<EventBus>,
}

impl AuthService {
    const MAX_LOGIN_ATTEMPTS: u32 = 5;
    const LOCKOUT_DURATION_SECS: u64 = 15 * 60; // 15 minutes

    pub fn new(
        user_service: Arc<UserService>,
        organization_service: Arc<OrganizationService>,
        email_service: Option<Arc<EmailService>>,
        event_bus: Arc<EventBus>,
    ) -> Self {
        Self {
            user_service,
            organization_service,
            email_service,
            login_attempts: Arc::new(RwLock::new(HashMap::new())),
            password_reset_tokens: Arc::new(RwLock::new(HashMap::new())),
            event_bus,
        }
    }

    /// Register a new user with password
    pub async fn register(
        &self,
        request: RegisterRequest,
        params: LoginRegisterParams,
        pending_setup: Option<PendingSetup>,
        billing_enabled: bool,
    ) -> Result<User> {
        let LoginRegisterParams {
            org_id,
            permissions,
            ip,
            user_agent,
            network_ids,
        } = params;

        request
            .validate()
            .map_err(|e| anyhow!("Validation failed: {}", e))?;

        // Check if email already taken
        let all_users = self
            .user_service
            .get_all(EntityFilter::unfiltered())
            .await?;

        if all_users.iter().any(|u| u.base.email == request.email) {
            return Err(anyhow!("Email address already taken"));
        }

        let terms_accepted_at = if request.terms_accepted {
            Some(Utc::now())
        } else {
            None
        };

        // Provision user with password
        let user = self
            .provision_user(
                ProvisionUserParams {
                    email: request.email,
                    password_hash: Some(hash_password(&request.password)?),
                    oidc_subject: None,
                    oidc_provider: None,
                    org_id,
                    permissions,
                    network_ids,
                    terms_accepted_at,
                    billing_enabled,
                },
                pending_setup,
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
                    "method": "password",
                    "subscribed": request.subscribed
                }),
                authentication: user.clone().into(),
            })
            .await?;

        Ok(user)
    }

    /// Core user provisioning logic - handles both password and OIDC registration
    /// If pending_setup is provided, uses setup.org_name and marks OnboardingModalCompleted
    /// If billing_enabled is false (self-hosted), sets default billing plan
    pub async fn provision_user(
        &self,
        params: ProvisionUserParams,
        pending_setup: Option<PendingSetup>,
    ) -> Result<User> {
        let ProvisionUserParams {
            email,
            password_hash,
            oidc_subject,
            oidc_provider,
            org_id,
            permissions,
            network_ids,
            terms_accepted_at,
            billing_enabled,
        } = params;

        let mut is_new_org = false;

        // If being invited, use provided org ID, otherwise create a new one
        let organization_id = if let Some(org_id) = org_id {
            org_id
        } else {
            is_new_org = true;

            // Use org name from setup if provided, otherwise default
            let org_name = pending_setup
                .as_ref()
                .map(|s| s.org_name.clone())
                .unwrap_or_else(|| "My Organization".to_string());

            // Mark OnboardingModalCompleted if setup was provided (pre-registration setup flow)
            let onboarding = if pending_setup.is_some() {
                vec![TelemetryOperation::OnboardingModalCompleted]
            } else {
                vec![]
            };

            // Set billing plan if billing is disabled (self-hosted)
            let plan = if !billing_enabled {
                Some(crate::server::billing::types::base::BillingPlan::default())
            } else {
                None
            };

            // Create new organization for this user
            let organization = self
                .organization_service
                .create(
                    Organization::new(OrganizationBase {
                        stripe_customer_id: None,
                        name: org_name,
                        plan,
                        plan_status: None,
                        onboarding,
                    }),
                    AuthenticatedEntity::System,
                )
                .await?;
            organization.id
        };

        // If being invited, will have permissions (default to None in case permissions were lost for some reason); otherwise, new user and should be owner of org
        let permissions = if is_new_org {
            UserOrgPermissions::Owner
        } else {
            permissions.unwrap_or(UserOrgPermissions::None)
        };

        // Create user based on auth method
        let user = if let Some(hash) = password_hash {
            Ok(self
                .user_service
                .create(
                    User::new(UserBase::new_password(
                        email,
                        hash,
                        organization_id,
                        permissions,
                        network_ids,
                        terms_accepted_at,
                    )),
                    AuthenticatedEntity::System,
                )
                .await?)
        } else if let Some(oidc_subject) = oidc_subject {
            Ok(self
                .user_service
                .create(
                    User::new(UserBase::new_oidc(
                        email,
                        oidc_subject,
                        oidc_provider,
                        organization_id,
                        permissions,
                        network_ids,
                        terms_accepted_at,
                    )),
                    AuthenticatedEntity::System,
                )
                .await?)
        } else {
            Err(anyhow!("Must provide either password or OIDC credentials"))
        }?;

        if is_new_org {
            self.event_bus
                .publish_telemetry(TelemetryEvent {
                    id: Uuid::new_v4(),
                    authentication: user.clone().into(),
                    organization_id: user.base.organization_id,
                    operation: TelemetryOperation::OrgCreated,
                    timestamp: Utc::now(),
                    metadata: serde_json::json!({}),
                })
                .await?;
        }

        Ok(user)
    }

    /// Login with username and password
    pub async fn login(
        &self,
        request: LoginRequest,
        ip: IpAddr,
        user_agent: Option<String>,
    ) -> Result<User> {
        request
            .validate()
            .map_err(|e| anyhow!("Validation failed: {}", e))?;

        // Check if account is locked due to too many failed attempts
        self.check_login_lockout(&request.email).await?;

        // Attempt login
        let result = self.try_login(&request).await;

        // Update login attempts based on result
        match result {
            Ok(user) => {
                // Success - clear attempts
                self.login_attempts.write().await.remove(&request.email);

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
                            "method": "password",
                        }),
                        authentication: user.clone().into(),
                    })
                    .await?;

                Ok(user)
            }
            Err(e) => {
                // Failure - increment attempts

                self.event_bus
                    .publish_auth(AuthEvent {
                        id: Uuid::new_v4(),
                        user_id: None,
                        organization_id: None,
                        timestamp: Utc::now(),
                        operation: AuthOperation::LoginFailed,
                        ip_address: ip,
                        user_agent,
                        metadata: serde_json::json!({
                            "method": "password",
                            "email": request.email
                        }),
                        authentication: AuthenticatedEntity::Anonymous,
                    })
                    .await?;

                let mut attempts = self.login_attempts.write().await;
                let entry = attempts
                    .entry(request.email.clone())
                    .or_insert((0, Instant::now()));
                entry.0 += 1;
                entry.1 = Instant::now();
                Err(e)
            }
        }
    }

    /// Check if user is locked out due to too many login attempts
    async fn check_login_lockout(&self, email: &EmailAddress) -> Result<()> {
        let attempts = self.login_attempts.read().await;
        if let Some((count, last_attempt)) = attempts.get(email)
            && *count >= Self::MAX_LOGIN_ATTEMPTS
        {
            let elapsed = last_attempt.elapsed().as_secs();
            if elapsed < Self::LOCKOUT_DURATION_SECS {
                let remaining = (Self::LOCKOUT_DURATION_SECS - elapsed) / 60;
                return Err(anyhow!(
                    "Too many failed login attempts. Try again in {} minutes.",
                    remaining + 1
                ));
            }
        }
        Ok(())
    }

    /// Attempt login without rate limiting
    async fn try_login(&self, request: &LoginRequest) -> Result<User> {
        // Get user by email
        let all_users = self
            .user_service
            .get_all(EntityFilter::unfiltered())
            .await?;

        let user = all_users
            .iter()
            .find(|u| u.base.email == request.email)
            .ok_or_else(|| anyhow!("Invalid email or password"))?;

        // Check if user has a password set
        let password_hash = user
            .base
            .password_hash
            .as_ref()
            .ok_or_else(|| anyhow!("User has no password set. Please register first."))?;

        // Verify password
        verify_password(&request.password, password_hash)?;

        Ok(user.clone())
    }

    pub async fn update_password(
        &self,
        user_id: Uuid,
        password: Option<String>,
        email: Option<EmailAddress>,
        ip: IpAddr,
        user_agent: Option<String>,
        authentication: AuthenticatedUser,
    ) -> Result<User> {
        let mut user = self
            .user_service
            .get_by_id(&user_id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("User not found".to_string()))?;

        if let Some(password) = password {
            user.set_password(hash_password(&password)?);
        }

        if let Some(email) = email {
            user.base.email = email
        }

        self.event_bus
            .publish_auth(AuthEvent {
                id: Uuid::new_v4(),
                user_id: Some(user.id),
                organization_id: Some(user.base.organization_id),
                timestamp: Utc::now(),
                operation: AuthOperation::PasswordChanged,
                ip_address: ip,
                user_agent,
                metadata: serde_json::json!({}),
                authentication: authentication.clone().into(),
            })
            .await?;

        self.user_service
            .update(&mut user, authentication.into())
            .await
    }

    /// Initiate password reset process - generates a token
    pub async fn initiate_password_reset(
        &self,
        email: &EmailAddress,
        url: String,
        ip: IpAddr,
        user_agent: Option<String>,
    ) -> Result<()> {
        let email_service = self
            .email_service
            .as_ref()
            .ok_or_else(|| anyhow!("Email service not configured"))?
            .clone();

        let all_users = self
            .user_service
            .get_all(EntityFilter::unfiltered())
            .await?;

        // Find user but don't expose if they exist or not
        let user = match all_users.iter().find(|u| &u.base.email == email) {
            Some(user) => user,
            None => {
                // User doesn't exist - but we still return Ok to prevent enumeration
                tracing::info!("Password reset requested for non-existent email");
                return Ok(());
            }
        };

        self.event_bus
            .publish_auth(AuthEvent {
                id: Uuid::new_v4(),
                user_id: Some(user.id),
                organization_id: Some(user.base.organization_id),
                timestamp: Utc::now(),
                operation: AuthOperation::PasswordResetRequested,
                ip_address: ip,
                user_agent,
                metadata: serde_json::json!({}),
                authentication: AuthenticatedEntity::Anonymous,
            })
            .await?;

        let token = Uuid::new_v4().to_string();
        let mut tokens = self.password_reset_tokens.write().await;
        tokens.insert(token.clone(), (user.id, Instant::now()));

        email_service
            .send_password_reset(user.base.email.clone(), url, token)
            .await?;

        Ok(())
    }

    /// Reset password using token
    pub async fn complete_password_reset(
        &self,
        token: &str,
        new_password: &str,
        ip: IpAddr,
        user_agent: Option<String>,
    ) -> Result<User> {
        let mut tokens = self.password_reset_tokens.write().await;
        let (user_id, created_at) = tokens
            .remove(token)
            .ok_or_else(|| anyhow!("Invalid or expired password reset token"))?;

        // Check if token is expired (valid for 1 hour)
        if created_at.elapsed().as_secs() > 3600 {
            return Err(anyhow!("Password reset token has expired"));
        }

        // Get user
        let mut user = self
            .user_service
            .get_by_id(&user_id)
            .await?
            .ok_or_else(|| anyhow!("User not found"))?;

        self.event_bus
            .publish_auth(AuthEvent {
                id: Uuid::new_v4(),
                user_id: Some(user.id),
                organization_id: Some(user.base.organization_id),
                timestamp: Utc::now(),
                operation: AuthOperation::PasswordResetCompleted,
                ip_address: ip,
                user_agent,
                metadata: serde_json::json!({}),
                authentication: user.clone().into(),
            })
            .await?;

        // Update password
        let hashed_password = hash_password(new_password)?;
        user.set_password(hashed_password);
        self.user_service
            .update(&mut user, AuthenticatedEntity::System)
            .await?;

        Ok(user.clone())
    }

    pub async fn logout(
        &self,
        user_id: Uuid,
        ip: IpAddr,
        user_agent: Option<String>,
    ) -> Result<()> {
        if let Ok(Some(user)) = self.user_service.get_by_id(&user_id).await {
            self.event_bus
                .publish_auth(AuthEvent {
                    id: Uuid::new_v4(),
                    user_id: Some(user.id),
                    organization_id: Some(user.base.organization_id),
                    timestamp: Utc::now(),
                    operation: AuthOperation::LoggedOut,
                    ip_address: ip,
                    user_agent,
                    metadata: serde_json::json!({}),
                    authentication: user.into(),
                })
                .await?;
        }

        Ok(())
    }

    /// Cleanup old login attempts (called periodically from background task)
    pub async fn cleanup_old_login_attempts(&self) {
        let mut attempts = self.login_attempts.write().await;

        attempts.retain(|_, (_, last_attempt)| {
            last_attempt.elapsed().as_secs() < Self::LOCKOUT_DURATION_SECS
        });

        tracing::debug!("Cleaned up old login attempts");
    }
}

/// Hash a password using Argon2id
pub fn hash_password(password: &str) -> Result<String> {
    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();

    let hash = argon2
        .hash_password(password.as_bytes(), &salt)
        .map_err(|e| anyhow!("Password hashing failed: {}", e))?
        .to_string();

    Ok(hash)
}

/// Verify a password against a hash
pub fn verify_password(password: &str, hash: &str) -> Result<()> {
    let parsed_hash =
        PasswordHash::new(hash).map_err(|e| anyhow!("Invalid password hash: {}", e))?;

    Argon2::default()
        .verify_password(password.as_bytes(), &parsed_hash)
        .map_err(|_| anyhow!("Invalid username or password"))
}
