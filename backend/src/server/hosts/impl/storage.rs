use chrono::{DateTime, Utc};
use sqlx::Row;
use sqlx::postgres::PgRow;
use uuid::Uuid;

use crate::server::{
    hosts::r#impl::{
        base::{Host, HostBase},
        interfaces::Interface,
        ports::Port,
        targets::HostTarget,
        virtualization::HostVirtualization,
    },
    shared::{
        storage::traits::{SqlValue, StorableEntity},
        types::entities::EntitySource,
    },
};

impl StorableEntity for Host {
    type BaseData = HostBase;

    fn table_name() -> &'static str {
        "hosts"
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
                    description,
                    hostname,
                    interfaces,
                    network_id,
                    target,
                    hidden,
                    source,
                    services,
                    ports,
                    virtualization,
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
                "hostname",
                "target",
                "hidden",
                "services",
                "ports",
                "virtualization",
                "interfaces",
            ],
            vec![
                SqlValue::Uuid(id),
                SqlValue::Timestamp(created_at),
                SqlValue::Timestamp(updated_at),
                SqlValue::String(name),
                SqlValue::OptionalString(description),
                SqlValue::Uuid(network_id),
                SqlValue::EntitySource(source),
                SqlValue::OptionalString(hostname),
                SqlValue::HostTarget(target),
                SqlValue::Bool(hidden),
                SqlValue::UuidArray(services),
                SqlValue::Ports(ports),
                SqlValue::OptionalHostVirtualization(virtualization),
                SqlValue::Interfaces(interfaces),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        // Parse JSON fields safely
        let services: Vec<Uuid> =
            serde_json::from_value(row.get::<serde_json::Value, _>("services"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize services: {}", e))?;
        let interfaces: Vec<Interface> =
            serde_json::from_value(row.get::<serde_json::Value, _>("interfaces"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize interfaces: {}", e))?;
        let target: HostTarget = serde_json::from_value(row.get::<serde_json::Value, _>("target"))
            .map_err(|e| anyhow::anyhow!("Failed to deserialize target: {}", e))?;
        let ports: Vec<Port> = serde_json::from_value(row.get::<serde_json::Value, _>("ports"))
            .map_err(|e| anyhow::anyhow!("Failed to deserialize ports: {}", e))?;
        let source: EntitySource =
            serde_json::from_value(row.get::<serde_json::Value, _>("source"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize source: {}", e))?;
        let virtualization: Option<HostVirtualization> =
            serde_json::from_value(row.get::<serde_json::Value, _>("virtualization"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize virtualization: {}", e))?;

        Ok(Host {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: HostBase {
                name: row.get("name"),
                description: row.get("description"),
                network_id: row.get("network_id"),
                source,
                hostname: row.get("hostname"),
                target,
                hidden: row.get("hidden"),
                services,
                ports,
                virtualization,
                interfaces,
            },
        })
    }
}
