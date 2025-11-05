use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::{Pattern, Vendor};

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct GoogleHome;

impl ServiceDefinition for GoogleHome {
    fn name(&self) -> &'static str {
        "Google Nest router"
    }

    fn description(&self) -> &'static str {
        "Google Nest Wifi router"
    }

    fn category(&self) -> ServiceCategory {
        ServiceCategory::NetworkAccess
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::AnyOf(vec![
                Pattern::MacVendor(Vendor::NEST),
                Pattern::MacVendor(Vendor::GOOGLE),
            ]),
            Pattern::IsGateway,
            Pattern::Endpoint(PortBase::Http, "/", "Nest Wifi"),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/google-home.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<GoogleHome>));
