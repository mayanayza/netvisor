use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct QNAP;

impl ServiceDefinition for QNAP {
    fn name(&self) -> &'static str {
        "QNAP NAS"
    }
    fn description(&self) -> &'static str {
        "QNAP network attached storage system"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Storage
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Port(PortType::Ftp),
            Pattern::AnyOf(vec![
                Pattern::Endpoint(PortType::Http, "/", "QNAP", None),
                Pattern::Endpoint(PortType::Http8080, "/", "QNAP", None),
            ]),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/qnap.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<QNAP>));
