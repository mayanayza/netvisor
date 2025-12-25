use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Frigate;

impl ServiceDefinition for Frigate {
    fn name(&self) -> &'static str {
        "Frigate"
    }
    fn description(&self) -> &'static str {
        "NVR with realtime object detection for IP Cameras"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::IoT
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Endpoint(PortBase::Https, "/", "<title>Frigate</title>", None),
            Pattern::Endpoint(PortBase::Http5000, "/", "<title>Frigate</title>", None),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/frigate.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Frigate>));
