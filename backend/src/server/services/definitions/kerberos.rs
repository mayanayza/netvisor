use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Kerberos;

impl ServiceDefinition for Kerberos {
    fn name(&self) -> &'static str {
        "Kerberos"
    }
    fn description(&self) -> &'static str {
        "Kerberos authentication service"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::IdentityAndAccess
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortType::Kerberos)
    }
    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Kerberos>));
