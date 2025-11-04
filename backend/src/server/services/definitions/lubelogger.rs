use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

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
        Pattern::Endpoint(PortBase::HttpAlt, "/", "LubeLogger")
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Lubelogger"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Lubelogger>));
