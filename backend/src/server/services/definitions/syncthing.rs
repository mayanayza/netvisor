use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Syncthing;

impl ServiceDefinition for Syncthing {
    fn name(&self) -> &'static str {
        "Syncthing"
    }
    fn description(&self) -> &'static str {
        "Continuous file synchronization service"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Backup
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Endpoint(PortType::Http, "/", "Syncthing", None),
            Pattern::Port(PortType::new_tcp(22000)),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/syncthing.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Syncthing>));
