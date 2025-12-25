use crate::server::billing::types::base::BillingPlan;
use serde::Deserialize;
use serde::Serialize;
use utoipa::ToSchema;

#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct CreateCheckoutRequest {
    pub plan: BillingPlan,
    pub url: String,
}
