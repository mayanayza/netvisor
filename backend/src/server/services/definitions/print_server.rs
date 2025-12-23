use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct PrintServer;

impl ServiceDefinition for PrintServer {
    fn name(&self) -> &'static str {
        "Print Server"
    }
    fn description(&self) -> &'static str {
        "A generic printing service"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Printer
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Port(PortType::Ipp),
            Pattern::Port(PortType::LdpTcp),
            Pattern::Port(PortType::LdpUdp),
        ])
    }

    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<PrintServer>));
