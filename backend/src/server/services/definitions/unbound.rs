use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Unbound;

impl ServiceDefinition for Unbound {
    fn name(&self) -> &'static str {
        "Unbound DNS"
    }
    fn description(&self) -> &'static str {
        "Recursive DNS resolver with control interface"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::DNS
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Port(PortType::DnsUdp),
            Pattern::Port(PortType::new_tcp(8953)),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/unbound.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Unbound>));
