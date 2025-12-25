use chrono::{DateTime, Utc};
use sqlx::Row;
use sqlx::postgres::PgRow;
use uuid::Uuid;

use crate::server::{
    billing::types::base::BillingPlan,
    organizations::r#impl::base::{Organization, OrganizationBase},
    shared::{
        events::types::TelemetryOperation,
        storage::traits::{SqlValue, StorableEntity},
    },
};

impl StorableEntity for Organization {
    type BaseData = OrganizationBase;

    fn table_name() -> &'static str {
        "organizations"
    }

    fn get_base(&self) -> Self::BaseData {
        self.base.clone()
    }

    fn network_id(&self) -> Option<Uuid> {
        None
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
                    stripe_customer_id,
                    plan,
                    plan_status,
                    onboarding,
                },
        } = self.clone();

        Ok((
            vec![
                "id",
                "created_at",
                "updated_at",
                "name",
                "stripe_customer_id",
                "plan",
                "plan_status",
                "onboarding",
            ],
            vec![
                SqlValue::Uuid(id),
                SqlValue::Timestamp(created_at),
                SqlValue::Timestamp(updated_at),
                SqlValue::String(name),
                SqlValue::OptionalString(stripe_customer_id),
                SqlValue::OptionBillingPlan(plan),
                SqlValue::OptionalString(plan_status),
                SqlValue::TelemetryOperation(onboarding),
            ],
        ))
    }

    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error> {
        let plan: Option<BillingPlan> = row
            .try_get::<Option<serde_json::Value>, _>("plan")
            .unwrap_or(None)
            .and_then(|v| serde_json::from_value(v).ok());

        let onboarding: Vec<TelemetryOperation> =
            serde_json::from_value(row.get::<serde_json::Value, _>("onboarding"))
                .map_err(|e| anyhow::anyhow!("Failed to deserialize onboarding: {}", e))?;

        Ok(Organization {
            id: row.get("id"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
            base: OrganizationBase {
                name: row.get("name"),
                stripe_customer_id: row.get("stripe_customer_id"),
                plan,
                plan_status: row.get("plan_status"),
                onboarding,
            },
        })
    }
}
