use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Autobrr;

impl ServiceDefinition for Autobrr {
    fn name(&self) -> &'static str {
        "Autobrr"
    }
    fn description(&self) -> &'static str {
        "the modern autodl-irssi replacement."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortBase::new_tcp(7474))
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Autobrr"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Autobrr>));
