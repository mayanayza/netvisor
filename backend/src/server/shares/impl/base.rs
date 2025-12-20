use std::fmt::Display;

use crate::server::shared::{
    entities::ChangeTriggersTopologyStaleness,
    storage::traits::{SqlValue, StorableEntity},
};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::Row;
use sqlx::postgres::PgRow;
use uuid::Uuid;

/// Share type: link (password-protected) or embed (domain-restricted)
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
#[serde(rename_all = "lowercase")]
pub enum ShareType {
    Link,
    Embed,
}

impl Display for ShareType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ShareType::Link => write!(f, "link"),
            ShareType::Embed => write!(f, "embed"),
        }
    }
}

impl std::str::FromStr for ShareType {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.to_lowercase().as_str() {
            "link" => Ok(ShareType::Link),
            "embed" => Ok(ShareType::Embed),
            _ => Err(anyhow::anyhow!("Invalid share type: {}", s)),
        }
    }
}

/// Embed display options
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct EmbedOptions {
    pub show_inspect_panel: bool,
    pub show_zoom_controls: bool,
}

impl Default for EmbedOptions {
    fn default() -> Self {
        Self {
            show_inspect_panel: true,
            show_zoom_controls: true,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct ShareBase {
    pub topology_id: Uuid,
    pub network_id: Uuid,
    pub created_by: Uuid,
    pub share_type: ShareType,
    pub name: String,
    pub has_password: bool,
    pub is_enabled: bool,
    pub expires_at: Option<DateTime<Utc>>,
    /// Password hash - never sent to client, stored internally
    #[serde(skip_serializing)]
    pub password_hash: Option<String>,
    pub allowed_domains: Option<Vec<String>>,
    pub embed_options: EmbedOptions,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct Share {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
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

    /// Check if this is a link share
    pub fn is_link_share(&self) -> bool {
        self.base.share_type == ShareType::Link
    }

    /// Check if this is an embed share
    pub fn is_embed_share(&self) -> bool {
        self.base.share_type == ShareType::Embed
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
                "share_type",
                "name",
                "is_enabled",
                "expires_at",
                "password_hash",
                "allowed_domains",
                "embed_options",
                "created_at",
                "updated_at",
            ],
            vec![
                SqlValue::Uuid(self.id),
                SqlValue::Uuid(self.base.topology_id),
                SqlValue::Uuid(self.base.network_id),
                SqlValue::Uuid(self.base.created_by),
                SqlValue::String(self.base.share_type.to_string()),
                SqlValue::String(self.base.name.clone()),
                SqlValue::Bool(self.base.is_enabled),
                SqlValue::OptionTimestamp(self.base.expires_at),
                SqlValue::OptionalString(self.base.password_hash.clone()),
                SqlValue::OptionalStringArray(self.base.allowed_domains.clone()),
                SqlValue::JsonValue(serde_json::to_value(&self.base.embed_options)?),
                SqlValue::Timestamp(self.created_at),
                SqlValue::Timestamp(self.updated_at),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        let share_type_str: String = row.get("share_type");
        let share_type: ShareType = share_type_str.parse()?;

        let embed_options_value: serde_json::Value = row.get("embed_options");
        let embed_options: EmbedOptions = serde_json::from_value(embed_options_value)?;
        let password_hash: Option<String> = row.get("password_hash");

        Ok(Share {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: {
                ShareBase {
                    topology_id: row.get("topology_id"),
                    network_id: row.get("network_id"),
                    created_by: row.get("created_by"),
                    share_type,
                    has_password: password_hash.is_some(),
                    name: row.get("name"),
                    is_enabled: row.get("is_enabled"),
                    expires_at: row.get("expires_at"),
                    password_hash,
                    allowed_domains: row.get("allowed_domains"),
                    embed_options,
                }
            },
        })
    }
}
