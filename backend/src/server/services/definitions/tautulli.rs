use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Tautulli;

impl ServiceDefinition for Tautulli {
    fn name(&self) -> &'static str {
        "Tautulli"
    }
    fn description(&self) -> &'static str {
        "Monitor, view analytics, and receive notifications about your Plex Media Server."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(8181), "/", "Tautulli", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/tautulli.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Tautulli>));
