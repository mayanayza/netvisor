use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Restic;

impl ServiceDefinition for Restic {
    fn name(&self) -> &'static str {
        "Restic"
    }
    fn description(&self) -> &'static str {
        "Fast and secure backup program"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Backup
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Port(PortBase::new_tcp(8000)),
            Pattern::Endpoint(PortBase::Http, "/", "restic", None),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/restic.png"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Restic>));
