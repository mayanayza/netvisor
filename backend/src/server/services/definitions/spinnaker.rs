use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Spinnaker;

impl ServiceDefinition for Spinnaker {
    fn name(&self) -> &'static str {
        "Spinnaker"
    }
    fn description(&self) -> &'static str {
        "Multi-cloud CD platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Development
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::None
    }
    fn logo_url(&self) -> &'static str {
        "https://simpleicons.org/icons/spinnaker.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Spinnaker>));
