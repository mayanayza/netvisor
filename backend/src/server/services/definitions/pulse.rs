use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Pulse;

impl ServiceDefinition for Pulse {
    fn name(&self) -> &'static str {
        "Pulse"
    }
    fn description(&self) -> &'static str {
        "Proxmox Cluster, Docker and host monitor"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Endpoint(PortBase::new_tcp(7655), "/", "Pulse"),
            Pattern::Endpoint(
                PortBase::new_tcp(7655),
                "/api/health",
                "proxyInstallScriptAvailable",
            ),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pulse.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Pulse>));
