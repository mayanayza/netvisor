use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

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
                Pattern::Port(PortType::DnsUdp),
                Pattern::Port(PortType::DnsTcp),
            ]),
            Pattern::Endpoint(PortType::Http, "/admin", "pi-hole", None),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pi-hole.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<PiHole>));
