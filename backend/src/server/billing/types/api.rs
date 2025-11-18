use crate::server::billing::types::base::BillingPlan;
use serde::Deserialize;
use serde::Serialize;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateCheckoutRequest {
    pub plan: BillingPlan,
}
