use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Homarr;

impl ServiceDefinition for Homarr {
    fn name(&self) -> &'static str {
        "Homarr"
    }
    fn description(&self) -> &'static str {
        "A sleek, modern dashboard"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Dashboard
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortBase::new_tcp(7575))
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Homarr"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Homarr>));
