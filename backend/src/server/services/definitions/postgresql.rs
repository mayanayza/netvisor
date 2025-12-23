use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

// PostgreSQL
#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct PostgreSQL;

impl ServiceDefinition for PostgreSQL {
    fn name(&self) -> &'static str {
        "PostgreSQL"
    }
    fn description(&self) -> &'static str {
        "Open-source relational database"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Database
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortType::PostgreSQL)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/postgresql.svg"
    }
    fn logo_needs_white_background(&self) -> bool {
        true
    }
    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<PostgreSQL>));
