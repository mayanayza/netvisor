use crate::server::networks::r#impl::Network;
use serde::Deserialize;
use serde::Serialize;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CreateNetworkRequest {
    pub network: Network,
    pub seed_baseline_data: bool,
}
