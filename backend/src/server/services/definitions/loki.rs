use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Loki;

impl ServiceDefinition for Loki {
    fn name(&self) -> &'static str {
        "Loki"
    }
    fn description(&self) -> &'static str {
        "Log aggregation system inspired by Prometheus"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![Pattern::Endpoint(
            PortBase::new_tcp(3100),
            "/metrics",
            "loki_build_info",
            None,
        )])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/loki.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Loki>));
