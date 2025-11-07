use std::fmt::Display;

use crate::server::shared::storage::traits::{SqlValue, StorableEntity};
use anyhow::Result;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::Row;
use sqlx::postgres::PgRow;
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

impl StorableEntity for User {
    type BaseData = UserBase;

    fn get_base(&self) -> Self::BaseData {
        self.base.clone()
    }

    fn new(base: Self::BaseData) -> Self {
        let now = chrono::Utc::now();

        Self {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base,
        }
    }

    fn table_name() -> &'static str {
        "users"
    }

    fn id(&self) -> Uuid {
        self.id
    }

    fn created_at(&self) -> DateTime<Utc> {
        self.created_at
    }

    fn updated_at(&self) -> DateTime<Utc> {
        self.updated_at
    }

    fn set_updated_at(&mut self, time: DateTime<Utc>) {
        self.updated_at = time;
    }

    fn to_params(&self) -> Result<(Vec<&'static str>, Vec<SqlValue>), anyhow::Error> {
        let Self {
            id,
            created_at,
            updated_at,
            base:
                Self::BaseData {
                    name,
                    username,
                    password_hash,
                },
        } = self.clone();

        Ok((
            vec![
                "id",
                "name",
                "username",
                "password_hash",
                "created_at",
                "updated_at",
            ],
            vec![
                SqlValue::Uuid(id),
                SqlValue::String(name),
                SqlValue::String(username),
                SqlValue::OptionalString(password_hash),
                SqlValue::Timestamp(created_at),
                SqlValue::Timestamp(updated_at),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        Ok(User {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: UserBase {
                name: row.get("name"),
                username: row.get("username"),
                password_hash: row.get("password_hash"),
            },
        })
    }
}
