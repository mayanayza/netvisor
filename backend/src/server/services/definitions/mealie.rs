use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Mealie;

impl ServiceDefinition for Mealie {
    fn name(&self) -> &'static str {
        "Mealie"
    }
    fn description(&self) -> &'static str {
        "A self-hosted recipe manager and meal planner"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::HomeAutomation
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Endpoint(PortType::Http9000, "/", "Mealie", None),
            Pattern::Endpoint(PortType::Http9000, "/", "recipe", None),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mealie.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Mealie>));
