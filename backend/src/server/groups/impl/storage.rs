use chrono::{DateTime, Utc};
use sqlx::Row;
use sqlx::postgres::PgRow;
use uuid::Uuid;

use crate::server::{
    groups::r#impl::{
        base::{Group, GroupBase},
        types::GroupType,
    },
    shared::{
        storage::traits::{SqlValue, StorableEntity},
        types::entities::EntitySource,
    },
    topology::types::edges::EdgeStyle,
};

impl StorableEntity for Group {
    type BaseData = GroupBase;

    fn table_name() -> &'static str {
        "groups"
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
                    name,
                    network_id,
                    description,
                    group_type,
                    source,
                    color,
                    edge_style,
                },
        } = self.clone();

        Ok((
            vec![
                "id",
                "created_at",
                "updated_at",
                "name",
                "description",
                "network_id",
                "source",
                "group_type",
                "color",
                "edge_style",
            ],
            vec![
                SqlValue::Uuid(id),
                SqlValue::Timestamp(created_at),
                SqlValue::Timestamp(updated_at),
                SqlValue::String(name),
                SqlValue::OptionalString(description),
                SqlValue::Uuid(network_id),
                SqlValue::EntitySource(source),
                SqlValue::GroupType(group_type),
                SqlValue::String(color),
                SqlValue::String(serde_json::to_string(&edge_style)?),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        let group_type: GroupType =
            serde_json::from_value(row.get::<serde_json::Value, _>("group_type"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize group_type: {}", e))?;

        let source: EntitySource =
            serde_json::from_value(row.get::<serde_json::Value, _>("source"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize source: {}", e))?;

        let edge_style: EdgeStyle = serde_json::from_str(&row.get::<String, _>("edge_style"))
            .map_err(|e| anyhow::anyhow!("Failed to deserialize edge_style: {}", e))?;

        Ok(Group {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: GroupBase {
                name: row.get("name"),
                description: row.get("description"),
                network_id: row.get("network_id"),
                source,
                edge_style,
                group_type,
                color: row.get("color"),
            },
        })
    }
}
