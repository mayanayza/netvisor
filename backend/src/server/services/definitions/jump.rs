use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Jump;

impl ServiceDefinition for Jump {
    fn name(&self) -> &'static str {
        "Jump"
    }
    fn description(&self) -> &'static str {
        "A self-hosted startpage and real-time status page"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Dashboard
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(8123), "/", "Jump", None)
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Jump>));
