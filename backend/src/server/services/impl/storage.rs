use chrono::{DateTime, Utc};
use sqlx::Row;
use sqlx::postgres::PgRow;
use uuid::Uuid;

use crate::server::{
    services::r#impl::{
        base::{Service, ServiceBase},
        definitions::ServiceDefinition,
        virtualization::ServiceVirtualization,
    },
    shared::{
        storage::{
            child::ChildStorableEntity,
            traits::{SqlValue, StorableEntity},
        },
        types::entities::EntitySource,
    },
};

impl StorableEntity for Service {
    type BaseData = ServiceBase;

    fn table_name() -> &'static str {
        "services"
    }

    fn get_base(&self) -> Self::BaseData {
        self.base.clone()
    }

    fn network_id(&self) -> Option<Uuid> {
        Some(self.base.network_id)
    }

    fn organization_id(&self) -> Option<Uuid> {
        None
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
                    host_id,
                    service_definition,
                    virtualization,
                    bindings: _, // Bindings stored in separate table, managed by BindingStorage
                    source,
                    tags,
                },
        } = self.clone();

        Ok((
            vec![
                "id",
                "created_at",
                "updated_at",
                "name",
                "network_id",
                "host_id",
                "service_definition",
                "virtualization",
                "source",
                "tags",
            ],
            vec![
                SqlValue::Uuid(id),
                SqlValue::Timestamp(created_at),
                SqlValue::Timestamp(updated_at),
                SqlValue::String(name),
                SqlValue::Uuid(network_id),
                SqlValue::Uuid(host_id),
                SqlValue::ServiceDefinition(service_definition),
                SqlValue::OptionalServiceVirtualization(virtualization),
                SqlValue::EntitySource(source),
                SqlValue::UuidArray(tags),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        let service_definition: Box<dyn ServiceDefinition> =
            serde_json::from_str(&row.get::<String, _>("service_definition"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize service_definition: {}", e))?;
        let virtualization: Option<ServiceVirtualization> =
            serde_json::from_value(row.get::<serde_json::Value, _>("virtualization"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize virtualization: {}", e))?;
        let source: EntitySource =
            serde_json::from_value(row.get::<serde_json::Value, _>("source"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize source: {}", e))?;

        Ok(Service {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: ServiceBase {
                name: row.get("name"),
                network_id: row.get("network_id"),
                host_id: row.get("host_id"),
                service_definition,
                virtualization,
                bindings: Vec::new(), // Bindings loaded separately by ServiceService via BindingStorage
                tags: row.get("tags"),
                source,
            },
        })
    }
}

impl ChildStorableEntity for Service {
    fn parent_column() -> &'static str {
        "host_id"
    }

    fn parent_id(&self) -> Uuid {
        self.base.host_id
    }
}
