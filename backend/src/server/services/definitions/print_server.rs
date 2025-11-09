use crate::server::hosts::r#impl::ports::PortBase;
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
            Pattern::Port(PortBase::Ipp),
            Pattern::Port(PortBase::LdpTcp),
            Pattern::Port(PortBase::LdpUdp),
        ])
    }

    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<PrintServer>));
