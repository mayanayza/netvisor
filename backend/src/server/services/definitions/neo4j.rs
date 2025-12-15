use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Neo4j;

impl ServiceDefinition for Neo4j {
    fn name(&self) -> &'static str {
        "Neo4j"
    }
    fn description(&self) -> &'static str {
        "Graph database"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Database
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Port(PortBase::new_tcp(7473)),
            Pattern::Port(PortBase::new_tcp(7687)),
        ])
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/neo4j.png"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Neo4j>));
