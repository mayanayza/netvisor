use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct SABnzbd;

impl ServiceDefinition for SABnzdb {
    fn name(&self) -> &'static str {
        "SABnzdb"
    }
    fn description(&self) -> &'static str {
        "A NZB Files Downloader."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(
            PortBase::new_tcp(7777),
            "/Content/manifest.json",
            "SABnzdb",
            None,
        )
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/sabnzbd.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<SABnzbd>));
