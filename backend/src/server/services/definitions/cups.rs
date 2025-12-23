use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct CUPS;

impl ServiceDefinition for CUPS {
    fn name(&self) -> &'static str {
        "CUPS"
    }
    fn description(&self) -> &'static str {
        "Common Unix Printing System"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Printer
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Port(PortType::Ipp),
            Pattern::Endpoint(PortType::Http, "/", "CUPS", None),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cups.svg"
    }
    fn logo_needs_white_background(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<CUPS>));
