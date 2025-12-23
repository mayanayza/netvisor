use std::net::IpAddr;

use chrono::{DateTime, Utc};
use ipnetwork::IpNetwork;
use mac_address::MacAddress;
use sqlx::Row;
use sqlx::postgres::PgRow;
use uuid::Uuid;

use crate::server::{
    interfaces::r#impl::base::{Interface, InterfaceBase},
    shared::storage::{
        child::ChildStorableEntity,
        traits::{SqlValue, StorableEntity},
    },
};

impl StorableEntity for Interface {
    type BaseData = InterfaceBase;

    fn table_name() -> &'static str {
        "interfaces"
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
        let now = Utc::now();

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
                    network_id,
                    host_id,
                    subnet_id,
                    ip_address,
                    mac_address,
                    name,
                },
        } = self.clone();

        Ok((
            vec![
                "id",
                "network_id",
                "host_id",
                "subnet_id",
                "ip_address",
                "mac_address",
                "name",
                "created_at",
                "updated_at",
            ],
            vec![
                SqlValue::Uuid(id),
                SqlValue::Uuid(network_id),
                SqlValue::Uuid(host_id),
                SqlValue::Uuid(subnet_id),
                SqlValue::IpAddr(ip_address),
                SqlValue::OptionalMacAddress(mac_address),
                SqlValue::OptionalString(name),
                SqlValue::Timestamp(created_at),
                SqlValue::Timestamp(updated_at),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        // Read ip_address from INET column using IpNetwork
        let ip_network: IpNetwork = row
            .try_get("ip_address")
            .map_err(|e| anyhow::anyhow!("Failed to read ip_address: {}", e))?;
        let ip_address: IpAddr = ip_network.ip();

        // Read mac_address from MACADDR column - sqlx returns [u8; 6] for mac_address feature
        let mac_address: Option<MacAddress> = row
            .try_get::<Option<MacAddress>, _>("mac_address")
            .map_err(|e| anyhow::anyhow!("Failed to read mac_address: {}", e))?;

        Ok(Interface {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: InterfaceBase {
                network_id: row.get("network_id"),
                host_id: row.get("host_id"),
                subnet_id: row.get("subnet_id"),
                ip_address,
                mac_address,
                name: row.get("name"),
            },
        })
    }
}

impl ChildStorableEntity for Interface {
    fn parent_column() -> &'static str {
        "host_id"
    }

    fn parent_id(&self) -> Uuid {
        self.base.host_id
    }
}
