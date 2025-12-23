use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Wizarr;

impl ServiceDefinition for Wizarr {
    fn name(&self) -> &'static str {
        "Wizarr"
    }
    fn description(&self) -> &'static str {
        "User invitation and management system for Jellyfin, Plex, Emby etc"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(
            PortType::new_tcp(5690),
            "/static/manifest.json",
            "Wizarr",
            None,
        )
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/wizarr.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Wizarr>));
