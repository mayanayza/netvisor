use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct UptimeKuma;

impl ServiceDefinition for UptimeKuma {
    fn name(&self) -> &'static str {
        "UptimeKuma"
    }
    fn description(&self) -> &'static str {
        "Self-hosted uptime monitoring tool"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::Http, "/", "Uptime Kuma")
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/uptime-kuma.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<UptimeKuma>));
