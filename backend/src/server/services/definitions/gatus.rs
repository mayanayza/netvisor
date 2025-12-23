use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Gatus;

impl ServiceDefinition for Gatus {
    fn name(&self) -> &'static str {
        "Gatus"
    }
    fn description(&self) -> &'static str {
        "Automated developer-oriented status page"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http8080, "/manifest.json", "Gatus", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/gatus.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Gatus>));
