use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Ceph;

impl ServiceDefinition for Ceph {
    fn name(&self) -> &'static str {
        "Ceph"
    }
    fn description(&self) -> &'static str {
        "Distributed storage"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Storage
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http8080, "/", "ceph dashboard", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/ceph.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Ceph>));
