use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Prowlarr;

impl ServiceDefinition for Prowlarr {
    fn name(&self) -> &'static str {
        "Prowlarr"
    }
    fn description(&self) -> &'static str {
        "The Ultimate Indexer Manager."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(
            PortType::new_tcp(3232),
            "/Content/Images/Icons/manifest.json",
            "Prowlarr",
            None,
        )
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/prowlarr.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Prowlarr>));
