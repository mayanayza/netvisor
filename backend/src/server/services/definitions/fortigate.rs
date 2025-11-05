use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Fortinet;

impl ServiceDefinition for Fortinet {
    fn name(&self) -> &'static str {
        "Fortinet"
    }
    fn description(&self) -> &'static str {
        "Fortinet security appliance"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::NetworkSecurity
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::Http, "/", "fortinet")
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/fortinet.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Fortinet>));
