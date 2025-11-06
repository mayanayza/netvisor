use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Glances;

impl ServiceDefinition for Glances {
    fn name(&self) -> &'static str {
        "Glances"
    }
    fn description(&self) -> &'static str {
        "An open-source system cross-platform monitoring tool."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(61208), "/", "Glances")
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/glances.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Glances>));
