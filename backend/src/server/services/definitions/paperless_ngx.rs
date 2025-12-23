use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct PaperlessNGX;

impl ServiceDefinition for PaperlessNGX {
    fn name(&self) -> &'static str {
        "Paperless-NGX"
    }
    fn description(&self) -> &'static str {
        "Community-supported document management system"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Office
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(
            PortType::new_tcp(8000),
            "/static/frontend/en-US/manifest.webmanifest",
            "Paperless-ngx",
            None,
        )
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/paperless-ngx.svg"
    }
    fn logo_needs_white_background(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<PaperlessNGX>
));
