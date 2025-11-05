use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Immich;

impl ServiceDefinition for Immich {
    fn name(&self) -> &'static str {
        "Immich"
    }
    fn description(&self) -> &'static str {
        "Self-hosted photo and video management solution"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(2283), "/photos", "Immich")
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/immich.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Immich>));
