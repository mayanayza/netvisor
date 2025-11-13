use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Plex;

impl ServiceDefinition for Plex {
    fn name(&self) -> &'static str {
        "Plex Media Server"
    }
    fn description(&self) -> &'static str {
        "Media server for streaming personal content"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(32400), "/web/index.html", "Plex", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/plex.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Plex>));
