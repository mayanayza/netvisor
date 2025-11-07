use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::{Pattern, Vendor};

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct RingDoorbell;

impl ServiceDefinition for RingDoorbell {
    fn name(&self) -> &'static str {
        "Ring Doorbell"
    }

    fn description(&self) -> &'static str {
        "Ring video doorbell or security camera"
    }

    fn category(&self) -> ServiceCategory {
        ServiceCategory::IoT
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::MacVendor(Vendor::AMAZON),
            Pattern::AnyOf(vec![
                Pattern::Port(PortBase::new_tcp(8557)),
                Pattern::Port(PortBase::new_tcp(9998)),
                Pattern::Port(PortBase::new_tcp(19302)),
                Pattern::Port(PortBase::new_tcp(9999)),
            ]),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://simpleicons.org/icons/ring.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<RingDoorbell>
));
