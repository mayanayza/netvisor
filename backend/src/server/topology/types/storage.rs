use crate::server::groups::r#impl::base::Group;
use crate::server::interfaces::r#impl::base::Interface;
use crate::server::services::r#impl::base::Service;
use crate::server::subnets::r#impl::base::Subnet;
use crate::server::{
    hosts::r#impl::base::Host,
    shared::storage::traits::{SqlValue, StorableEntity},
    topology::types::{
        base::{Topology, TopologyBase, TopologyOptions},
        edges::Edge,
        nodes::Node,
    },
};
use chrono::{DateTime, Utc};
use sqlx::Row;
use sqlx::postgres::PgRow;
use uuid::Uuid;

impl StorableEntity for Topology {
    type BaseData = TopologyBase;

    fn table_name() -> &'static str {
        "topologies"
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
                    nodes,
                    edges,
                    options,
                    hosts,
                    interfaces,
                    services,
                    subnets,
                    groups,
                    is_stale,
                    last_refreshed,
                    is_locked,
                    locked_at,
                    locked_by,
                    removed_hosts,
                    removed_interfaces,
                    removed_services,
                    removed_subnets,
                    removed_groups,
                    parent_id,
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
                "nodes",
                "edges",
                "options",
                "hosts",
                "interfaces",
                "subnets",
                "groups",
                "services",
                "is_stale",
                "last_refreshed",
                "is_locked",
                "locked_at",
                "locked_by",
                "removed_hosts",
                "removed_interfaces",
                "removed_services",
                "removed_subnets",
                "removed_groups",
                "parent_id",
                "tags",
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
                SqlValue::Hosts(hosts),
                SqlValue::Interfaces(interfaces),
                SqlValue::Subnets(subnets),
                SqlValue::Groups(groups),
                SqlValue::Services(services),
                SqlValue::Bool(is_stale),
                SqlValue::Timestamp(last_refreshed),
                SqlValue::Bool(is_locked),
                SqlValue::OptionTimestamp(locked_at),
                SqlValue::OptionalUuid(locked_by),
                SqlValue::UuidArray(removed_hosts),
                SqlValue::UuidArray(removed_interfaces),
                SqlValue::UuidArray(removed_services),
                SqlValue::UuidArray(removed_subnets),
                SqlValue::UuidArray(removed_groups),
                SqlValue::OptionalUuid(parent_id),
                SqlValue::UuidArray(tags),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        // Parse JSON fields safely
        let nodes: Vec<Node> = serde_json::from_value(row.get::<serde_json::Value, _>("nodes"))
            .map_err(|e| anyhow::anyhow!("Failed to deserialize nodes: {}", e))?;
        let edges: Vec<Edge> = serde_json::from_value(row.get::<serde_json::Value, _>("edges"))
            .map_err(|e| anyhow::anyhow!("Failed to deserialize edges: {}", e))?;
        let options: TopologyOptions =
            serde_json::from_value(row.get::<serde_json::Value, _>("options"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize options: {}", e))?;

        let hosts: Vec<Host> = serde_json::from_value(row.get::<serde_json::Value, _>("hosts"))
            .map_err(|e| anyhow::anyhow!("Failed to deserialize hosts: {}", e))?;
        let interfaces: Vec<Interface> =
            serde_json::from_value(row.get::<serde_json::Value, _>("interfaces"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize interfaces: {}", e))?;
        let subnets: Vec<Subnet> =
            serde_json::from_value(row.get::<serde_json::Value, _>("subnets"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize subnets: {}", e))?;
        let services: Vec<Service> =
            serde_json::from_value(row.get::<serde_json::Value, _>("services"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize services: {}", e))?;
        let groups: Vec<Group> = serde_json::from_value(row.get::<serde_json::Value, _>("groups"))
            .map_err(|e| anyhow::anyhow!("Failed to deserialize groups: {}", e))?;

        Ok(Topology {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: TopologyBase {
                name: row.get("name"),
                network_id: row.get("network_id"),
                is_stale: row.get("is_stale"),
                last_refreshed: row.get("last_refreshed"),
                is_locked: row.get("is_locked"),
                locked_at: row.get("locked_at"),
                locked_by: row.get("locked_by"),
                removed_groups: row.get("removed_groups"),
                removed_hosts: row.get("removed_hosts"),
                removed_interfaces: row.get("removed_interfaces"),
                removed_services: row.get("removed_services"),
                removed_subnets: row.get("removed_subnets"),
                parent_id: row.get("parent_id"),
                nodes,
                edges,
                hosts,
                interfaces,
                subnets,
                services,
                groups,
                options,
                tags: row.get("tags"),
            },
        })
    }
}
