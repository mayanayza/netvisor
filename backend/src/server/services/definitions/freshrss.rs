use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct FreshRSS;

impl ServiceDefinition for FreshRSS {
    fn name(&self) -> &'static str {
        "FreshRSS"
    }
    fn description(&self) -> &'static str {
        "A free, self-hostable news aggregator"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Publishing
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(
            PortType::Http,
            "/themes/manifest.json",
            "FreshRSS feed aggregator",
            None,
        )
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/freshrss.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<FreshRSS>));
