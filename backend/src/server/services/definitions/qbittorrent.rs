use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct QBittorrent;

impl ServiceDefinition for QBittorrent {
    fn name(&self) -> &'static str {
        "qBittorrent"
    }
    fn description(&self) -> &'static str {
        "Cross-platform open-source BitTorrent client"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Endpoint(PortType::Http8080, "/", "qBittorrent logo", None),
            Pattern::Endpoint(PortType::new_tcp(8090), "/", "qBittorrent logo", None),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/qbittorrent.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<QBittorrent>));
