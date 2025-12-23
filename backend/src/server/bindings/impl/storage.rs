use anyhow::Result;
use chrono::{DateTime, Utc};
use sqlx::{Row, postgres::PgRow};
use uuid::Uuid;

use crate::server::{
    bindings::r#impl::base::{Binding, BindingBase, BindingType},
    shared::storage::traits::{SqlValue, StorableEntity},
};

impl StorableEntity for Binding {
    type BaseData = BindingBase;

    fn table_name() -> &'static str {
        "bindings"
    }

    fn new(base: Self::BaseData) -> Self {
        Binding::new(base)
    }

    fn get_base(&self) -> Self::BaseData {
        self.base
    }

    fn id(&self) -> Uuid {
        self.id
    }

    fn network_id(&self) -> Option<Uuid> {
        Some(self.base.network_id)
    }

    fn organization_id(&self) -> Option<Uuid> {
        None
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

    fn to_params(&self) -> Result<(Vec<&'static str>, Vec<SqlValue>)> {
        let (binding_type, interface_id, port_id) = match self.base.binding_type {
            BindingType::Interface { interface_id } => ("Interface", Some(interface_id), None),
            BindingType::Port {
                port_id,
                interface_id,
            } => ("Port", interface_id, Some(port_id)),
        };

        Ok((
            vec![
                "id",
                "service_id",
                "network_id",
                "binding_type",
                "interface_id",
                "port_id",
                "created_at",
                "updated_at",
            ],
            vec![
                SqlValue::Uuid(self.id),
                SqlValue::Uuid(self.base.service_id),
                SqlValue::Uuid(self.base.network_id),
                SqlValue::String(binding_type.to_string()),
                SqlValue::OptionalUuid(interface_id),
                SqlValue::OptionalUuid(port_id),
                SqlValue::Timestamp(self.created_at),
                SqlValue::Timestamp(self.updated_at),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self> {
        let id: Uuid = row.get("id");
        let service_id: Uuid = row.get("service_id");
        let network_id: Uuid = row.get("network_id");
        let created_at: DateTime<Utc> = row.get("created_at");
        let updated_at: DateTime<Utc> = row.get("updated_at");
        let binding_type_str: String = row.get("binding_type");
        let interface_id: Option<Uuid> = row.get("interface_id");
        let port_id: Option<Uuid> = row.get("port_id");

        let binding_type = match binding_type_str.as_str() {
            "Interface" => {
                let interface_id = interface_id
                    .ok_or_else(|| anyhow::anyhow!("Interface binding missing interface_id"))?;
                BindingType::Interface { interface_id }
            }
            "Port" => {
                let port_id =
                    port_id.ok_or_else(|| anyhow::anyhow!("Port binding missing port_id"))?;
                BindingType::Port {
                    port_id,
                    interface_id, // Can be None for "all interfaces"
                }
            }
            _ => {
                return Err(anyhow::anyhow!(
                    "Unknown binding type: {}",
                    binding_type_str
                ));
            }
        };

        Ok(Binding {
            id,
            created_at,
            updated_at,
            base: BindingBase {
                service_id,
                network_id,
                binding_type,
            },
        })
    }
}
