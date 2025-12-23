use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Veeam;

impl ServiceDefinition for Veeam {
    fn name(&self) -> &'static str {
        "Veeam"
    }
    fn description(&self) -> &'static str {
        "Backup and replication"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Backup
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        // Veeam Backup Server
        Pattern::Port(PortType::new_tcp(9392))
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/veeam.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Veeam>));
