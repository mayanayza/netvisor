use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Sonarr;

impl ServiceDefinition for Sonarr {
    fn name(&self) -> &'static str {
        "Sonarr"
    }
    fn description(&self) -> &'static str {
        "A TV collection manager for Usenet and BitTorrent users."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(
            PortType::new_tcp(8989),
            "/Content/manifest.json",
            "Sonarr",
            None,
        )
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/sonarr.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Sonarr>));
