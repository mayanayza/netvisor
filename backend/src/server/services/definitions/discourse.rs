use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Discourse;

impl ServiceDefinition for Discourse {
    fn name(&self) -> &'static str {
        "Discourse"
    }
    fn description(&self) -> &'static str {
        "Discussion platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Publishing
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http, "/srv/status", "discourse", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/discourse.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Discourse>));
