use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Cadvisor;

impl ServiceDefinition for Cadvisor {
    fn name(&self) -> &'static str {
        "cAdvisor"
    }
    fn description(&self) -> &'static str {
        "Graph database"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Database
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(
            PortBase::Http8080,
            "/api/v1.0/containers/",
            "cAdvisor",
            None,
        )
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/cadvisor.png"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Cadvisor>));
