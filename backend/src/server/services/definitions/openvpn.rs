use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct OpenVpn;

impl ServiceDefinition for OpenVpn {
    fn name(&self) -> &'static str {
        "OpenVPN"
    }
    fn description(&self) -> &'static str {
        "OpenVPN server"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::VPN
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortType::OpenVPN)
    }
    fn is_generic(&self) -> bool {
        true
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openvpn.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<OpenVpn>));
