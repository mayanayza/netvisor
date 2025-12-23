use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct ZWaveJS;

impl ServiceDefinition for ZWaveJS {
    fn name(&self) -> &'static str {
        "Z-Wave JS"
    }
    fn description(&self) -> &'static str {
        "Z-Wave controller server"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::HomeAutomation
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::new_tcp(8091), "/health", "", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/z-wave-js-ui.svg"
    }
    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<ZWaveJS>));
