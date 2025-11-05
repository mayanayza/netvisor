use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

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
            Pattern::Port(PortBase::Ipp),
            Pattern::Endpoint(PortBase::Http, "/", "CUPS"),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cups.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<CUPS>));
