use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::types::categories::ServiceCategory;
use crate::server::services::types::definitions::ServiceDefinition;
use crate::server::services::types::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Prometheus;

impl ServiceDefinition for Prometheus {
    fn name(&self) -> &'static str {
        "Prometheus"
    }
    fn description(&self) -> &'static str {
        "Time-series monitoring and alerting system"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Endpoint(PortBase::Http, "/metrics", "Prometheus"),
            Pattern::Endpoint(PortBase::Http, "/graph", "Prometheus"),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/prometheus.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Prometheus>));
