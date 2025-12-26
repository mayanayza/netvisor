use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Promtail;

impl ServiceDefinition for Promtail {
    fn name(&self) -> &'static str {
        "Promtail"
    }
    fn description(&self) -> &'static str {
        "Agent which ships logs to Grafana Loki"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Endpoint(
                PortBase::new_tcp(9080),
                "/metrics",
                "promtail_build_info",
                None,
            ),
            Pattern::Endpoint(PortBase::new_tcp(9080), "/targets", "Promtail", None),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/loki.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Promtail>));
