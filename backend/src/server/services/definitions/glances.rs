use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Glances;

impl ServiceDefinition for Glances {
    fn name(&self) -> &'static str {
        "Glances"
    }
    fn description(&self) -> &'static str {
        "An open-source system cross-platform monitoring tool."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(61208), "/", "Glances", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/glances.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Glances>));
