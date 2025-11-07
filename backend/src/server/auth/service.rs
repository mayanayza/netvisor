use crate::server::{
    auth::r#impl::api::{LoginRequest, RegisterRequest},
    shared::{
        services::traits::CrudService,
        storage::{filter::EntityFilter, traits::StorableEntity},
    },
    users::{
        r#impl::base::{User, UserBase},
        service::UserService,
    },
};
use anyhow::{Result, anyhow};
use argon2::{
    Argon2,
    password_hash::{PasswordHash, PasswordHasher, PasswordVerifier, SaltString, rand_core::OsRng},
};
use std::{collections::HashMap, sync::Arc, time::Instant};
use tokio::sync::RwLock;
use validator::Validate;

pub struct AuthService {
    user_service: Arc<UserService>,
    login_attempts: Arc<RwLock<HashMap<String, (u32, Instant)>>>,
}

impl AuthService {
    const MAX_LOGIN_ATTEMPTS: u32 = 5;
    const LOCKOUT_DURATION_SECS: u64 = 15 * 60; // 15 minutes

    pub fn new(user_service: Arc<UserService>) -> Self {
        Self {
            user_service,
            login_attempts: Arc::new(RwLock::new(HashMap::new())),
        }
    }

    /// Register a new user
    /// Returns User (session management handled by tower-sessions)
    pub async fn register(&self, request: RegisterRequest) -> Result<User> {
        // Validate request
        request
            .validate()
            .map_err(|e| anyhow!("Validation failed: {}", e))?;

        // Get all users
        let all_users = self
            .user_service
            .get_all(EntityFilter::unfiltered())
            .await?;

        // Check if username already taken by a user with a password
        let username_exists = all_users.iter().any(|u| {
            u.base.username.to_lowercase() == request.username.to_lowercase()
                && u.base.password_hash.is_some()
        });

        if username_exists {
            return Err(anyhow!("Username already taken"));
        }

       // Find seed user (only exists if NO users have been created yet)
        let seed_user: Option<User> = all_users
            .iter()
            .find(|u| {
                u.base.password_hash.is_none() 
                && u.base.oidc_subject.is_none()
            })
            .cloned();

        let user = if let Some(mut seed_user) = seed_user {
            // First user ever - claim seed user
            tracing::info!("First user registration - claiming seed user");
            seed_user.base.username = request.username.clone();
            seed_user.base.name = request.username.clone();
            seed_user.set_password(hash_password(&request.password)?);
            self.user_service.update(&mut seed_user).await?
        } else {
            // Not first user - create new user + network
            let new_user = User::new(UserBase::new_password(
                request.username,
                hash_password(&request.password)?
            ));
            let (user, _) = self.user_service.create_user(new_user).await?;
            user
        };

        tracing::info!("User {} registered successfully", user.id);
        Ok(user)
    }

    /// Login with username and password
    /// Returns User (session management handled by tower-sessions)
    pub async fn login(&self, request: LoginRequest) -> Result<User> {
        tracing::debug!("Login request received: {:?}", request);

        // Validate request
        request
            .validate()
            .map_err(|e| anyhow!("Validation failed: {}", e))?;

        // Check if account is locked due to too many failed attempts
        self.check_login_lockout(&request.name).await?;

        // Attempt login
        let result = self.try_login(&request).await;

        // Update login attempts based on result
        match result {
            Ok(user) => {
                // Success - clear attempts
                self.login_attempts.write().await.remove(&request.name);
                tracing::info!("User {} logged in successfully", user.id);
                Ok(user)
            }
            Err(e) => {
                // Failure - increment attempts
                let mut attempts = self.login_attempts.write().await;
                let entry = attempts
                    .entry(request.name.clone())
                    .or_insert((0, Instant::now()));
                entry.0 += 1;
                entry.1 = Instant::now();
                Err(e)
            }
        }
    }

    /// Check if user is locked out due to too many login attempts
    async fn check_login_lockout(&self, name: &str) -> Result<()> {
        let attempts = self.login_attempts.read().await;
        if let Some((count, last_attempt)) = attempts.get(name)
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
        // Get user by username (case-insensitive)
        let all_users = self
            .user_service
            .get_all(EntityFilter::unfiltered())
            .await?;
        let user = all_users
            .iter()
            .find(|u| u.base.username.to_lowercase() == request.name.to_lowercase())
            .ok_or_else(|| anyhow!("Invalid username or password"))?;

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

    /// Get user by username
    pub async fn get_user_by_name(&self, name: &str) -> Result<Option<User>> {
        let all_users = self
            .user_service
            .get_all(EntityFilter::unfiltered())
            .await?;
        Ok(all_users
            .iter()
            .find(|u| u.base.username.to_lowercase() == name.to_lowercase())
            .cloned())
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
fn hash_password(password: &str) -> Result<String> {
    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();

    let hash = argon2
        .hash_password(password.as_bytes(), &salt)
        .map_err(|e| anyhow!("Password hashing failed: {}", e))?
        .to_string();

    Ok(hash)
}

/// Verify a password against a hash
fn verify_password(password: &str, hash: &str) -> Result<()> {
    let parsed_hash =
        PasswordHash::new(hash).map_err(|e| anyhow!("Invalid password hash: {}", e))?;

    Argon2::default()
        .verify_password(password.as_bytes(), &parsed_hash)
        .map_err(|_| anyhow!("Invalid username or password"))
}
