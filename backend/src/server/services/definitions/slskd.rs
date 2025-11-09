use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Slskd;

impl ServiceDefinition for Slskd {
    fn name(&self) -> &'static str {
        "Slskd"
    }
    fn description(&self) -> &'static str {
        "A modern client-server application for the Soulseek file-sharing network"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Endpoint(PortBase::new_tcp(5030), "/", "slskd"),
            Pattern::Endpoint(PortBase::new_tcp(5030), "/api/v0/session/enabled", "true")
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/slskd.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Slskd>));
