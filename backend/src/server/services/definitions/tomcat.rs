use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

// Tomcat
#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Tomcat;

impl ServiceDefinition for Tomcat {
    fn name(&self) -> &'static str {
        "Tomcat"
    }
    fn description(&self) -> &'static str {
        "Java servlet container"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Development
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http8080, "/", "apache tomcat", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/apache-tomcat.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Tomcat>));
