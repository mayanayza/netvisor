use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Bamboo;

impl ServiceDefinition for Bamboo {
    fn name(&self) -> &'static str {
        "Bamboo"
    }
    fn description(&self) -> &'static str {
        "CI/CD server"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Development
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(8085), "/", "bamboo", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/atlassian-bamboo.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Bamboo>));
