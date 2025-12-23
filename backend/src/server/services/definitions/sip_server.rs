use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct SIPServer;

impl ServiceDefinition for SIPServer {
    fn name(&self) -> &'static str {
        "SIP Server"
    }
    fn description(&self) -> &'static str {
        "Session initiation protocol"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Telephony
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Port(PortType::Sip),
            Pattern::Port(PortType::SipTls),
        ])
    }
    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<SIPServer>));
