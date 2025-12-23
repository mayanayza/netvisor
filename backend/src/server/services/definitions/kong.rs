use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Kong;

impl ServiceDefinition for Kong {
    fn name(&self) -> &'static str {
        "Kong"
    }
    fn description(&self) -> &'static str {
        "API gateway"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::ReverseProxy
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(8001), "/", "kong", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://simpleicons.org/icons/kong.svg"
    }
    fn logo_needs_white_background(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Kong>));
