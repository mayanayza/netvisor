use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Autobrr;

impl ServiceDefinition for Autobrr {
    fn name(&self) -> &'static str {
        "Autobrr"
    }
    fn description(&self) -> &'static str {
        "The modern autodl-irssi replacement."
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Media
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortType::new_tcp(7474))
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/autobrr.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Autobrr>));
