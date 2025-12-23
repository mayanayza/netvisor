use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::{Pattern, Vendor};

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct NestThermostat;

impl ServiceDefinition for NestThermostat {
    fn name(&self) -> &'static str {
        "Nest Thermostat"
    }

    fn description(&self) -> &'static str {
        "Google Nest smart thermostat"
    }

    fn category(&self) -> ServiceCategory {
        ServiceCategory::IoT
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::AnyOf(vec![
                Pattern::MacVendor(Vendor::NEST),
                Pattern::MacVendor(Vendor::GOOGLE),
            ]),
            Pattern::Port(PortType::new_tcp(9543)),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/google-home.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<NestThermostat>
));
