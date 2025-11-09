use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Homepage;

impl ServiceDefinition for Homepage {
    fn name(&self) -> &'static str {
        "Homepage"
    }
    fn description(&self) -> &'static str {
        "A self-hosted dashboard for your homelab"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Dashboard
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(
            PortBase::new_tcp(3000),
            "/site.webmanifest",
            "Homepage"
        )
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/webp/homepage.webp"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Homepage>));
