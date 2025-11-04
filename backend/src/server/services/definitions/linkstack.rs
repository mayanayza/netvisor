use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct LinkStack;

impl ServiceDefinition for LinkStack {
    fn name(&self) -> &'static str {
        "LinkStack"
    }
    fn description(&self) -> &'static str {
        "a highly customizable link sharing platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Dashboard
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::HttpAlt, "/", "LinkStack")
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Linkstack"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<LinkStack>));
