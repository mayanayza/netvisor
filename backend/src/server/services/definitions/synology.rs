use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Synology;

impl ServiceDefinition for Synology {
    fn name(&self) -> &'static str {
        "Synology DSM"
    }
    fn description(&self) -> &'static str {
        "Synology DiskStation Manager NAS system"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Storage
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Endpoint(PortType::Http, "/", "synology", None),
            Pattern::Port(PortType::Ftp),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/synology.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Synology>));
