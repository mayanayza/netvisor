use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::{MatchConfidence, Pattern};

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct OpenPorts;

impl ServiceDefinition for OpenPorts {
    fn name(&self) -> &'static str {
        "Unclaimed Open Ports"
    }
    fn description(&self) -> &'static str {
        "Unclaimed open ports. Reassign to the correct service if known."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::OpenPorts
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Custom(
            |p| !p.service_params.unbound_ports.is_empty(),
            |p| p.service_params.unbound_ports.to_vec(),
            "Has unbound open ports",
            "No unbound ports remaining",
            MatchConfidence::NotApplicable,
        )
    }

    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<OpenPorts>));
