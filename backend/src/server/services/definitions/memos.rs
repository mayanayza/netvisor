use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Memos;

impl ServiceDefinition for Memos {
    fn name(&self) -> &'static str {
        "Memos"
    }
    fn description(&self) -> &'static str {
        "An open-source, self-hosted note-taking service."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Office
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(5230), "/explore", "Memos", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/memos.png"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Memos>));
