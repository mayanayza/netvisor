use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Denodo;

impl ServiceDefinition for Denodo {
    fn name(&self) -> &'static str {
        "Denodo"
    }
    fn description(&self) -> &'static str {
        "Data virtualization"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Database
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Port(PortBase::new_tcp(9990)),
            Pattern::Port(PortBase::new_tcp(9996)),
            Pattern::Port(PortBase::new_tcp(9090)),
            Pattern::Port(PortBase::new_tcp(9099)),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/denodo.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Denodo>));
