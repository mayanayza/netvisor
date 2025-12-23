use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Bitwarden;

impl ServiceDefinition for Bitwarden {
    fn name(&self) -> &'static str {
        "Bitwarden"
    }
    fn description(&self) -> &'static str {
        "Password manager"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::IdentityAndAccess
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http, "/api/config", "bitwarden", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/bitwarden.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Bitwarden>));
