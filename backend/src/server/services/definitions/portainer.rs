use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Portainer;

impl ServiceDefinition for Portainer {
    fn name(&self) -> &'static str {
        "Portainer"
    }
    fn description(&self) -> &'static str {
        "Container management web interface"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Virtualization
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Endpoint(PortType::Https9443, "/#!/auth", "portainer.io", None),
            Pattern::Endpoint(PortType::Http9000, "/", "portainer.io", None),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/portainer.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Portainer>));
