use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct BackRest;

impl ServiceDefinition for BackRest {
    fn name(&self) -> &'static str {
        "BackRest"
    }
    fn description(&self) -> &'static str {
        "Web UI and orchestrator for Restic"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Backup
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(9898), "/", "BackRest", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/backrest-light.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<BackRest>));
