use serde::Serialize;
use serde::Deserialize;
use crate::server::billing::types::base::BillingPlan;


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateCheckoutRequest {
    pub plan: BillingPlan,
    pub url: String
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateCheckoutResponse {
    pub url: String
}