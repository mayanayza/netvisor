use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct RocketChat;

impl ServiceDefinition for RocketChat {
    fn name(&self) -> &'static str {
        "Rocket.Chat"
    }
    fn description(&self) -> &'static str {
        "Team communication platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Messaging
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http3000, "/api/info", "rocket", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/rocket-chat.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<RocketChat>));
