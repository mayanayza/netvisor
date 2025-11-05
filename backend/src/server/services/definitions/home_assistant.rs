use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct HomeAssistant;

impl ServiceDefinition for HomeAssistant {
    fn name(&self) -> &'static str {
        "Home Assistant"
    }
    fn description(&self) -> &'static str {
        "Open-source home automation platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::HomeAutomation
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(8123), "/auth/authorize", "home assistant")
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/home-assistant.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<HomeAssistant>
));
