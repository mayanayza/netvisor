use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct FiosGateway;

impl ServiceDefinition for FiosGateway {
    fn name(&self) -> &'static str {
        "Fios Gateway"
    }
    fn description(&self) -> &'static str {
        "Fios device providing routing and gateway services"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::NetworkAccess
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Endpoint(PortBase::Http, "/#/login/", "fios"),
            Pattern::IsGateway,
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/fios.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<FiosGateway>));
