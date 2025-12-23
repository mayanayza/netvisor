use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

// Jenkins
#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Jenkins;

impl ServiceDefinition for Jenkins {
    fn name(&self) -> &'static str {
        "Jenkins"
    }
    fn description(&self) -> &'static str {
        "Automation server for CI/CD"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Development
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http8080, "/", "jenkins.io", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jenkins.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Jenkins>));
