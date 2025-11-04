use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Sonarr;

impl ServiceDefinition for Sonarr {
    fn name(&self) -> &'static str {
        "Sonarr"
    }
    fn description(&self) -> &'static str {
        "a TV collection manager for Usenet and BitTorrent users."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortBase::new_tcp(8989))
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Sonarr"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Sonarr>));
