use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Jellyseerr;

impl ServiceDefinition for Jellyseerr {
    fn name(&self) -> &'static str {
        "Jellyseerr"
    }
    fn description(&self) -> &'static str {
        "Open source software application for managing requests for your media library."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(5055), "/", "Jellyseerr")
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jellyseerr.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Jellyseerr>));
