use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Vault;

impl ServiceDefinition for Vault {
    fn name(&self) -> &'static str {
        "Vault"
    }
    fn description(&self) -> &'static str {
        "Secrets management"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::IdentityAndAccess
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(8200), "/v1/sys/health", "vault", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/hashicorp-vault.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Vault>));
