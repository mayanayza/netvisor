use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Bacula;

impl ServiceDefinition for Bacula {
    fn name(&self) -> &'static str {
        "Bacula"
    }
    fn description(&self) -> &'static str {
        "Network backup solution"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Backup
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        // Bacula Director port
        Pattern::Port(PortType::new_tcp(9101))
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/bacula.png"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Bacula>));
