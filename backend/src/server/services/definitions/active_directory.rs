use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct ActiveDirectory;

impl ServiceDefinition for ActiveDirectory {
    fn name(&self) -> &'static str {
        "Active Directory"
    }
    fn description(&self) -> &'static str {
        "Microsoft directory service"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::IdentityAndAccess
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Port(PortBase::Ldap),
            Pattern::Port(PortBase::Samba),
            Pattern::Port(PortBase::Kerberos),
        ])
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/microsoft.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<ActiveDirectory>
));
