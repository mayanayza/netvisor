use chrono::{DateTime, Utc};
use sqlx::Row;
use sqlx::postgres::PgRow;
use uuid::Uuid;

use crate::server::{
    daemons::r#impl::{
        api::DaemonCapabilities,
        base::{Daemon, DaemonBase, DaemonMode},
    },
    shared::storage::traits::{SqlValue, StorableEntity},
};

impl StorableEntity for Daemon {
    type BaseData = DaemonBase;

    fn table_name() -> &'static str {
        "daemons"
    }

    fn network_id(&self) -> Option<Uuid> {
        Some(self.base.network_id)
    }

    fn organization_id(&self) -> Option<Uuid> {
        None
    }

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
        let Self {
            id,
            created_at,
            updated_at,
            base:
                Self::BaseData {
                    network_id,
                    host_id,
                    capabilities,
                    last_seen,
                    mode,
                    url,
                    name,
                    tags,
                },
        } = self.clone();

        Ok((
            vec![
                "id",
                "created_at",
                "updated_at",
                "last_seen",
                "network_id",
                "host_id",
                "capabilities",
                "url",
                "name",
                "mode",
                "tags",
            ],
            vec![
                SqlValue::Uuid(id),
                SqlValue::Timestamp(created_at),
                SqlValue::Timestamp(updated_at),
                SqlValue::Timestamp(last_seen),
                SqlValue::Uuid(network_id),
                SqlValue::Uuid(host_id),
                SqlValue::DaemonCapabilities(capabilities),
                SqlValue::String(url),
                SqlValue::String(name),
                SqlValue::DaemonMode(mode),
                SqlValue::UuidArray(tags),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        let mode: DaemonMode = serde_json::from_str(&row.get::<String, _>("mode"))
            .map_err(|e| anyhow::anyhow!("Failed to deserialize mode: {}", e))?;

        let capabilities: DaemonCapabilities =
            serde_json::from_value(row.get::<serde_json::Value, _>("capabilities"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize capabilities: {}", e))?;

        Ok(Daemon {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: DaemonBase {
                url: row.get("url"),
                last_seen: row.get("last_seen"),
                host_id: row.get("host_id"),
                network_id: row.get("network_id"),
                name: row.get("name"),
                mode,
                capabilities,
                tags: row.get("tags"),
            },
        })
    }
}
