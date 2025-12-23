use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct MeTube;

impl ServiceDefinition for MeTube {
    fn name(&self) -> &'static str {
        "MeTube"
    }
    fn description(&self) -> &'static str {
        "Self-hosted YouTube downloader"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http8081, "/manifest.webmanifest", "MeTube", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/metube.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<MeTube>));
