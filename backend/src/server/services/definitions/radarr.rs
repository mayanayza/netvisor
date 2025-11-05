use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Radarr;

impl ServiceDefinition for Radarr {
    fn name(&self) -> &'static str {
        "Radarr"
    }
    fn description(&self) -> &'static str {
        "A movie collection manager for Usenet and BitTorrent users."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortBase::new_tcp(7878))
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/radarr.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Radarr>));
