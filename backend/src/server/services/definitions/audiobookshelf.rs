use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct AudioBookShelf;

impl ServiceDefinition for AudioBookShelf {
    fn name(&self) -> &'static str {
        "AudioBookShelf"
    }
    fn description(&self) -> &'static str {
        "Self-hosted audiobook and podcast server."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortType::new_tcp(13378))
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/audiobookshelf.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<AudioBookShelf>
));
