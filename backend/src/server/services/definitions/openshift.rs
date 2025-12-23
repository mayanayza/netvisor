use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct OpenShift;

impl ServiceDefinition for OpenShift {
    fn name(&self) -> &'static str {
        "OpenShift"
    }
    fn description(&self) -> &'static str {
        "Enterprise Kubernetes"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Virtualization
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Kubernetes, "/healthz", "openshift", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openshift.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<OpenShift>));
