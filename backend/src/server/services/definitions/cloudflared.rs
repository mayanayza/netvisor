use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

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
        Pattern::Endpoint(PortType::Http, "/metrics", "cloudflared", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cloudflare.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Cloudflared>));
