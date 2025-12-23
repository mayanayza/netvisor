use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Mailcow;

impl ServiceDefinition for Mailcow {
    fn name(&self) -> &'static str {
        "mailcow"
    }

    fn description(&self) -> &'static str {
        "Open-source mail server suite (Dockerized)"
    }

    fn category(&self) -> ServiceCategory {
        ServiceCategory::Email
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Https, "/api/v1/get/status", "mailcow", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mailcow.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Mailcow>));
