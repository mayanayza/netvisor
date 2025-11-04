use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Overseerr;

impl ServiceDefinition for Overseerr {
    fn name(&self) -> &'static str {
        "Overseerr"
    }
    fn description(&self) -> &'static str {
        "open source software application for managing requests for your media library."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(5055), "/", "Overseerr")
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Overseerr"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Overseerr>));
