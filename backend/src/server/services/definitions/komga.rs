use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Komga;

impl ServiceDefinition for Komga {
    fn name(&self) -> &'static str {
        "Komga"
    }
    fn description(&self) -> &'static str {
        "A media server for your comics, mangas, BDs, magazines and eBooks."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(25600), "/", "Komga", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/komga.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Komga>));
