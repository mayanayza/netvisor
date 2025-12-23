use crate::server::networks::r#impl::Network;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct CreateNetworkRequest {
    pub network: Network,
    /// Whether to seed baseline data (default subnets, etc.) for the network
    pub seed_baseline_data: bool,
}
