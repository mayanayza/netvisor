use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Rancher;

impl ServiceDefinition for Rancher {
    fn name(&self) -> &'static str {
        "Rancher"
    }
    fn description(&self) -> &'static str {
        "Kubernetes management"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Virtualization
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http, "/v3", "rancher", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/rancher.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Rancher>));
