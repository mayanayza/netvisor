use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct NFSServer;

impl ServiceDefinition for NFSServer {
    fn name(&self) -> &'static str {
        "NFS"
    }
    fn description(&self) -> &'static str {
        "Generic network file system"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Storage
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortType::Nfs)
    }
    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<NFSServer>));
