use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Workstation;

impl ServiceDefinition for Workstation {
    fn name(&self) -> &'static str {
        "Workstation"
    }
    fn description(&self) -> &'static str {
        "Desktop computer for productivity work"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Workstation
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Port(PortBase::Rdp),
            Pattern::Port(PortBase::Samba),
        ])
    }

    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Workstation>));
