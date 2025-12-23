use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Bind9;

impl ServiceDefinition for Bind9 {
    fn name(&self) -> &'static str {
        "Bind9"
    }
    fn description(&self) -> &'static str {
        "Berkeley Internet Name Domain DNS server"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::DNS
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Port(PortType::DnsUdp),
            Pattern::Port(PortType::new_tcp(8053)),
        ])
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Bind9>));
