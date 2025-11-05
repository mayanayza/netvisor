use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::{Pattern, Vendor};

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct EeroGateway;

impl ServiceDefinition for EeroGateway {
    fn name(&self) -> &'static str {
        "Eero Gateway"
    }
    fn description(&self) -> &'static str {
        "Eero device providing routing and gateway services"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::NetworkAccess
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![Pattern::MacVendor(Vendor::EERO), Pattern::IsGateway])
    }

    fn logo_url(&self) -> &'static str {
        "https://www.vectorlogo.zone/logos/eero/eero-icon.svg"
    }

    fn logo_needs_white_background(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<EeroGateway>));
