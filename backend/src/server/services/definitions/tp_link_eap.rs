use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::{Pattern, Vendor};

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct TpLinkEap;

impl ServiceDefinition for TpLinkEap {
    fn name(&self) -> &'static str {
        "TP-Link EAP"
    }
    fn description(&self) -> &'static str {
        "TP-Link EAP wireless access point"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::NetworkAccess
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::MacVendor(Vendor::TPLINK),
            Pattern::Endpoint(PortType::Http, "/", "tp-link", None),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/tp-link.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<TpLinkEap>));
