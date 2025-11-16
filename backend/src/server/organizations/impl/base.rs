use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::fmt::Display;
use stripe_billing::SubscriptionStatus;
use uuid::Uuid;
use validator::Validate;

use crate::server::billing::types::base::BillingPlan;

#[derive(Debug, Clone, Serialize, Validate, Deserialize, Default)]
pub struct OrganizationBase {
    pub stripe_customer_id: Option<String>,
    #[validate(length(min = 0, max = 100))]
    pub name: String,
    pub plan: Option<BillingPlan>,
    pub plan_status: Option<SubscriptionStatus>,
    pub is_onboarded: bool,
}

#[derive(Debug, Clone, Validate, Serialize, Deserialize)]
pub struct Organization {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    #[validate(nested)]
    pub base: OrganizationBase,
}

impl Display for Organization {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}: {:?}", self.base.name, self.id)
    }
}
