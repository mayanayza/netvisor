use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Zigbee2MQTT;

impl ServiceDefinition for Zigbee2MQTT {
    fn name(&self) -> &'static str {
        "Zigbee2MQTT"
    }
    fn description(&self) -> &'static str {
        "Zigbee to MQTT bridge"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::HomeAutomation
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http8080, "/", "Zigbee2MQTT WindFront", None)
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/zigbee2mqtt.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Zigbee2MQTT>));
