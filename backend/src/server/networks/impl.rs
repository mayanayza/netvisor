use std::fmt::Display;

use crate::server::{
    config::AppState,
    networks::service::NetworkService,
    shared::{
        entities::ChangeTriggersTopologyStaleness,
        handlers::{query::NoFilterQuery, traits::CrudHandlers},
    },
};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::Row;
use sqlx::postgres::PgRow;
use ts_rs::TS;
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

use crate::server::shared::storage::traits::{SqlValue, StorableEntity};

#[derive(Debug, Clone, Serialize, Deserialize, Validate, PartialEq, Eq, Hash, Default, ToSchema, TS)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct NetworkBase {
    #[validate(length(min = 0, max = 100))]
    pub name: String,
    pub organization_id: Uuid,
    #[serde(default)]
    pub tags: Vec<Uuid>,
}

impl NetworkBase {
    pub fn new(organization_id: Uuid) -> Self {
        Self {
            name: "My Network".to_string(),
            organization_id,
            tags: Vec::new(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema, TS)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
#[schema(example = crate::server::shared::types::examples::network)]
pub struct Network {
    #[serde(default)]
    #[schema(read_only)]
    pub id: Uuid,
    #[serde(default)]
    #[schema(read_only)]
    pub created_at: DateTime<Utc>,
    #[serde(default)]
    #[schema(read_only)]
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    pub base: NetworkBase,
}

impl Display for Network {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}: {}", self.base.name, self.id)
    }
}

impl CrudHandlers for Network {
    type Service = NetworkService;
    type FilterQuery = NoFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.network_service
    }
}

impl ChangeTriggersTopologyStaleness<Network> for Network {
    fn triggers_staleness(&self, _other: Option<Network>) -> bool {
        false
    }
}

impl StorableEntity for Network {
    type BaseData = NetworkBase;

    fn table_name() -> &'static str {
        "networks"
    }

    fn get_base(&self) -> Self::BaseData {
        self.base.clone()
    }

    fn new(base: Self::BaseData) -> Self {
        let now = chrono::Utc::now();
        Self {
            base,
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
        }
    }

    fn id(&self) -> Uuid {
        self.id
    }

    fn network_id(&self) -> Option<Uuid> {
        None
    }

    fn organization_id(&self) -> Option<Uuid> {
        Some(self.base.organization_id)
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
                    organization_id,
                    tags,
                },
        } = self.clone();

        Ok((
            vec![
                "id",
                "created_at",
                "updated_at",
                "name",
                "organization_id",
                "tags",
            ],
            vec![
                SqlValue::Uuid(id),
                SqlValue::Timestamp(created_at),
                SqlValue::Timestamp(updated_at),
                SqlValue::String(name),
                SqlValue::Uuid(organization_id),
                SqlValue::UuidArray(tags),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        Ok(Network {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: NetworkBase {
                name: row.get("name"),
                organization_id: row.get("organization_id"),
                tags: row.get("tags"),
            },
        })
    }
}
