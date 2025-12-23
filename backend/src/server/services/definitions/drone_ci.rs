use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct DroneCI;

impl ServiceDefinition for DroneCI {
    fn name(&self) -> &'static str {
        "Drone"
    }
    fn description(&self) -> &'static str {
        "Container-native CI platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Development
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Endpoint(PortType::Http, "/", "drone", None),
            Pattern::Endpoint(PortType::Http, "/api/user", "", None),
        ])
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/drone.png"
    }
    fn logo_needs_white_background(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<DroneCI>));
