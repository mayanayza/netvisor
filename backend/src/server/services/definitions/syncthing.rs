use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Syncthing;

impl ServiceDefinition for Syncthing {
    fn name(&self) -> &'static str {
        "Syncthing"
    }
    fn description(&self) -> &'static str {
        "Continuous file synchronization service"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Backup
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::Http, "/", "Syncthing")
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/syncthing.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Syncthing>));
