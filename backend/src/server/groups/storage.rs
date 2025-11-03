use crate::server::{
    groups::types::{Group, GroupBase, GroupType},
    shared::types::entities::EntitySource,
};
use anyhow::{Error, Result};
use async_trait::async_trait;
use sqlx::{PgPool, Row};
use uuid::Uuid;

#[async_trait]
pub trait GroupStorage: Send + Sync {
    async fn create(&self, group: &Group) -> Result<Group>;
    async fn get_by_id(&self, id: &Uuid) -> Result<Option<Group>>;
    async fn get_all(&self, network_ids: &[Uuid]) -> Result<Vec<Group>>;
    async fn update(&self, group: &Group) -> Result<()>;
    async fn delete(&self, id: &Uuid) -> Result<()>;
}

pub struct PostgresGroupStorage {
    pool: PgPool,
}

impl PostgresGroupStorage {
    pub fn new(pool: PgPool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl GroupStorage for PostgresGroupStorage {
    async fn create(&self, group: &Group) -> Result<Group> {
        let group_type_json = serde_json::to_value(&group.base.group_type)?;
        let source_json = serde_json::to_value(&group.base.source)?;

        sqlx::query(
            r#"
            INSERT INTO groups (
                id, name, description, group_type, source,
                created_at, updated_at, network_id, color
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            "#,
        )
        .bind(group.id)
        .bind(&group.base.name)
        .bind(&group.base.description)
        .bind(group_type_json)
        .bind(source_json)
        .bind(chrono::Utc::now())
        .bind(chrono::Utc::now())
        .bind(group.base.network_id)
        .bind(&group.base.color)
        .execute(&self.pool)
        .await?;

        Ok(group.clone())
    }

    async fn get_by_id(&self, id: &Uuid) -> Result<Option<Group>> {
        let row = sqlx::query("SELECT * FROM groups WHERE id = $1")
            .bind(id)
            .fetch_optional(&self.pool)
            .await?;

        match row {
            Some(row) => Ok(Some(row_to_group(row)?)),
            None => Ok(None),
        }
    }

    async fn get_all(&self, network_ids: &[Uuid]) -> Result<Vec<Group>> {
        let rows =
            sqlx::query("SELECT * FROM groups WHERE network_id = ANY($1) ORDER BY created_at ASC ")
                .bind(network_ids)
                .fetch_all(&self.pool)
                .await?;

        let mut groups = Vec::new();
        for row in rows {
            groups.push(row_to_group(row)?);
        }

        Ok(groups)
    }

    async fn update(&self, group: &Group) -> Result<()> {
        let group_type_json = serde_json::to_value(&group.base.group_type)?;
        let source_json = serde_json::to_value(&group.base.source)?;

        sqlx::query(
            r#"
            UPDATE groups SET 
                name = $2, description = $3, group_type = $4, source = $5,
                updated_at = $6, color = $7, network_id = $8
            WHERE id = $1
            "#,
        )
        .bind(group.id)
        .bind(&group.base.name)
        .bind(&group.base.description)
        .bind(group_type_json)
        .bind(source_json)
        .bind(chrono::Utc::now())
        .bind(&group.base.color)
        .bind(group.base.network_id)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn delete(&self, id: &Uuid) -> Result<()> {
        sqlx::query("DELETE FROM groups WHERE id = $1")
            .bind(id)
            .execute(&self.pool)
            .await?;

        Ok(())
    }
}

fn row_to_group(row: sqlx::postgres::PgRow) -> Result<Group, Error> {
    let group_type: GroupType =
        serde_json::from_value(row.get::<serde_json::Value, _>("group_type"))
            .or(Err(Error::msg("Failed to deserialize group_type")))?;

    let source: EntitySource = serde_json::from_value(row.get::<serde_json::Value, _>("source"))
        .or(Err(Error::msg("Failed to deserialize group_type")))?;

    Ok(Group {
        id: row.get("id"),
        created_at: row.get("created_at"),
        updated_at: row.get("updated_at"),
        base: GroupBase {
            name: row.get("name"),
            description: row.get("description"),
            network_id: row.get("network_id"),
            source,
            group_type,
            color: row.get("color"),
        },
    })
}
