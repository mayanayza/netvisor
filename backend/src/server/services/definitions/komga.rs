use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Komga;

impl ServiceDefinition for Komga {
    fn name(&self) -> &'static str {
        "Komga"
    }
    fn description(&self) -> &'static str {
        "a media server for your comics, mangas, BDs, magazines and eBooks."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(25600), "/", "Komga")
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Komga"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Komga>));
