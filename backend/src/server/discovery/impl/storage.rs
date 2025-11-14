use chrono::{DateTime, Utc};
use sqlx::Row;
use sqlx::postgres::PgRow;
use uuid::Uuid;

use crate::server::{
    discovery::r#impl::{
        base::{Discovery, DiscoveryBase},
        types::{DiscoveryType, RunType},
    },
    shared::storage::traits::{SqlValue, StorableEntity},
};

impl StorableEntity for Discovery {
    type BaseData = DiscoveryBase;

    fn table_name() -> &'static str {
        "discovery"
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
                    discovery_type,
                    run_type,
                    name,
                    daemon_id,
                    network_id,
                },
        } = self.clone();

        Ok((
            vec![
                "id",
                "created_at",
                "updated_at",
                "name",
                "network_id",
                "daemon_id",
                "run_type",
                "discovery_type",
            ],
            vec![
                SqlValue::Uuid(id),
                SqlValue::Timestamp(created_at),
                SqlValue::Timestamp(updated_at),
                SqlValue::String(name),
                SqlValue::Uuid(network_id),
                SqlValue::Uuid(daemon_id),
                SqlValue::RunType(run_type),
                SqlValue::DiscoveryType(discovery_type),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        let discovery_type: DiscoveryType =
            serde_json::from_value(row.get::<serde_json::Value, _>("discovery_type"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize discovery_type: {}", e))?;

        let run_type: RunType = serde_json::from_value(row.get::<serde_json::Value, _>("run_type"))
            .map_err(|e| anyhow::anyhow!("Failed to deserialize run_type: {}", e))?;

        Ok(Discovery {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: DiscoveryBase {
                daemon_id: row.get("daemon_id"),
                name: row.get("name"),
                network_id: row.get("network_id"),
                run_type,
                discovery_type,
            },
        })
    }
}
