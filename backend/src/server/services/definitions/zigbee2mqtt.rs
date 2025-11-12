use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Zigbee2Mqtt;

impl ServiceDefinition for Zigbee2Mqtt {
    fn name(&self) -> &'static str {
        "Zigbee2MQTT"
    }
    fn description(&self) -> &'static str {
        "A Zigbee to MQTT Bridge"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::HomeAutomation
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::HttpAlt, "/", "Zigbee2MQTT WindFront")
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/zigbee2mqtt.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Zigbee2Mqtt>));
