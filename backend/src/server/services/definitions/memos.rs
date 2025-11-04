use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Memos;

impl ServiceDefinition for Memos {
    fn name(&self) -> &'static str {
        "Memos"
    }
    fn description(&self) -> &'static str {
        "An open-source, self-hosted note-taking service."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(5230), "/explore", "Memos")
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Memos"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Memos>));
