use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct PeaNut;

impl ServiceDefinition for PeaNut {
    fn name(&self) -> &'static str {
        "PeaNUT"
    }
    fn description(&self) -> &'static str {
        "A tiny dashboard for Network UPS Tools"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http3000, "/api/v1/info", "peanut", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/peanut.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<PeaNut>));
