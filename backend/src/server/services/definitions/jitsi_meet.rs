use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct JitsiMeet;

impl ServiceDefinition for JitsiMeet {
    fn name(&self) -> &'static str {
        "Jitsi Meet"
    }
    fn description(&self) -> &'static str {
        "Video conferencing"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Conferencing
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Https8443, "/", "jitsilogo.png", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jitsi-meet.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<JitsiMeet>));
