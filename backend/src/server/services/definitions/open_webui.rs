use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct OpenWebUI;

impl ServiceDefinition for OpenWebUI {
    fn name(&self) -> &'static str {
        "Open WebUI"
    }
    fn description(&self) -> &'static str {
        "Open, extensible, user-friendly interface for AI"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Development
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http8080, "/manifest.json", "Open WebUI", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/open-webui-light.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<OpenWebUI>));
