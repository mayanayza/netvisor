use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct DnsServer;

impl ServiceDefinition for DnsServer {
    fn name(&self) -> &'static str {
        "Dns Server"
    }
    fn description(&self) -> &'static str {
        "A generic Dns server"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::DNS
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Port(PortType::DnsTcp),
            Pattern::Port(PortType::DnsUdp),
        ])
    }

    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<DnsServer>));
