use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Grocy;

impl ServiceDefinition for Grocy {
    fn name(&self) -> &'static str {
        "Grocy"
    }
    fn description(&self) -> &'static str {
        "Web-based self-hosted groceries & household management solution"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::HomeAutomation
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Endpoint(PortType::Http, "/", "grocy.css", None),
            Pattern::Endpoint(PortType::Https, "/", "grocy.css", None),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/grocy.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Grocy>));
