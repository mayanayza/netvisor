use std::fmt::Display;

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use validator::Validate;

#[derive(Debug, Clone, Serialize, Deserialize, Validate)]
pub struct UserBase {
    #[validate(length(min = 0, max = 100))]
    pub name: String,
}

impl Default for UserBase {
    fn default() -> Self {
        Self {
            name: "Default Username".to_string(),
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
}

impl Display for User {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}: {}", self.base.name, self.id)
    }
}
