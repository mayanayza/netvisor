use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Homarr;

impl ServiceDefinition for Homarr {
    fn name(&self) -> &'static str {
        "Homarr"
    }
    fn description(&self) -> &'static str {
        "A sleek, modern dashboard"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Dashboard
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortType::new_tcp(7575))
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/homarr.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Homarr>));
