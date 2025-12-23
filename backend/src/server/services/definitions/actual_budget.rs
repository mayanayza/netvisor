use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct ActualBudget;

impl ServiceDefinition for ActualBudget {
    fn name(&self) -> &'static str {
        "Actual Budget"
    }
    fn description(&self) -> &'static str {
        "A local-first personal finance app"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Office
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(
            PortType::new_tcp(5006),
            "/manifest.webmanifest",
            "@actual-app/web",
            None,
        )
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/actual-budget.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<ActualBudget>
));
