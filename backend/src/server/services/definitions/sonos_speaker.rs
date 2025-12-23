use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::{Pattern, Vendor};

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct SonosSpeaker;

impl ServiceDefinition for SonosSpeaker {
    fn name(&self) -> &'static str {
        "Sonos Speaker"
    }

    fn description(&self) -> &'static str {
        "Sonos wireless speaker system"
    }

    fn category(&self) -> ServiceCategory {
        ServiceCategory::IoT
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        // Sonos speakers have very distinctive port signature:
        // TCP 1400 (HTTP API), 1443 (HTTPS API), 4444 (control)
        Pattern::AllOf(vec![
            Pattern::MacVendor(Vendor::SONOS),
            Pattern::AnyOf(vec![
                Pattern::Port(PortType::Samba),
                Pattern::Port(PortType::new_tcp(3445)),
                Pattern::Port(PortType::new_tcp(1400)),
                Pattern::Port(PortType::new_tcp(1410)),
                Pattern::Port(PortType::new_tcp(1843)),
                Pattern::Port(PortType::new_tcp(3400)),
                Pattern::Port(PortType::new_tcp(3401)),
                Pattern::Port(PortType::new_tcp(3500)),
            ]),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://simpleicons.org/icons/sonos.svg"
    }

    fn logo_needs_white_background(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<SonosSpeaker>
));
