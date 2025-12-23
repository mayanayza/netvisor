use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct FileZillaServer;

impl ServiceDefinition for FileZillaServer {
    fn name(&self) -> &'static str {
        "FileZilla Server"
    }
    fn description(&self) -> &'static str {
        "FTP server"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Storage
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::Port(PortType::Ftp),
            Pattern::Port(PortType::new_tcp(14147)), // Admin interface
        ])
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/filezilla.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<FileZillaServer>
));
