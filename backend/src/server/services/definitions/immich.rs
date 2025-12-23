use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Immich;

impl ServiceDefinition for Immich {
    fn name(&self) -> &'static str {
        "Immich"
    }
    fn description(&self) -> &'static str {
        "Self-hosted photo and video management solution"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(2283), "/photos", "Immich", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/immich.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Immich>));
