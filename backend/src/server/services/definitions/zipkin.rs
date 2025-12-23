use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Zipkin;

impl ServiceDefinition for Zipkin {
    fn name(&self) -> &'static str {
        "Zipkin"
    }
    fn description(&self) -> &'static str {
        "Distributed tracing system"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(9411), "/api/v2/services", "", None)
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Zipkin>));
