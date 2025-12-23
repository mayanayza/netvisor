use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::{Pattern, Vendor};

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct PhilipsHueBridge;

impl ServiceDefinition for PhilipsHueBridge {
    fn name(&self) -> &'static str {
        "Philips Hue Bridge"
    }
    fn description(&self) -> &'static str {
        "Philips Hue Bridge for lighting control"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::IoT
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::MacVendor(Vendor::PHILIPS),
            Pattern::Endpoint(PortType::Http, "/", "hue", None),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://simpleicons.org/icons/philipshue.svg"
    }

    fn logo_needs_white_background(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<PhilipsHueBridge>
));
