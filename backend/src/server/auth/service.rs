use crate::server::{
    auth::types::api::{LoginRequest, RegisterRequest, SessionUser},
    users::{
        service::UserService,
        types::base::{User, UserBase},
    },
};
use anyhow::{Result, anyhow};
use argon2::{
    Argon2,
    password_hash::{PasswordHash, PasswordHasher, PasswordVerifier, SaltString, rand_core::OsRng},
};
use std::{
    collections::HashMap,
    sync::Arc,
    time::{Duration, Instant},
};
use tokio::sync::RwLock;
use uuid::Uuid;
use validator::Validate;

pub struct AuthService {
    user_service: Arc<UserService>,
    login_attempts: Arc<RwLock<HashMap<String, (u32, Instant)>>>,
    sessions: Arc<RwLock<HashMap<String, SessionData>>>, // session_id -> session data
}

#[derive(Debug, Clone)]
struct SessionData {
    pub user_id: Uuid,
    pub username: String,
    pub last_accessed: Instant,
    pub remember_me: bool,
}

impl AuthService {
    const MAX_LOGIN_ATTEMPTS: u32 = 5;
    const LOCKOUT_DURATION_SECS: u64 = 15 * 60; // 15 minutes
    const SESSION_DURATION_SECS: u64 = 24 * 60 * 60; // 24 hours
    const SESSION_DURATION_REMEMBER_SECS: u64 = 30 * 24 * 60 * 60; // 30 days

    pub fn new(user_service: Arc<UserService>) -> Self {
        Self {
            user_service,
            login_attempts: Arc::new(RwLock::new(HashMap::new())),
            sessions: Arc::new(RwLock::new(HashMap::new())),
        }
    }

    /// Register a new user and create a session
    /// Returns (User, session_id)
    pub async fn register(&self, request: RegisterRequest) -> Result<(User, String)> {
        // Validate request
        tracing::debug!("Registry request received: {:?}", request);
        request
            .validate()
            .map_err(|e| anyhow!("Validation failed: {}", e))?;

        // Get all users
        let all_users = self.user_service.get_all_users().await?;

        // Check if name already taken by a user with a password
        let name_exists = all_users.iter().any(|u| {
            u.base.username.to_lowercase() == request.username.to_lowercase()
                && u.base.password_hash.is_some()
        });

        if name_exists {
            return Err(anyhow!("Name already taken"));
        }

        // Get seed user
        let seed_user: Option<User> = all_users
            .iter()
            .find(|u| u.base.password_hash.is_none())
            .cloned();

        let user = if let Some(mut seed_user) = seed_user {
            tracing::info!("First registration - claiming seed user: {}", seed_user.id);

            // Update the seed user with credentials
            seed_user.base.username = request.username.clone();
            seed_user.set_password(hash_password(&request.password)?);

            self.user_service.update_user(seed_user).await?
        } else {
            // No legacy users - create new user with password
            let new_user = User::new(UserBase::new(
                request.username,
                hash_password(&request.password)?,
            ));

            self.user_service.create_user(new_user).await?
        };

        // Create session
        let session_id = self.create_session(&user, false).await?;

        tracing::info!("User {} registered successfully", user.id);
        Ok((user, session_id))
    }

    /// Login with name and password
    /// Returns (User, session_id)
    pub async fn login(&self, request: LoginRequest) -> Result<(User, String)> {
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
                // Success - clear attempts and create session
                self.login_attempts.write().await.remove(&request.name);
                let session_id = self.create_session(&user, request.remember_me).await?;
                Ok((user.clone(), session_id))
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

    /// Create a new session for a user
    /// Returns session_id
    async fn create_session(&self, user: &User, remember_me: bool) -> Result<String> {
        let session_id = Uuid::new_v4().to_string();
        let now = Instant::now();

        let session_data = SessionData {
            user_id: user.id,
            username: user.base.username.clone(),
            last_accessed: now,
            remember_me,
        };

        self.sessions
            .write()
            .await
            .insert(session_id.clone(), session_data);

        tracing::debug!("Created session {} for user {}", session_id, user.id);
        Ok(session_id)
    }

    /// Validate a session and return the associated user
    /// Updates last_accessed time and checks expiration
    pub async fn validate_session(&self, session_id: &str) -> Result<SessionUser> {
        let mut sessions = self.sessions.write().await;

        let session = sessions
            .get_mut(session_id)
            .ok_or_else(|| anyhow!("Invalid or expired session"))?;

        // Check if session has expired
        let max_age = if session.remember_me {
            Duration::from_secs(Self::SESSION_DURATION_REMEMBER_SECS)
        } else {
            Duration::from_secs(Self::SESSION_DURATION_SECS)
        };

        if session.last_accessed.elapsed() > max_age {
            sessions.remove(session_id);
            return Err(anyhow!("Session expired"));
        }

        // Update last accessed time
        session.last_accessed = Instant::now();

        Ok(SessionUser {
            user_id: session.user_id,
            name: session.username.clone(),
        })
    }

    /// Logout - destroy session
    pub async fn logout(&self, session_id: &str) -> Result<()> {
        if self.sessions.write().await.remove(session_id).is_some() {
            tracing::info!("Session {} logged out", session_id);
            Ok(())
        } else {
            Err(anyhow!("Session not found"))
        }
    }

    /// Cleanup expired sessions (called periodically from background task in server bin)
    pub async fn cleanup_expired_sessions(&self) {
        let mut sessions = self.sessions.write().await;
        let now = Instant::now();

        let expired: Vec<String> = sessions
            .iter()
            .filter_map(|(id, session)| {
                let max_age = if session.remember_me {
                    Duration::from_secs(Self::SESSION_DURATION_REMEMBER_SECS)
                } else {
                    Duration::from_secs(Self::SESSION_DURATION_SECS)
                };

                if now.duration_since(session.last_accessed) > max_age {
                    Some(id.clone())
                } else {
                    None
                }
            })
            .collect();

        for id in expired {
            sessions.remove(&id);
            tracing::debug!("Cleaned up expired session {}", id);
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
        // Get user by name (case-insensitive)
        let all_users = self.user_service.get_all_users().await?;
        let user = all_users
            .iter()
            .find(|u| u.base.username.to_lowercase() == request.name.to_lowercase())
            .ok_or_else(|| anyhow!("Invalid name or password"))?;

        // Check if user has a password set
        let password_hash = user
            .base
            .password_hash
            .as_ref()
            .ok_or_else(|| anyhow!("User has no password set. Please register first."))?;

        // Verify password
        verify_password(&request.password, password_hash)?;

        tracing::info!("User {} logged in successfully", user.id);
        Ok(user.clone())
    }

    /// Get user by name
    pub async fn get_user_by_name(&self, name: &str) -> Result<Option<User>> {
        let all_users = self.user_service.get_all_users().await?;
        Ok(all_users
            .iter()
            .find(|u| u.base.username.to_lowercase() == name.to_lowercase())
            .cloned())
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
        .map_err(|_| anyhow!("Invalid name or password"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_password_hashing() {
        let password = "MySecureP@ssw0rd123";
        let hash = hash_password(password).unwrap();

        assert!(verify_password(password, &hash).is_ok());
        assert!(verify_password("WrongPassword", &hash).is_err());
    }
}
