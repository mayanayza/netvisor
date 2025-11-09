use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Firewall;

impl ServiceDefinition for Firewall {
    fn name(&self) -> &'static str {
        "Firewall"
    }
    fn description(&self) -> &'static str {
        "Generic network security appliance"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::NetworkSecurity
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::None
    }

    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Firewall>));
