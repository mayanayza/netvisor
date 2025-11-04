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
        "a companion application to Sonarr and Radarr that manages and downloads subtitles"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortBase::new_tcp(6767))
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Bazarr"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Bazarr>));
