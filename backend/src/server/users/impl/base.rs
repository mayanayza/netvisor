use std::fmt::Display;

use crate::server::shared::storage::traits::{SqlValue, StorableEntity};
use anyhow::{Error, Result};
use chrono::{DateTime, Utc};
use email_address::EmailAddress;
use serde::{Deserialize, Serialize};
use sqlx::Row;
use sqlx::postgres::PgRow;
use uuid::Uuid;
use validator::Validate;

#[derive(Debug, Clone, Serialize, Deserialize, Validate)]
pub struct UserBase {
    pub email: EmailAddress,
    /// Password hash - None for legacy users created before auth migration or users using OIDC
    #[serde(skip_serializing)] // Never send password hash to client
    pub password_hash: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub oidc_provider: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub oidc_subject: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub oidc_linked_at: Option<DateTime<Utc>>,
}

impl Default for UserBase {
    fn default() -> Self {
        Self {
            email: EmailAddress::new_unchecked("user@example.com"),
            password_hash: None,
            oidc_linked_at: None,
            oidc_provider: None,
            oidc_subject: None,
        }
    }
}

impl UserBase {
    pub fn new_seed() -> Self {
        Self {
            email: EmailAddress::new_unchecked("user@example.com"),
            password_hash: None,
            oidc_linked_at: None,
            oidc_provider: None,
            oidc_subject: None,
        }
    }

    pub fn new_oidc(
        email: EmailAddress,
        oidc_subject: String,
        oidc_provider: Option<String>,
    ) -> Self {
        Self {
            email,
            password_hash: None,
            oidc_linked_at: Some(Utc::now()),
            oidc_provider,
            oidc_subject: Some(oidc_subject),
        }
    }

    pub fn new_password(email: EmailAddress, password_hash: String) -> Self {
        Self {
            email,
            password_hash: Some(password_hash),
            oidc_linked_at: None,
            oidc_provider: None,
            oidc_subject: None,
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
        write!(f, "{}: {}", self.base.email, self.id)
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
                    email,
                    password_hash,
                    oidc_linked_at,
                    oidc_provider,
                    oidc_subject,
                },
        } = self.clone();

        Ok((
            vec![
                "id",
                "email",
                "password_hash",
                "created_at",
                "updated_at",
                "oidc_linked_at",
                "oidc_provider",
                "oidc_subject",
            ],
            vec![
                SqlValue::Uuid(id),
                SqlValue::Email(email),
                SqlValue::OptionalString(password_hash),
                SqlValue::Timestamp(created_at),
                SqlValue::Timestamp(updated_at),
                SqlValue::OptionTimestamp(oidc_linked_at),
                SqlValue::OptionalString(oidc_provider),
                SqlValue::OptionalString(oidc_subject),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        let email: EmailAddress = serde_json::from_str(&row.get::<String, _>("email"))
            .or(Err(Error::msg("Failed to deserialize email")))?;

        Ok(User {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: UserBase {
                email,
                password_hash: row.get("password_hash"),
                oidc_linked_at: row.get("oidc_linked_at"),
                oidc_provider: row.get("oidc_provider"),
                oidc_subject: row.get("oidc_subject"),
            },
        })
    }
}
