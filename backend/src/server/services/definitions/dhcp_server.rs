use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct DhcpServer;

impl ServiceDefinition for DhcpServer {
    fn name(&self) -> &'static str {
        "Dhcp Server"
    }
    fn description(&self) -> &'static str {
        "A generic Dhcp server"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::NetworkCore
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortType::Dhcp)
    }

    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<DhcpServer>));
