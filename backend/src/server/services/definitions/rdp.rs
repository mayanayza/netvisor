use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct RemoteDesktop;

impl ServiceDefinition for RemoteDesktop {
    fn name(&self) -> &'static str {
        "Remote Desktop"
    }
    fn description(&self) -> &'static str {
        "Remote Desktop Protocol (RDP)"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::NetworkCore
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Port(PortType::Rdp)
    }
    fn is_generic(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<RemoteDesktop>
));
