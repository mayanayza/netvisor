use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct CoolerControl;

impl ServiceDefinition for CoolerControl {
    fn name(&self) -> &'static str {
        "CoolerControl"
    }
    fn description(&self) -> &'static str {
        "Monitor temperatures, fan speeds, and power in real time."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(11987), "/", "CoolerControl")
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cooler-control.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<CoolerControl>
));
