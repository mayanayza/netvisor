use std::fmt::Display;
use std::str::FromStr;

use crate::server::{
    shared::storage::traits::{SqlValue, StorableEntity},
    users::r#impl::permissions::UserOrgPermissions,
};
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
    pub organization_id: Uuid,
    pub permissions: UserOrgPermissions,
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
            permissions: UserOrgPermissions::Owner,
            organization_id: Uuid::new_v4(),
            password_hash: None,
            oidc_linked_at: None,
            oidc_provider: None,
            oidc_subject: None,
        }
    }
}

impl UserBase {
    pub fn new_seed(organization_id: Uuid) -> Self {
        Self {
            email: EmailAddress::new_unchecked(format!("{}@netvisor.io", Uuid::new_v4())),
            permissions: UserOrgPermissions::Owner,
            organization_id,
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
        organization_id: Uuid,
        permissions: UserOrgPermissions,
    ) -> Self {
        Self {
            email,
            password_hash: None,
            oidc_linked_at: Some(Utc::now()),
            permissions,
            organization_id,
            oidc_provider,
            oidc_subject: Some(oidc_subject),
        }
    }

    pub fn new_password(
        email: EmailAddress,
        password_hash: String,
        organization_id: Uuid,
        permissions: UserOrgPermissions,
    ) -> Self {
        Self {
            email,
            password_hash: Some(password_hash),
            organization_id,
            permissions,
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
                    permissions,
                    organization_id,
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
                "permissions",
                "organization_id",
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
                SqlValue::UserOrgPermissions(permissions),
                SqlValue::Uuid(organization_id),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        let email = EmailAddress::from_str(&row.get::<String, _>("email"))
            .map_err(|e| Error::msg(format!("Failed to parse email: {}", e)))?;

        let permissions: UserOrgPermissions =
            serde_json::from_str(&row.get::<String, _>("permissions"))
                .or(Err(Error::msg("Failed to deserialize permissions")))?;

        Ok(User {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: UserBase {
                email,
                password_hash: row.get("password_hash"),
                permissions,
                organization_id: row.get("organization_id"),
                oidc_linked_at: row.get("oidc_linked_at"),
                oidc_provider: row.get("oidc_provider"),
                oidc_subject: row.get("oidc_subject"),
            },
        })
    }
}
