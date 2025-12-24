use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::fmt::Display;
use ts_rs::TS;
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

use crate::server::{
    billing::types::base::BillingPlan,
    shared::{entities::ChangeTriggersTopologyStaleness, events::types::TelemetryOperation},
};

#[derive(Debug, Clone, Serialize, Validate, Deserialize, Default, PartialEq, Eq, Hash, ToSchema, TS)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct OrganizationBase {
    pub stripe_customer_id: Option<String>,
    #[validate(length(min = 0, max = 100))]
    pub name: String,
    #[ts(skip)]
    pub plan: Option<BillingPlan>,
    pub plan_status: Option<String>,
    #[ts(skip)]
    pub onboarding: Vec<TelemetryOperation>,
}

#[derive(Debug, Clone, Validate, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema, TS)]
#[ts(export, export_to = "../../ui/src/lib/generated/")]
pub struct Organization {
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
    #[validate(nested)]
    pub base: OrganizationBase,
}

impl Organization {
    pub fn not_onboarded(&self, step: &TelemetryOperation) -> bool {
        !self.base.onboarding.contains(step)
    }

    pub fn has_onboarded(&self, step: &TelemetryOperation) -> bool {
        self.base.onboarding.contains(step)
    }
}

impl Display for Organization {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}: {:?}", self.base.name, self.id)
    }
}

impl ChangeTriggersTopologyStaleness<Organization> for Organization {
    fn triggers_staleness(&self, _other: Option<Organization>) -> bool {
        false
    }
}
