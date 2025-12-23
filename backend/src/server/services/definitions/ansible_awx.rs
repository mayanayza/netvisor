use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct AnsibleAWX;

impl ServiceDefinition for AnsibleAWX {
    fn name(&self) -> &'static str {
        "AWX"
    }
    fn description(&self) -> &'static str {
        "Ansible automation platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Development
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http, "/api/v2/", "awx", Some(200..300))
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/ansible.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<AnsibleAWX>));
