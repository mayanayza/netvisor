use crate::server::{
    auth::r#impl::api::{LoginRequest, RegisterRequest},
    organizations::{
        r#impl::base::{Organization, OrganizationBase},
        service::OrganizationService,
    },
    shared::{
        services::traits::CrudService,
        storage::{filter::EntityFilter, traits::StorableEntity},
    },
    users::{
        r#impl::base::{User, UserOrgPermissions},
        service::UserService,
    },
};
use anyhow::{Result, anyhow};
use argon2::{
    Argon2,
    password_hash::{PasswordHash, PasswordHasher, PasswordVerifier, SaltString, rand_core::OsRng},
};
use email_address::EmailAddress;
use std::{collections::HashMap, sync::Arc, time::Instant};
use tokio::sync::RwLock;
use uuid::Uuid;
use validator::Validate;

pub struct AuthService {
    pub user_service: Arc<UserService>,
    organization_service: Arc<OrganizationService>,
    login_attempts: Arc<RwLock<HashMap<EmailAddress, (u32, Instant)>>>,
}

impl AuthService {
    const MAX_LOGIN_ATTEMPTS: u32 = 5;
    const LOCKOUT_DURATION_SECS: u64 = 15 * 60; // 15 minutes

    pub fn new(
        user_service: Arc<UserService>,
        organization_service: Arc<OrganizationService>,
    ) -> Self {
        Self {
            user_service,
            organization_service,
            login_attempts: Arc::new(RwLock::new(HashMap::new())),
        }
    }

    /// Register a new user with password
    pub async fn register(&self, request: RegisterRequest) -> Result<User> {
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

        // Provision user with password
        self.provision_user(
            request.email,
            Some(hash_password(&request.password)?),
            None,
            None,
            request.organization_id,
            request.permissions,
        )
        .await
    }

    /// Register a new user with OIDC
    pub async fn register_with_oidc(
        &self,
        email: EmailAddress,
        oidc_subject: String,
        oidc_provider: String,
        organization_id: Option<Uuid>,
        permissions: Option<UserOrgPermissions>,
    ) -> Result<User> {
        // Provision user with OIDC
        self.provision_user(
            email,
            None,
            Some(oidc_subject),
            Some(oidc_provider),
            organization_id,
            permissions,
        )
        .await
    }

    /// Core user provisioning logic - handles both password and OIDC registration
    async fn provision_user(
        &self,
        email: EmailAddress,
        password_hash: Option<String>,
        oidc_subject: Option<String>,
        oidc_provider: Option<String>,
        organization_id: Option<Uuid>,
        permissions: Option<UserOrgPermissions>,
    ) -> Result<User> {
        let all_users = self
            .user_service
            .get_all(EntityFilter::unfiltered())
            .await?;

        // Find seed user (only exists if NO users have been created yet)
        let seed_user: Option<User> = all_users
            .iter()
            .find(|u| u.base.password_hash.is_none() && u.base.oidc_subject.is_none())
            .cloned();

        if let Some(mut seed_user) = seed_user {
            // First user ever - claim seed user
            tracing::info!("First user registration - claiming seed user");
            seed_user.base.email = email;

            if let Some(hash) = password_hash {
                seed_user.set_password(hash);
            }

            if let Some(subject) = oidc_subject {
                seed_user.base.oidc_subject = Some(subject);
                seed_user.base.oidc_provider = oidc_provider;
                seed_user.base.oidc_linked_at = Some(chrono::Utc::now());
            }

            self.user_service.update(&mut seed_user).await
        } else {
            // Not first user - create new user with or without org
            let org_id = if let Some(org_id) = organization_id {
                org_id
            } else {
                // Create new organization for this user
                let organization = self
                    .organization_service
                    .create(Organization::new(OrganizationBase {
                        stripe_customer_id: None,
                        name: "My Organization".to_string(),
                        plan: None,
                        plan_status: None,
                    }))
                    .await?;
                organization.id
            };

            // Create user based on auth method
            if let Some(hash) = password_hash {
                self.user_service
                    .create_user_with_password(email, hash, org_id, permissions)
                    .await
            } else if let Some(subject) = oidc_subject {
                self.user_service
                    .create_user_with_oidc(email, subject, oidc_provider, org_id, permissions)
                    .await
            } else {
                Err(anyhow!("Must provide either password or OIDC credentials"))
            }
        }
    }

    /// Login with username and password
    pub async fn login(&self, request: LoginRequest) -> Result<User> {
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
                tracing::info!("User {} logged in successfully", user.id);
                Ok(user)
            }
            Err(e) => {
                // Failure - increment attempts
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
