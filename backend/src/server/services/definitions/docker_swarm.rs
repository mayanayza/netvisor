use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct DockerSwarm;

impl ServiceDefinition for DockerSwarm {
    fn name(&self) -> &'static str {
        "Docker Swarm"
    }
    fn description(&self) -> &'static str {
        "Docker native clustering and orchestration"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Virtualization
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Port(PortBase::new_tcp(2377)),
            Pattern::Port(PortBase::new_tcp(7946)),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/docker.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<DockerSwarm>));
