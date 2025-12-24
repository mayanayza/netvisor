use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Gitea;

impl ServiceDefinition for Gitea {
    fn name(&self) -> &'static str {
        "Gitea"
    }
    fn description(&self) -> &'static str {
        "DevOps platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Development
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(
            PortBase::Http3000,
            "/explore/repos",
            "Powered by Gitea",
            None,
        )
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/gitea.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Gitea>));
