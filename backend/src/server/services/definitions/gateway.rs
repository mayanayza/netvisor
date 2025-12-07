use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::{ServiceDefinition, ServiceDefinitionExt};
use crate::server::services::r#impl::patterns::{MatchConfidence, Pattern};

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Gateway;

impl ServiceDefinition for Gateway {
    fn name(&self) -> &'static str {
        "Gateway"
    }
    fn description(&self) -> &'static str {
        "A generic gateway"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::NetworkCore
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::IsGateway,
            Pattern::Custom(
                |params| {
                    !params
                        .service_params
                        .matched_services
                        .iter()
                        .any(|s| !s.base.service_definition.is_gateway())
                },
                |_| Vec::new(),
                "No other gateway services matched",
                "A gateway service has already been matched",
                MatchConfidence::Low,
            ),
        ])
    }

    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Gateway>));
