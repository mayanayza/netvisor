use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Bazarr;

impl ServiceDefinition for Bazarr {
    fn name(&self) -> &'static str {
        "Bazarr"
    }
    fn description(&self) -> &'static str {
        "A companion application to Sonarr and Radarr that manages and downloads subtitles"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortBase::new_tcp(6767))
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/bazarr.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Bazarr>));
