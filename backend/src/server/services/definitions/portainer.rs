use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Portainer;

impl ServiceDefinition for Portainer {
    fn name(&self) -> &'static str {
        "Portainer"
    }
    fn description(&self) -> &'static str {
        "Container management web interface"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Virtualization
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Endpoint(PortBase::new_tcp(9443), "/", "portainer"),
            Pattern::AllOf(vec!(
                Pattern::Port(PortBase::new_tcp(9443)),
                Pattern::Port(PortBase::new_tcp(9000)),
                Pattern::Port(PortBase::new_tcp(8000)),
            ))
        ])
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "portainer"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Portainer>));
