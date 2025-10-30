use crate::server::{
    discovery::types::base::EntitySource,
    subnets::types::base::{Subnet, SubnetBase, SubnetType},
};
use anyhow::{Error, Result};
use async_trait::async_trait;
use cidr::IpCidr;
use sqlx::{PgPool, Row};
use uuid::Uuid;

#[async_trait]
pub trait SubnetStorage: Send + Sync {
    async fn create(&self, subnet: &Subnet) -> Result<()>;
    async fn get_by_id(&self, id: &Uuid) -> Result<Option<Subnet>>;
    async fn get_by_ids(&self, ids: &[Uuid]) -> Result<Vec<Subnet>>;
    async fn get_all(&self, network_ids: &[Uuid]) -> Result<Vec<Subnet>>;
    async fn update(&self, subnet: &Subnet) -> Result<()>;
    async fn delete(&self, id: &Uuid) -> Result<()>;
}

pub struct PostgresSubnetStorage {
    pool: PgPool,
}

impl PostgresSubnetStorage {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl SubnetStorage for PostgresSubnetStorage {
    async fn create(&self, subnet: &Subnet) -> Result<()> {
        let cidr_str = serde_json::to_string(&subnet.base.cidr)?;
        let subnet_type_str = serde_json::to_string(&subnet.base.subnet_type)?;
        let subnet_source_str = serde_json::to_value(&subnet.base.source)?;

        sqlx::query(
            r#"
            INSERT INTO subnets (
                id, name, description, cidr, 
                subnet_type, source, created_at, updated_at, network_id
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            "#,
        )
        .bind(subnet.id)
        .bind(&subnet.base.name)
        .bind(&subnet.base.description)
        .bind(&cidr_str)
        .bind(subnet_type_str)
        .bind(subnet_source_str)
        .bind(subnet.created_at)
        .bind(subnet.updated_at)
        .bind(subnet.base.network_id)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn get_by_id(&self, id: &Uuid) -> Result<Option<Subnet>> {
        let row = sqlx::query("SELECT * FROM subnets WHERE id = $1")
            .bind(id)
            .fetch_optional(&self.pool)
            .await?;

        match row {
            Some(row) => Ok(Some(row_to_subnet(row)?)),
            None => Ok(None),
        }
    }

    async fn get_by_ids(&self, ids: &[Uuid]) -> Result<Vec<Subnet>> {
        if ids.is_empty() {
            return Ok(vec![]);
        }

        let placeholders = ids
            .iter()
            .enumerate()
            .map(|(i, _)| format!("${}", i + 1))
            .collect::<Vec<_>>()
            .join(",");
        let query = format!("SELECT * FROM subnets WHERE id IN ({})", placeholders);

        let mut query_builder = sqlx::query(&query);
        for id in ids {
            query_builder = query_builder.bind(id);
        }

        let rows = query_builder.fetch_all(&self.pool).await?;

        rows.into_iter()
            .map(row_to_subnet)
            .collect::<Result<Vec<_>, _>>()
    }

    async fn get_all(&self, network_ids: &[Uuid]) -> Result<Vec<Subnet>> {
        let rows = sqlx::query(
            "SELECT * FROM subnets WHERE network_id = ANY($1) ORDER BY created_at DESC",
        )
        .bind(network_ids)
        .fetch_all(&self.pool)
        .await?;

        let mut subnets = Vec::new();
        for row in rows {
            subnets.push(row_to_subnet(row)?);
        }

        Ok(subnets)
    }

    async fn update(&self, subnet: &Subnet) -> Result<()> {
        let cidr_str = serde_json::to_string(&subnet.base.cidr)?;
        let subnet_type_str = serde_json::to_string(&subnet.base.subnet_type)?;
        let subnet_source_str = serde_json::to_value(&subnet.base.source)?;

        sqlx::query(
            r#"
            UPDATE subnets SET 
                name = $2, description = $3, cidr = $4,
                subnet_type = $5, source = $6, updated_at = $7, network_id = $8
            WHERE id = $1
            "#,
        )
        .bind(subnet.id)
        .bind(&subnet.base.name)
        .bind(&subnet.base.description)
        .bind(cidr_str)
        .bind(subnet_type_str)
        .bind(subnet_source_str)
        .bind(subnet.updated_at)
        .bind(&subnet.base.network_id)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn delete(&self, id: &Uuid) -> Result<()> {
        sqlx::query("DELETE FROM subnets WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await?;

        Ok(())
    }
}

fn row_to_subnet(row: sqlx::postgres::PgRow) -> Result<Subnet, Error> {
    // Parse JSON fields safely
    let cidr: IpCidr = serde_json::from_str(&row.get::<String, _>("cidr"))
        .or(Err(Error::msg("Failed to deserialize cidr")))?;
    let subnet_type: SubnetType = serde_json::from_str(&row.get::<String, _>("subnet_type"))
        .or(Err(Error::msg("Failed to deserialize subnet_type")))?;
    let source: EntitySource = serde_json::from_value(row.get::<serde_json::Value, _>("source"))
        .or(Err(Error::msg("Failed to deserialize source")))?;

    Ok(Subnet {
        id: row.get("id"),
        created_at: row.get("created_at"),
        updated_at: row.get("updated_at"),
        base: SubnetBase {
            name: row.get("name"),
            description: row.get("description"),
            network_id: row.get("network_id"),
            source,
            cidr,
            subnet_type,
        },
    })
}
