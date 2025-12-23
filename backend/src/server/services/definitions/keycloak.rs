use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

// Keycloak
#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Keycloak;

impl ServiceDefinition for Keycloak {
    fn name(&self) -> &'static str {
        "Keycloak"
    }
    fn description(&self) -> &'static str {
        "Identity and access management"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::IdentityAndAccess
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http8080, "/", "/keycloak/", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/keycloak.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Keycloak>));
