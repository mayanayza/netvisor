use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct ArgoCD;

impl ServiceDefinition for ArgoCD {
    fn name(&self) -> &'static str {
        "ArgoCD"
    }
    fn description(&self) -> &'static str {
        "GitOps continuous delivery"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Development
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http8080, "/api/version", "argocd", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/argo-cd.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<ArgoCD>));
