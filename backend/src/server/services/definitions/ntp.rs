use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct NtpServer;

impl ServiceDefinition for NtpServer {
    fn name(&self) -> &'static str {
        "NTP Server"
    }
    fn description(&self) -> &'static str {
        "Network Time Protocol server"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::NetworkCore
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortBase::Ntp)
    }
    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<NtpServer>));
