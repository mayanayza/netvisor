use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

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
        Pattern::Endpoint(PortType::new_tcp(8123), "/", "home assistant", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/home-assistant.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<HomeAssistant>
));
