use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Tautulli;

impl ServiceDefinition for Tautulli {
    fn name(&self) -> &'static str {
        "Tautulli"
    }
    fn description(&self) -> &'static str {
        "monitor, view analytics, and receive notifications about your Plex Media Server."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(8181), "/", "Tautulli")
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Tautulli"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Tautulli>));
