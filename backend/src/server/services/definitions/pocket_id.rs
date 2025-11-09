use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct PocketID;

impl ServiceDefinition for PocketID {
    fn name(&self) -> &'static str {
        "Pocket ID"
    }
    fn description(&self) -> &'static str {
        "A Simple OIDC provider that uses passkeys for authentication"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Web
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::new_tcp(1411), "/app.webmanifest", "Pocket ID")
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pocket-id-light.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<PocketID>));
