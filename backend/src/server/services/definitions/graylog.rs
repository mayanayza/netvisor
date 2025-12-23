use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Graylog;

impl ServiceDefinition for Graylog {
    fn name(&self) -> &'static str {
        "Graylog"
    }
    fn description(&self) -> &'static str {
        "Security Information and Event Management (SIEM) solution and log analytics platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Header(None, "content-security-policy", "graylog", None),
            Pattern::Endpoint(PortType::Http9000, "/", "Graylog", None),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/graylog.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Graylog>));
