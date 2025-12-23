use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Wireguard;

impl ServiceDefinition for Wireguard {
    fn name(&self) -> &'static str {
        "WireGuard"
    }
    fn description(&self) -> &'static str {
        "WireGuard VPN"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::VPN
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortType::Wireguard)
    }
    fn is_generic(&self) -> bool {
        true
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/wireguard.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Wireguard>));
