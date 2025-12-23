use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Jotty;

impl ServiceDefinition for Jotty {
    fn name(&self) -> &'static str {
        "Jotty"
    }
    fn description(&self) -> &'static str {
        "A simple, self-hosted app for your checklists and notes"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Office
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http3000, "/site.webmanifest", "jotty", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jotty.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Jotty>));
