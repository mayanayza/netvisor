use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct ScanopyDaemon;

impl ServiceDefinition for ScanopyDaemon {
    fn name(&self) -> &'static str {
        "Scanopy Daemon"
    }
    fn description(&self) -> &'static str {
        "Automatically discover and visually document network infrastructure"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Scanopy
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(60073), "/api/health", "scanopy", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/scanopy/website@main/static/scanopy-logo.png"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<ScanopyDaemon>
));
