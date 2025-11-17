use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Ntfy;

impl ServiceDefinition for Ntfy {
    fn name(&self) -> &'static str {
        "Ntfy"
    }
    fn description(&self) -> &'static str {
        "Simple HTTP-based pub-sub notification service"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::MessageQueue
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Endpoint(PortBase::Http, "/", "ntfy web", None),
            Pattern::Endpoint(PortBase::new_tcp(2856), "/", "ntfy web", None),
        ])
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/ntfy.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Ntfy>));
