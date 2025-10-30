use anyhow::Error;
use anyhow::Result;
use async_trait::async_trait;
use sqlx::{PgPool, Row};
use tracing::info;
use uuid::Uuid;

use crate::server::networks::types::Network;
use crate::server::networks::types::NetworkBase;

#[async_trait]
pub trait NetworkStorage: Send + Sync {
    async fn create(&self, network: &Network) -> Result<()>;
    async fn get_by_id(&self, id: &Uuid) -> Result<Option<Network>>;
    async fn get_all(&self, user_id: &Uuid) -> Result<Vec<Network>>;
    async fn update(&self, group: &Network) -> Result<()>;
    async fn delete(&self, id: &Uuid) -> Result<()>;
}

pub struct PostgresNetworkStorage {
    pool: PgPool,
}

impl PostgresNetworkStorage {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl NetworkStorage for PostgresNetworkStorage {
    async fn create(&self, network: &Network) -> Result<()> {
        sqlx::query(
            r#"
            INSERT INTO networks (
                id, name, user_id, created_at, updated_at, is_default
            ) VALUES ($1, $2, $3, $4, $5, $6)
            "#,
        )
        .bind(network.id)
        .bind(&network.base.name)
        .bind(network.base.user_id)
        .bind(chrono::Utc::now())
        .bind(chrono::Utc::now())
        .bind(network.base.is_default)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn get_by_id(&self, id: &Uuid) -> Result<Option<Network>> {
        let row = sqlx::query("SELECT * FROM networks WHERE id = $1")
            .bind(id)
            .fetch_optional(&self.pool)
            .await?;

        match row {
            Some(row) => Ok(Some(row_to_network(row)?)),
            None => Ok(None),
        }
    }

    async fn get_all(&self, user_id: &Uuid) -> Result<Vec<Network>> {
        let rows = sqlx::query("SELECT * FROM networks WHERE user_id = $1 ORDER BY created_at DESC")
            .bind(user_id)
            .fetch_all(&self.pool)
            .await
            .map_err(|e| {
                info!("SQLx error in get_all: {:?}", e);
                e
            })?;

        let mut networks = Vec::new();
        for row in rows {
            networks.push(row_to_network(row)?);
        }

        Ok(networks)
    }

    async fn update(&self, network: &Network) -> Result<()> {
        sqlx::query(
            r#"
            UPDATE networks SET 
                name = $2, user_id = $3, updated_at = $4, is_default = $5
            WHERE id = $1
            "#,
        )
        .bind(network.id)
        .bind(&network.base.name)
        .bind(network.base.user_id)
        .bind(chrono::Utc::now())
        .bind(network.base.is_default)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn delete(&self, id: &Uuid) -> Result<()> {
        sqlx::query("DELETE FROM networks WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await?;

        Ok(())
    }
}

fn row_to_network(row: sqlx::postgres::PgRow) -> Result<Network, Error> {
    Ok(Network {
        id: row.get("id"),
        created_at: row.get("created_at"),
        updated_at: row.get("updated_at"),
        base: NetworkBase {
            name: row.get("name"),
            user_id: row.get("user_id"),
            is_default: row.get("is_default"),
        },
    })
}
