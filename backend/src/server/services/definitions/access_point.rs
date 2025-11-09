use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct AccessPoint;

impl ServiceDefinition for AccessPoint {
    fn name(&self) -> &'static str {
        "Access Point"
    }
    fn description(&self) -> &'static str {
        "A generic wireless access point for WiFi connectivity"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::NetworkAccess
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::None
    }

    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<AccessPoint>));
