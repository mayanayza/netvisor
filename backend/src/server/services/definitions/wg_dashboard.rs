use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;
use crate::server::subnets::types::base::SubnetType;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct WgDashboard;

impl ServiceDefinition for WgDashboard {
    fn name(&self) -> &'static str {
        "WGDashboard"
    }
    fn description(&self) -> &'static str {
        "Wireguard dashboard for visualizing and managing wireguard clients and server"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Dashboard
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Port(PortBase::new_tcp(10086)),
            Pattern::Not(&Pattern::SubnetIsType(SubnetType::VpnTunnel)),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/wireguard.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<WgDashboard>));
