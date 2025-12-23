use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Asterisk;

impl ServiceDefinition for Asterisk {
    fn name(&self) -> &'static str {
        "Asterisk"
    }
    fn description(&self) -> &'static str {
        "PBX and VoIP server"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Telephony
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(8088), "/httpstatus", "asterisk", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/asterisk.png"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Asterisk>));
