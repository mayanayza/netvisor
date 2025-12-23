use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Plex;

impl ServiceDefinition for Plex {
    fn name(&self) -> &'static str {
        "Plex Media Server"
    }
    fn description(&self) -> &'static str {
        "Media server for streaming personal content"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Endpoint(PortType::new_tcp(32400), "/web/index.html", "Plex", None),
            Pattern::Header(
                Some(PortType::new_tcp(32400)),
                "X-Plex-Protocol",
                "1.0",
                Some(401..401),
            ),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/plex.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Plex>));
