use crate::server::ports::r#impl::base::PortType;
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
        "Monitoring for container"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(
            PortType::Http8080,
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
