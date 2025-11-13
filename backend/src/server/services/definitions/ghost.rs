use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Ghost;

impl ServiceDefinition for Ghost {
    fn name(&self) -> &'static str {
        "Ghost"
    }
    fn description(&self) -> &'static str {
        "Publishing platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Web
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(2368), "/", "ghost", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/ghost.png"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Ghost>));
