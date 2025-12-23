use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct GitLab;

impl ServiceDefinition for GitLab {
    fn name(&self) -> &'static str {
        "GitLab"
    }
    fn description(&self) -> &'static str {
        "DevOps platform"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Development
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Header(None, "content-security-policy", "gitlab", None),
            Pattern::Endpoint(PortType::Http, "/", "gitlab", None),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/gitlab.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<GitLab>));
