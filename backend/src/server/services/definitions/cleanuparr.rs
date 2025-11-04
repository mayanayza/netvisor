use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Cleanuparr;

impl ServiceDefinition for Cleanuparr {
    fn name(&self) -> &'static str {
        "Cleanuparr"
    }
    fn description(&self) -> &'static str {
        "Torrent cleanup tool for Sonarr and Radarr"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortBase::new_tcp(11011))
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Cleanuparr"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Cleanuparr>));
