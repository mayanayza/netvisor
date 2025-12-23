// backend/src/server/services/definitions/amazon_echo.rs
use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::{Pattern, Vendor};

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct AmazonEcho;

impl ServiceDefinition for AmazonEcho {
    fn name(&self) -> &'static str {
        "Amazon Echo"
    }

    fn description(&self) -> &'static str {
        "Amazon Echo smart speaker"
    }

    fn category(&self) -> ServiceCategory {
        ServiceCategory::IoT
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::MacVendor(Vendor::AMAZON),
            Pattern::Port(PortType::new_tcp(40317)),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/alexa.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<AmazonEcho>));
