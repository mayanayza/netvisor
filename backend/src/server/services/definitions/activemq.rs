use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct ActiveMQ;

impl ServiceDefinition for ActiveMQ {
    fn name(&self) -> &'static str {
        "ActiveMQ"
    }
    fn description(&self) -> &'static str {
        "Message broker"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::MessageQueue
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(8161), "/admin", "activemq", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://www.vectorlogo.zone/logos/apache_activemq/apache_activemq-icon.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<ActiveMQ>));
