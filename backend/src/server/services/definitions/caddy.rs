use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Caddy;

impl ServiceDefinition for Caddy {
    fn name(&self) -> &'static str {
        "Caddy"
    }
    fn description(&self) -> &'static str {
        "Lightweight & versatile reverse proxy, web & file server"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::ReverseProxy
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(
            PortType::new_tcp(2019),
            "/reverse_proxy/upstreams",
            "num_requests",
            None,
        )
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/caddy.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Caddy>));
