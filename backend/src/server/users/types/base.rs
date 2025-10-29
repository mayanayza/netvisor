use std::fmt::Display;

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use validator::Validate;

#[derive(Debug, Clone, Serialize, Deserialize, Validate)]
pub struct UserBase {
    #[validate(length(min = 0, max = 100))]
    pub name: String,
    #[validate(length(min = 0, max = 100))]
    #[serde(default)]
    pub username: String,
    /// Password hash - None for legacy users created before auth migration
    #[serde(skip_serializing)] // Never send password hash to client
    pub password_hash: Option<String>,
}

impl Default for UserBase {
    fn default() -> Self {
        Self {
            name: "Default Name".to_string(),
            username: "default-username".to_string(),
            password_hash: None,
        }
    }
}

impl UserBase {
    pub fn new_seed() -> Self {
        Self {
            name: "Username".to_string(),
            username: "default-username".to_string(),
            password_hash: None,
        }
    }

    pub fn new(username: String, password_hash: String) -> Self {
        Self {
            name: username.clone(),
            username,
            password_hash: Some(password_hash),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    pub base: UserBase,
}

impl User {
    pub fn new(base: UserBase) -> Self {
        let now = chrono::Utc::now();
        User {
            base,
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
        }
    }

    pub fn set_password(&mut self, password_hash: String) {
        self.base.password_hash = Some(password_hash);
        self.updated_at = Utc::now();
    }
}

impl Display for User {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}: {}", self.base.name, self.id)
    }
}
