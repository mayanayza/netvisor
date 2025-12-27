use std::fmt::Display;

use crate::server::shared::{
    entities::ChangeTriggersTopologyStaleness,
    storage::traits::{SqlValue, StorableEntity},
};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::Row;
use sqlx::postgres::PgRow;
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

/// Share display options
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash, ToSchema)]
pub struct ShareOptions {
    #[schema(required)]
    pub show_inspect_panel: bool,
    #[schema(required)]
    pub show_zoom_controls: bool,
    #[schema(required)]
    pub show_export_button: bool,
}

impl Default for ShareOptions {
    fn default() -> Self {
        Self {
            show_inspect_panel: true,
            show_zoom_controls: true,
            show_export_button: true,
        }
    }
}

#[derive(
    Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema, Validate,
)]
pub struct ShareBase {
    pub topology_id: Uuid,
    pub network_id: Uuid,
    pub created_by: Uuid,
    pub name: String,
    pub is_enabled: bool,
    #[schema(required)]
    pub expires_at: Option<DateTime<Utc>>,
    /// Password hash - never sent to client, never accept from client
    #[serde(skip)]
    pub password_hash: Option<String>,
    #[schema(required)]
    pub allowed_domains: Option<Vec<String>>,
    pub options: ShareOptions,
}

#[derive(
    Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema, Validate,
)]
pub struct Share {
    #[serde(default)]
    #[schema(read_only, required)]
    pub id: Uuid,
    #[serde(default)]
    #[schema(read_only, required)]
    pub created_at: DateTime<Utc>,
    #[serde(default)]
    #[schema(read_only, required)]
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    #[validate(nested)]
    pub base: ShareBase,
}

impl Display for Share {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Share {} ({})", self.id, self.base.name)
    }
}

impl Share {
    /// Check if the share is currently valid (enabled and not expired)
    pub fn is_valid(&self) -> bool {
        if !self.base.is_enabled {
            return false;
        }
        if let Some(expires_at) = self.base.expires_at
            && Utc::now() > expires_at
        {
            return false;
        }
        true
    }

    /// Check if this share requires a password
    pub fn requires_password(&self) -> bool {
        self.base.password_hash.is_some()
    }

    /// Check if this share has domain restrictions configured
    pub fn has_domain_restrictions(&self) -> bool {
        self.base
            .allowed_domains
            .as_ref()
            .is_some_and(|d| !d.is_empty())
    }
}

impl ChangeTriggersTopologyStaleness<Share> for Share {
    fn triggers_staleness(&self, _other: Option<Share>) -> bool {
        false
    }
}

impl StorableEntity for Share {
    type BaseData = ShareBase;

    fn table_name() -> &'static str {
        "shares"
    }

    fn get_base(&self) -> Self::BaseData {
        self.base.clone()
    }

    fn network_id(&self) -> Option<Uuid> {
        Some(self.base.network_id)
    }

    fn organization_id(&self) -> Option<Uuid> {
        None
    }

    fn new(base: Self::BaseData) -> Self {
        let now = Utc::now();
        Self {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base,
        }
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

    fn set_id(&mut self, id: Uuid) {
        self.id = id;
    }

    fn set_created_at(&mut self, time: DateTime<Utc>) {
        self.created_at = time;
    }

    fn set_updated_at(&mut self, time: DateTime<Utc>) {
        self.updated_at = time;
    }

    fn to_params(&self) -> Result<(Vec<&'static str>, Vec<SqlValue>), anyhow::Error> {
        Ok((
            vec![
                "id",
                "topology_id",
                "network_id",
                "created_by",
                "name",
                "is_enabled",
                "expires_at",
                "password_hash",
                "allowed_domains",
                "options",
                "created_at",
                "updated_at",
            ],
            vec![
                SqlValue::Uuid(self.id),
                SqlValue::Uuid(self.base.topology_id),
                SqlValue::Uuid(self.base.network_id),
                SqlValue::Uuid(self.base.created_by),
                SqlValue::String(self.base.name.clone()),
                SqlValue::Bool(self.base.is_enabled),
                SqlValue::OptionTimestamp(self.base.expires_at),
                SqlValue::OptionalString(self.base.password_hash.clone()),
                SqlValue::OptionalStringArray(self.base.allowed_domains.clone()),
                SqlValue::JsonValue(serde_json::to_value(&self.base.options)?),
                SqlValue::Timestamp(self.created_at),
                SqlValue::Timestamp(self.updated_at),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        let options_value: serde_json::Value = row.get("options");
        let options: ShareOptions = serde_json::from_value(options_value)?;

        Ok(Share {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: ShareBase {
                topology_id: row.get("topology_id"),
                network_id: row.get("network_id"),
                created_by: row.get("created_by"),
                name: row.get("name"),
                is_enabled: row.get("is_enabled"),
                expires_at: row.get("expires_at"),
                password_hash: row.get("password_hash"),
                allowed_domains: row.get("allowed_domains"),
                options,
            },
        })
    }
}
