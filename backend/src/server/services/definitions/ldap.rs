use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct LDAP;

impl ServiceDefinition for LDAP {
    fn name(&self) -> &'static str {
        "Open LDAP"
    }
    fn description(&self) -> &'static str {
        "Generic LDAP directory service"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::IdentityAndAccess
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Port(PortType::Ldap),
            Pattern::Port(PortType::Ldaps),
        ])
    }
    fn is_generic(&self) -> bool {
        true
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openldap.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<LDAP>));
