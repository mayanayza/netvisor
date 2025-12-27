use chrono::{DateTime, Utc};
use sqlx::Row;
use sqlx::postgres::PgRow;
use uuid::Uuid;

use crate::server::{
    shared::storage::traits::{SqlValue, StorableEntity},
    tags::r#impl::base::{Tag, TagBase},
};

impl StorableEntity for Tag {
    type BaseData = TagBase;

    fn table_name() -> &'static str {
        "tags"
    }

    fn get_base(&self) -> Self::BaseData {
        self.base.clone()
    }

    fn network_id(&self) -> Option<Uuid> {
        None
    }

    fn organization_id(&self) -> Option<Uuid> {
        Some(self.base.organization_id)
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
                    name,
                    description,
                    color,
                    organization_id,
                },
        } = self.clone();

        Ok((
            vec![
                "id",
                "name",
                "description",
                "color",
                "organization_id",
                "created_at",
                "updated_at",
            ],
            vec![
                SqlValue::Uuid(id),
                SqlValue::String(name),
                SqlValue::OptionalString(description),
                SqlValue::String(color.to_string()),
                SqlValue::Uuid(organization_id),
                SqlValue::Timestamp(created_at),
                SqlValue::Timestamp(updated_at),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        Ok(Tag {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: TagBase {
                name: row.get("name"),
                description: row.get("description"),
                organization_id: row.get("organization_id"),
                color: row.get::<String, _>("color").parse().unwrap_or_default(),
            },
        })
    }
}
