use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct UnifiController;

impl ServiceDefinition for UnifiController {
    fn name(&self) -> &'static str {
        "UniFi Controller"
    }
    fn description(&self) -> &'static str {
        "Ubiquiti UniFi network controller"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::NetworkAccess
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Https8443, "/manage", "UniFi", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/unifi.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<UnifiController>
));
