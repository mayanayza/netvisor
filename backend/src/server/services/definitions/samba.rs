use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Samba;

impl ServiceDefinition for Samba {
    fn name(&self) -> &'static str {
        "Samba"
    }
    fn description(&self) -> &'static str {
        "Generic SMB file server"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Storage
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortType::Samba)
    }
    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Samba>));
