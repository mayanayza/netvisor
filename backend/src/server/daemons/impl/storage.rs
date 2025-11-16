use chrono::{DateTime, Utc};
use sqlx::Row;
use sqlx::postgres::PgRow;
use std::net::IpAddr;
use uuid::Uuid;

use crate::server::{
    daemons::r#impl::{
        api::DaemonCapabilities,
        base::{Daemon, DaemonBase},
    },
    shared::storage::traits::{SqlValue, StorableEntity},
};

impl StorableEntity for Daemon {
    type BaseData = DaemonBase;

    fn table_name() -> &'static str {
        "daemons"
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
                    network_id,
                    host_id,
                    ip,
                    port,
                    capabilities,
                    last_seen,
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
                "port",
                "ip",
            ],
            vec![
                SqlValue::Uuid(id),
                SqlValue::Timestamp(created_at),
                SqlValue::Timestamp(updated_at),
                SqlValue::Timestamp(last_seen),
                SqlValue::Uuid(network_id),
                SqlValue::Uuid(host_id),
                SqlValue::DaemonCapabilities(capabilities),
                SqlValue::U16(port),
                SqlValue::IpAddr(ip),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        let ip: IpAddr = serde_json::from_str(&row.get::<String, _>("ip"))
            .map_err(|e| anyhow::anyhow!("Failed to deserialize IP: {}", e))?;

        let capabilities: DaemonCapabilities =
            serde_json::from_value(row.get::<serde_json::Value, _>("capabilities"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize capabilities: {}", e))?;

        Ok(Daemon {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: DaemonBase {
                ip,
                port: row.get::<i32, _>("port").try_into().unwrap(),
                last_seen: row.get("last_seen"),
                host_id: row.get("host_id"),
                network_id: row.get("network_id"),
                capabilities,
            },
        })
    }
}
