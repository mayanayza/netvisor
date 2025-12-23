use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Kafka;

impl ServiceDefinition for Kafka {
    fn name(&self) -> &'static str {
        "Kafka"
    }
    fn description(&self) -> &'static str {
        "Event streaming platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::MessageQueue
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortType::Kafka)
    }
    fn logo_url(&self) -> &'static str {
        "https://simpleicons.org/icons/apachekafka.svg"
    }
    fn is_generic(&self) -> bool {
        true
    }
    fn logo_needs_white_background(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Kafka>));
