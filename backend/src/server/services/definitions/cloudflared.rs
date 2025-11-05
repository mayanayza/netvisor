use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Cloudflared;

impl ServiceDefinition for Cloudflared {
    fn name(&self) -> &'static str {
        "Cloudflared"
    }
    fn description(&self) -> &'static str {
        "Cloudflare tunnel daemon"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::ReverseProxy
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::Http, "/metrics", "cloudflared")
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cloudflare.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Cloudflared>));
