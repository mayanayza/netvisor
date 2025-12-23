use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct ESPHome;

impl ServiceDefinition for ESPHome {
    fn name(&self) -> &'static str {
        "ESPHome"
    }
    fn description(&self) -> &'static str {
        "ESP device management"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::HomeAutomation
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        // ESPHome API port
        Pattern::Port(PortType::new_tcp(6052))
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/esphome.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<ESPHome>));
