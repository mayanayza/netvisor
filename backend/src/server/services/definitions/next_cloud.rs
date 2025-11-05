use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct NextCloud;

impl ServiceDefinition for NextCloud {
    fn name(&self) -> &'static str {
        "NextCloud"
    }
    fn description(&self) -> &'static str {
        "Self-hosted cloud storage and collaboration platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Web
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::Http, "/", "nextcloud")
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nextcloud.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<NextCloud>));
