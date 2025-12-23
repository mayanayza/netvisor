use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct ConfluenceServer;

impl ServiceDefinition for ConfluenceServer {
    fn name(&self) -> &'static str {
        "Confluence"
    }
    fn description(&self) -> &'static str {
        "Team collaboration wiki"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::ProjectManagement
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(8090), "/", "confluence", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/confluence.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<ConfluenceServer>
));
