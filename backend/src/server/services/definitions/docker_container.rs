use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::base::DiscoverySessionServiceMatchParams;
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::{MatchConfidence, Pattern};
use crate::server::services::r#impl::virtualization::{
    DockerVirtualization, ServiceVirtualization,
};

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct DockerContainer;

impl ServiceDefinition for DockerContainer {
    fn name(&self) -> &'static str {
        "Docker Container"
    }
    fn description(&self) -> &'static str {
        "A generic docker container"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Virtualization
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::DockerContainer,
            Pattern::Custom(
                |p: &DiscoverySessionServiceMatchParams| {
                    // If there's a matched service with the id of the container, the container was already detected as a non-generic service
                    let c_id = match p.baseline_params.virtualization {
                        Some(ServiceVirtualization::Docker(DockerVirtualization {
                            container_id: Some(id),
                            ..
                        })) => id,
                        _ => return false, // No docker container_id -> not a docker container
                    };

                    p.service_params
                        .matched_services
                        .iter()
                        .all(|s| match &s.base.virtualization {
                            Some(ServiceVirtualization::Docker(DockerVirtualization {
                                container_id,
                                ..
                            })) if container_id.is_some() => *container_id != Some(c_id.clone()),
                            _ => true,
                        })
                },
                "No other services with this container's ID have been matched",
                "A service with this container's ID has already been matched",
                MatchConfidence::Low,
            ),
        ])
    }

    fn is_generic(&self) -> bool {
        true
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/docker.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<DockerContainer>
));
