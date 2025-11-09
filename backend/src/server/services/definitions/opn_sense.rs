use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct OpnSense;

impl ServiceDefinition for OpnSense {
    fn name(&self) -> &'static str {
        "OPNsense"
    }
    fn description(&self) -> &'static str {
        "Open-source firewall and routing platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::NetworkSecurity
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::Http, "/", "opnsense")
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/opnsense.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<OpnSense>));
