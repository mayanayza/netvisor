use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Amqp;

impl ServiceDefinition for Amqp {
    fn name(&self) -> &'static str {
        "AMQP"
    }
    fn description(&self) -> &'static str {
        "Advanced Message Queuing Protocol"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::MessageQueue
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Port(PortBase::AMQP),
            Pattern::Port(PortBase::AMQPTls),
        ])
    }
    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Amqp>));
