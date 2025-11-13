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
        Pattern::AllOf(vec![
            Pattern::Endpoint(PortBase::Http, "/", "opnsense", None),
            Pattern::AnyOf(vec![
                Pattern::Port(PortBase::DnsTcp),
                Pattern::Port(PortBase::DnsUdp),
                Pattern::Port(PortBase::Ssh),
                Pattern::Port(PortBase::Ntp),
                Pattern::Port(PortBase::Dhcp),
            ]),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/opnsense.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<OpnSense>));
