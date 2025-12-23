use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct PowerDNS;

impl ServiceDefinition for PowerDNS {
    fn name(&self) -> &'static str {
        "PowerDNS"
    }
    fn description(&self) -> &'static str {
        "Authoritative DNS server with API"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::DNS
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Port(PortType::DnsUdp),
            Pattern::Port(PortType::DnsTcp),
            Pattern::Port(PortType::Http8081),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/powerdns.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<PowerDNS>));
