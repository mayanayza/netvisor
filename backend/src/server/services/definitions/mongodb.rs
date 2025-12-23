use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct MongoDB;

impl ServiceDefinition for MongoDB {
    fn name(&self) -> &'static str {
        "MongoDB"
    }
    fn description(&self) -> &'static str {
        "NoSQL document database"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Database
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortType::MongoDB)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mongodb.svg"
    }
    fn logo_needs_white_background(&self) -> bool {
        true
    }
    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<MongoDB>));
