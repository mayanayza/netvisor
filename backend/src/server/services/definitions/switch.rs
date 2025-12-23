use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Switch;

impl ServiceDefinition for Switch {
    fn name(&self) -> &'static str {
        "Switch"
    }
    fn description(&self) -> &'static str {
        "Generic network switch for local area networking"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::NetworkCore
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Not(Box::new(Pattern::IsGateway)),
            Pattern::AllOf(vec![
                Pattern::Port(PortType::Http),
                Pattern::Port(PortType::Telnet),
            ]),
        ])
    }

    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Switch>));
