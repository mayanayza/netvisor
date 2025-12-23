use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Jaeger;

impl ServiceDefinition for Jaeger {
    fn name(&self) -> &'static str {
        "Jaeger"
    }
    fn description(&self) -> &'static str {
        "Distributed tracing system"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(16686), "/", "jaeger", None)
    }
    fn is_generic(&self) -> bool {
        true
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jaeger.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Jaeger>));
