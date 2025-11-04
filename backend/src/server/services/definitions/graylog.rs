use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

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
        Pattern::Endpoint(PortBase::new_tcp(9000), "/", "Graylog")
    }

    fn dashboard_icons_path(&self) -> &'static str {
        "Graylog"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Graylog>));
