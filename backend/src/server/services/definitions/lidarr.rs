use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Lidarr;

impl ServiceDefinition for Lidarr {
    fn name(&self) -> &'static str {
        "Lidarr"
    }
    fn description(&self) -> &'static str {
        "a music collection manager for Usenet and BitTorrent users."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortBase::new_tcp(8686))
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Lidarr"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Lidarr>));
