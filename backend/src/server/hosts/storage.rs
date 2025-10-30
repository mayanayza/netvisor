use crate::server::{
    discovery::types::base::EntitySource,
    hosts::types::{
        base::{Host, HostBase},
        interfaces::Interface,
        ports::Port,
        targets::HostTarget,
        virtualization::HostVirtualization,
    },
};
use anyhow::{Error, Result};
use async_trait::async_trait;
use sqlx::{PgPool, Row};
use uuid::Uuid;

#[async_trait]
pub trait HostStorage: Send + Sync {
    async fn create(&self, host: &Host) -> Result<()>;
    async fn get_by_id(&self, id: &Uuid) -> Result<Option<Host>>;
    async fn get_all(&self, network_ids: &[Uuid]) -> Result<Vec<Host>>;
    async fn update(&self, host: &Host) -> Result<()>;
    async fn delete(&self, id: &Uuid) -> Result<()>;
}

pub struct PostgresHostStorage {
    pool: PgPool,
}

impl PostgresHostStorage {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl HostStorage for PostgresHostStorage {
    async fn create(&self, host: &Host) -> Result<()> {
        let services_str = serde_json::to_value(&host.base.services)?;
        let interfaces_str = serde_json::to_value(&host.base.interfaces)?;
        let target_str = serde_json::to_value(host.base.target)?;
        let ports_str = serde_json::to_value(&host.base.ports)?;
        let source_str = serde_json::to_value(&host.base.source)?;
        let virtualization_str = serde_json::to_value(&host.base.virtualization)?;

        sqlx::query(
            r#"
            INSERT INTO hosts (
                id, name, hostname, target, description,
                services, interfaces, ports, source, virtualization,
                created_at, updated_at, network_id
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
            "#,
        )
        .bind(host.id)
        .bind(&host.base.name)
        .bind(&host.base.hostname)
        .bind(target_str)
        .bind(&host.base.description)
        .bind(services_str)
        .bind(interfaces_str)
        .bind(ports_str)
        .bind(source_str)
        .bind(virtualization_str)
        .bind(host.created_at)
        .bind(host.updated_at)
        .bind(host.base.network_id)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn get_by_id(&self, id: &Uuid) -> Result<Option<Host>> {
        let row = sqlx::query("SELECT * FROM hosts WHERE id = $1")
            .bind(id)
            .fetch_optional(&self.pool)
            .await?;

        match row {
            Some(row) => Ok(Some(row_to_host(row)?)),
            None => Ok(None),
        }
    }

    async fn get_all(&self, network_ids: &[Uuid]) -> Result<Vec<Host>> {
        let rows =
            sqlx::query("SELECT * FROM hosts WHERE network_id = ANY($1) ORDER BY created_at DESC")
                .bind(network_ids)
                .fetch_all(&self.pool)
                .await?;

        let mut hosts = Vec::new();
        for row in rows {
            hosts.push(row_to_host(row)?);
        }

        Ok(hosts)
    }

    async fn update(&self, host: &Host) -> Result<()> {
        let services_str = serde_json::to_value(&host.base.services)?;
        let interfaces_str = serde_json::to_value(&host.base.interfaces)?;
        let target_str = serde_json::to_value(host.base.target)?;
        let ports_str = serde_json::to_value(&host.base.ports)?;
        let source_str = serde_json::to_value(&host.base.source)?;
        let virtualization_str = serde_json::to_value(&host.base.virtualization)?;

        sqlx::query(
            r#"
            UPDATE hosts SET 
                name = $2, hostname = $3, description = $4,
                target = $5, interfaces = $6, ports = $7, source = $8, services = $9, virtualization = $10,
                updated_at = $11
            WHERE id = $1
            "#,
        )
        .bind(host.id)
        .bind(&host.base.name)
        .bind(&host.base.hostname)
        .bind(&host.base.description)
        .bind(target_str)
        .bind(interfaces_str)
        .bind(ports_str)
        .bind(source_str)
        .bind(services_str)
        .bind(virtualization_str)
        .bind(host.updated_at)
        .bind(host.base.network_id)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn delete(&self, id: &Uuid) -> Result<()> {
        sqlx::query("DELETE FROM hosts WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await?;

        Ok(())
    }
}

fn row_to_host(row: sqlx::postgres::PgRow) -> Result<Host, Error> {
    // Parse JSON fields safely
    let services: Vec<Uuid> = serde_json::from_value(row.get::<serde_json::Value, _>("services"))
        .or(Err(Error::msg("Failed to deserialize services")))?;
    let interfaces: Vec<Interface> =
        serde_json::from_value(row.get::<serde_json::Value, _>("interfaces"))
            .or(Err(Error::msg("Failed to deserialize interfaces")))?;
    let target: HostTarget = serde_json::from_value(row.get::<serde_json::Value, _>("target"))
        .or(Err(Error::msg("Failed to deserialize target")))?;
    let ports: Vec<Port> = serde_json::from_value(row.get::<serde_json::Value, _>("ports"))
        .or(Err(Error::msg("Failed to deserialize ports")))?;
    let source: EntitySource = serde_json::from_value(row.get::<serde_json::Value, _>("source"))
        .or(Err(Error::msg("Failed to deserialize source")))?;
    let virtualization: Option<HostVirtualization> =
        serde_json::from_value(row.get::<serde_json::Value, _>("virtualization"))
            .or(Err(Error::msg("Failed to deserialize virtualization")))?;

    Ok(Host {
        id: row.get("id"),
        created_at: row.get("created_at"),
        updated_at: row.get("updated_at"),
        base: HostBase {
            name: row.get("name"),
            network_id: row.get("network_id"),
            target,
            hostname: row.get("hostname"),
            description: row.get("description"),
            services,
            ports,
            virtualization,
            interfaces,
            source,
        },
    })
}
