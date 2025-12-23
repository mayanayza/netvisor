use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct BookLore;

impl ServiceDefinition for BookLore {
    fn name(&self) -> &'static str {
        "BookLore"
    }
    fn description(&self) -> &'static str {
        "A self-hosted, multi-user digital library."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(6060), "/", "booklore-app", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/book-lore.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<BookLore>));
