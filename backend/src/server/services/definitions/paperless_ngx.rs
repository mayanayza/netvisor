use crate::server::hosts::r#impl::ports::PortBase;
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
        ServiceCategory::Web
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(8000), "/", "Paperless-ngx project", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/paperless-ngx.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<PaperlessNGX>
));
