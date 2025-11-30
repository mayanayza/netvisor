use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct NetvisorServer;

impl ServiceDefinition for NetvisorServer {
    fn name(&self) -> &'static str {
        "NetVisor Server API"
    }
    fn description(&self) -> &'static str {
        "NetVisor Server API for network management"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Netvisor
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(60072), "/api/health", "netvisor", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/netvisor.png"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<NetvisorServer>
));
