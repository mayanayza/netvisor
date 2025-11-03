use crate::server::discovery::types::base::DiscoveryBase;
use anyhow::Error;
use anyhow::Result;
use async_trait::async_trait;
use chrono::DateTime;
use chrono::Utc;
use sqlx::{PgPool, Row};
use uuid::Uuid;

use crate::server::discovery::types::base::Discovery;
use crate::server::discovery::types::base::DiscoveryType;
use crate::server::discovery::types::base::RunType;

#[async_trait]
pub trait DiscoveryStorage: Send + Sync {
    async fn create(&self, discovery: &Discovery) -> Result<Discovery>;
    async fn get_by_id(&self, id: &Uuid) -> Result<Option<Discovery>>;
    async fn get_all(&self, network_ids: &[Uuid]) -> Result<Vec<Discovery>>;
    async fn update(&self, discovery: &Discovery) -> Result<Discovery>;
    async fn delete(&self, id: &Uuid) -> Result<()>;
    async fn get_all_scheduled(&self) -> Result<Vec<Discovery>>;
    async fn update_schedule_times(&self, id: &Uuid, last_run: DateTime<Utc>) -> Result<()>;
}

pub struct PostgresDiscoveryStorage {
    pool: PgPool,
}

impl PostgresDiscoveryStorage {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl DiscoveryStorage for PostgresDiscoveryStorage {
    async fn create(&self, discovery: &Discovery) -> Result<Discovery> {
        let discovery_type_json = serde_json::to_value(&discovery.base.discovery_type)?;
        let run_type_json = serde_json::to_value(&discovery.base.run_type)?;

        sqlx::query(
            r#"
            INSERT INTO discovery (
                id, discovery_type, run_type, name, daemon_id, created_at, updated_at, network_Id
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            "#,
        )
        .bind(discovery.id)
        .bind(discovery_type_json)
        .bind(run_type_json)
        .bind(&discovery.base.name)
        .bind(discovery.base.daemon_id)
        .bind(chrono::Utc::now())
        .bind(chrono::Utc::now())
        .bind(discovery.base.network_id)
        .execute(&self.pool)
        .await?;

        Ok(discovery.clone())
    }

    async fn get_by_id(&self, id: &Uuid) -> Result<Option<Discovery>> {
        let row = sqlx::query("SELECT * FROM discovery WHERE id = $1")
            .bind(id)
            .fetch_optional(&self.pool)
            .await?;

        match row {
            Some(row) => Ok(Some(row_to_discovery(row)?)),
            None => Ok(None),
        }
    }

    async fn get_all(&self, network_ids: &[Uuid]) -> Result<Vec<Discovery>> {
        let rows = sqlx::query(
            "SELECT * FROM discovery WHERE network_id = ANY($1) ORDER BY created_at DESC",
        )
        .bind(network_ids)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| {
            tracing::info!("SQLx error in get_all: {:?}", e);
            e
        })?;

        let mut discovery = Vec::new();
        for row in rows {
            discovery.push(row_to_discovery(row)?);
        }

        Ok(discovery)
    }

    async fn update(&self, discovery: &Discovery) -> Result<Discovery> {
        let discovery_type_json = serde_json::to_value(&discovery.base.discovery_type)?;
        let run_type_json = serde_json::to_value(&discovery.base.run_type)?;

        sqlx::query(
            r#"
            UPDATE discovery SET 
                discovery_type = $2, run_type = $3, name = $4, 
                daemon_id = $5, created_at = $6, updated_at = $7, network_id = $8
            WHERE id = $1
            "#,
        )
        .bind(discovery.id)
        .bind(discovery_type_json)
        .bind(run_type_json)
        .bind(&discovery.base.name)
        .bind(discovery.base.daemon_id)
        .bind(discovery.created_at)
        .bind(discovery.updated_at)
        .bind(discovery.base.network_id)
        .execute(&self.pool)
        .await?;

        Ok(discovery.clone())
    }

    async fn get_all_scheduled(&self) -> Result<Vec<Discovery>> {
        let rows = sqlx::query(
            r#"
            SELECT * FROM discovery 
            WHERE run_type->>'type' = 'Scheduled'
            AND (run_type->>'enabled')::boolean = true
            ORDER BY created_at DESC
            "#,
        )
        .fetch_all(&self.pool)
        .await?;

        let mut discoveries = Vec::new();
        for row in rows {
            discoveries.push(row_to_discovery(row)?);
        }

        Ok(discoveries)
    }

    async fn update_schedule_times(&self, id: &Uuid, last_run: DateTime<Utc>) -> Result<()> {
        // Get current discovery
        let discovery = self
            .get_by_id(id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Discovery not found"))?;

        // Update the run_type with new times
        let updated_run_type = match discovery.base.run_type {
            RunType::Scheduled {
                cron_schedule,
                enabled,
                ..
            } => RunType::Scheduled {
                cron_schedule,
                last_run: Some(last_run),
                enabled,
            },
            other => other,
        };

        let run_type_json = serde_json::to_value(&updated_run_type)?;

        sqlx::query("UPDATE discovery SET run_type = $1, updated_at = $2 WHERE id = $3")
            .bind(run_type_json)
            .bind(Utc::now())
            .bind(id)
            .execute(&self.pool)
            .await?;

        Ok(())
    }

    async fn delete(&self, id: &Uuid) -> Result<()> {
        sqlx::query("DELETE FROM discovery WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await?;

        Ok(())
    }
}

fn row_to_discovery(row: sqlx::postgres::PgRow) -> Result<Discovery, Error> {
    let discovery_type: DiscoveryType =
        serde_json::from_value(row.get::<serde_json::Value, _>("discovery_type"))
            .or(Err(Error::msg("Failed to deserialize discovery_type")))?;

    let run_type: RunType = serde_json::from_value(row.get::<serde_json::Value, _>("run_type"))
        .or(Err(Error::msg("Failed to deserialize run_type")))?;

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
