use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct FreePBX;

impl ServiceDefinition for FreePBX {
    fn name(&self) -> &'static str {
        "FreePBX"
    }
    fn description(&self) -> &'static str {
        "PBX web interface"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Telephony
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Endpoint(PortType::Http, "/", "freepbx", None),
            Pattern::Port(PortType::Sip),
        ])
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/freepbx.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<FreePBX>));
