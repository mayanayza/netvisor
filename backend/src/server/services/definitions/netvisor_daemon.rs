use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct NetvisorDaemon;

impl ServiceDefinition for NetvisorDaemon {
    fn name(&self) -> &'static str {
        "NetVisor Daemon API"
    }
    fn description(&self) -> &'static str {
        "NetVisor Daemon API for network scanning"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Netvisor
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(60073), "/api/health", "netvisor")
    }

    fn logo_url(&self) -> &'static str {
        "/logos/netvisor-logo.png"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<NetvisorDaemon>
));
