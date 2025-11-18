use chrono::{DateTime, Utc};
use sqlx::Row;
use sqlx::postgres::PgRow;
use uuid::Uuid;

use crate::server::{
    shared::storage::traits::{SqlValue, StorableEntity},
    topology::types::{
        api::TopologyOptions,
        base::{Topology, TopologyBase},
        edges::Edge,
        nodes::Node,
    },
};

impl StorableEntity for Topology {
    type BaseData = TopologyBase;

    fn table_name() -> &'static str {
        "topologies"
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
                    nodes,
                    edges,
                    options,
                },
        } = self.clone();

        Ok((
            vec![
                "id",
                "created_at",
                "updated_at",
                "name",
                "network_id",
                "nodes",
                "edges",
                "options",
            ],
            vec![
                SqlValue::Uuid(id),
                SqlValue::Timestamp(created_at),
                SqlValue::Timestamp(updated_at),
                SqlValue::String(name),
                SqlValue::Uuid(network_id),
                SqlValue::Nodes(nodes),
                SqlValue::Edges(edges),
                SqlValue::TopologyOptions(options),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        // Parse JSON fields safely
        let nodes: Vec<Node> = serde_json::from_str(&row.get::<String, _>("nodes"))
            .map_err(|e| anyhow::anyhow!("Failed to deserialize nodes: {}", e))?;
        let edges: Vec<Edge> = serde_json::from_str(&row.get::<String, _>("edges"))
            .map_err(|e| anyhow::anyhow!("Failed to deserialize edges: {}", e))?;
        let options: TopologyOptions =
            serde_json::from_value(row.get::<serde_json::Value, _>("options"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize options: {}", e))?;

        Ok(Topology {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: TopologyBase {
                name: row.get("name"),
                network_id: row.get("network_id"),
                nodes,
                edges,
                options,
            },
        })
    }
}
