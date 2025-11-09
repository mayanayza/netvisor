use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Client;

impl ServiceDefinition for Client {
    fn name(&self) -> &'static str {
        "Client"
    }
    fn description(&self) -> &'static str {
        "A generic client device that initiates connections to services"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Mobile
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::None // Clients aren't typically discoverable
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Client>));
