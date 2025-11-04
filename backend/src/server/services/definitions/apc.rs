use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct APC;

impl ServiceDefinition for APC {
    fn name(&self) -> &'static str {
        "APC"
    }
    fn description(&self) -> &'static str {
        "APC Network-Connected UPS"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::Http, "/", "APC")
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Apc"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<APC>));
