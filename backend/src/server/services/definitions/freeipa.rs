use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct FreeIPA;

impl ServiceDefinition for FreeIPA {
    fn name(&self) -> &'static str {
        "FreeIPA"
    }
    fn description(&self) -> &'static str {
        "Identity management system"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::IdentityAndAccess
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http, "/ipa/ui", "", Some(200..300))
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/freeipa.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<FreeIPA>));
