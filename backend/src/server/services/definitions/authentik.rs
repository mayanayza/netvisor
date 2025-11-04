use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Authentik;

impl ServiceDefinition for Authentik {
    fn name(&self) -> &'static str {
        "Authentik"
    }
    fn description(&self) -> &'static str {
        "a self-hosted, open source identity provider"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Endpoint(PortBase::Http, "/", "authentik"),
            Pattern::Endpoint(PortBase::Https, "/", "authentik")
        ])
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Authentik"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Authentik>));
