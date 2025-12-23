use crate::server::ports::r#impl::base::PortType;
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
            Pattern::Port(PortType::Ldap),
            Pattern::Port(PortType::Samba),
            Pattern::Port(PortType::Kerberos),
        ])
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/microsoft.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<ActiveDirectory>
));
