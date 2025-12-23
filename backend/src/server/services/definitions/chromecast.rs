use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::{Pattern, Vendor};

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct ChromecastDevice;

impl ServiceDefinition for ChromecastDevice {
    fn name(&self) -> &'static str {
        "Chromecast"
    }

    fn description(&self) -> &'static str {
        "Google Chromecast streaming device"
    }

    fn category(&self) -> ServiceCategory {
        ServiceCategory::IoT
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::MacVendor(Vendor::GOOGLE),
            Pattern::Port(PortType::new_tcp(8008)),
            Pattern::Port(PortType::new_tcp(8009)),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://simpleicons.org/icons/googlecast.svg"
    }
    fn logo_needs_white_background(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<ChromecastDevice>
));
