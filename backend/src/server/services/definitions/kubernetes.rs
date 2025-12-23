use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Kubernetes;

impl ServiceDefinition for Kubernetes {
    fn name(&self) -> &'static str {
        "Kubernetes"
    }
    fn description(&self) -> &'static str {
        "Container orchestration platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Virtualization
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Port(PortType::Kubernetes),
            Pattern::AnyOf(vec![
                Pattern::Port(PortType::new_tcp(10250)),
                Pattern::Port(PortType::new_tcp(10259)),
                Pattern::Port(PortType::new_tcp(10257)),
                Pattern::Port(PortType::new_tcp(10256)),
            ]),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/kubernetes.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Kubernetes>));
