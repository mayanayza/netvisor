use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Lubelogger;

impl ServiceDefinition for Lubelogger {
    fn name(&self) -> &'static str {
        "Lubelogger"
    }
    fn description(&self) -> &'static str {
        "Vehicle Maintenance Records and Fuel Mileage Tracker"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::HomeAutomation
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http8080, "/", "Garage - LubeLogger", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/lubelogger.png"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Lubelogger>));
