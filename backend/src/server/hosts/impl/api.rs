use serde::{Deserialize, Serialize};

use crate::server::{hosts::r#impl::base::Host, services::r#impl::base::Service};

/// None in services = don't do anything to services, no services to create or update
/// Some(vec!()) = delete all services
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HostWithServicesRequest {
    pub host: Host,
    #[serde(default)]
    pub services: Option<Vec<Service>>,
}
