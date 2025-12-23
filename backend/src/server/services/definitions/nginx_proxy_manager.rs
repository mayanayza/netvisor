use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct NginxProxyManager;

impl ServiceDefinition for NginxProxyManager {
    fn name(&self) -> &'static str {
        "Nginx Proxy Manager"
    }
    fn description(&self) -> &'static str {
        "Web-based Nginx proxy management interface"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::ReverseProxy
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http, "", "nginx proxy manager", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nginx-proxy-manager.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<NginxProxyManager>
));
