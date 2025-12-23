use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

// HAProxy
#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct HAProxy;

impl ServiceDefinition for HAProxy {
    fn name(&self) -> &'static str {
        "HAProxy"
    }
    fn description(&self) -> &'static str {
        "Load balancer and proxy"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::ReverseProxy
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(8404), "/stats", "haproxy", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/haproxy.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<HAProxy>));
