use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct OpenMediaVault;

impl ServiceDefinition for OpenMediaVault {
    fn name(&self) -> &'static str {
        "OpenMediaVault"
    }
    fn description(&self) -> &'static str {
        "Debian-based NAS solution"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Storage
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Port(PortType::Samba),
            Pattern::Endpoint(PortType::Http, "/", "openmediavault", None),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openmediavault.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<OpenMediaVault>
));
