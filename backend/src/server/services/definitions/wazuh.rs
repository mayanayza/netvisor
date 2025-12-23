use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Wazuh;

impl ServiceDefinition for Wazuh {
    fn name(&self) -> &'static str {
        "Wazuh"
    }
    fn description(&self) -> &'static str {
        "Security platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(55000), "/", "wazuh", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/wazuh.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Wazuh>));
