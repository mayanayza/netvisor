use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct GlanceApp;

impl ServiceDefinition for GlanceApp {
    fn name(&self) -> &'static str {
        "Glance"
    }
    fn description(&self) -> &'static str {
        "A self-hosted dashboard that puts all your feeds in one place"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Dashboard
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http8080, "/manifest.json", "Glance", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/glance.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<GlanceApp>));
