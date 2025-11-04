use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Grocy;

impl ServiceDefinition for Grocy {
    fn name(&self) -> &'static str {
        "Grocy"
    }
    fn description(&self) -> &'static str {
        "web-based self-hosted groceries & household management solution"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::HomeAutomation
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Endpoint(PortBase::Http, "/", "Grocy"),
            Pattern::Endpoint(PortBase::Https, "/", "Grocy"),
        ])
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Grocy"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Grocy>));
