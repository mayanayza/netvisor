use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Netbootxyz;

impl ServiceDefinition for Netbootxyz {
    fn name(&self) -> &'static str {
        "Netbootxyz"
    }
    fn description(&self) -> &'static str {
        "PXE Boot Server"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Storage
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(61208), "/", "Netbootxyz")
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Netbootxyz"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Netbootxyz>));
