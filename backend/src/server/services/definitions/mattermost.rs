use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Mattermost;

impl ServiceDefinition for Mattermost {
    fn name(&self) -> &'static str {
        "Mattermost"
    }
    fn description(&self) -> &'static str {
        "Team messaging platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Collaboration
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(8065), "/api/v4/system/ping", "", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mattermost.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Mattermost>));
