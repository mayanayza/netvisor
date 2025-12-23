use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Duplicati;

impl ServiceDefinition for Duplicati {
    fn name(&self) -> &'static str {
        "Duplicati"
    }
    fn description(&self) -> &'static str {
        "Cross-platform backup client with encryption"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Backup
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(
            PortType::new_tcp(8200),
            "/ngax/index.html",
            "Duplicati",
            None,
        )
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/duplicati.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Duplicati>));
