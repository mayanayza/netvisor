use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct JiraServer;

impl ServiceDefinition for JiraServer {
    fn name(&self) -> &'static str {
        "Jira"
    }
    fn description(&self) -> &'static str {
        "Project management platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Collaboration
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(
            PortBase::Http8080,
            "/rest/api/2/serverInfo",
            "jira",
            Some(200..300),
        )
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<JiraServer>));
