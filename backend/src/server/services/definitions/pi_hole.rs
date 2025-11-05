use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct PiHole;

impl ServiceDefinition for PiHole {
    fn name(&self) -> &'static str {
        "Pi-Hole"
    }
    fn description(&self) -> &'static str {
        "Network-wide ad blocking DNS service"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::AdBlock
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::AnyOf(vec![
                Pattern::Port(PortBase::DnsUdp),
                Pattern::Port(PortBase::DnsTcp),
            ]),
            Pattern::Endpoint(PortBase::Http, "/admin", "pi-hole"),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pi-hole.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<PiHole>));
