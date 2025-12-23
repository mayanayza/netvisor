use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct ProxmoxBackupServer;

impl ServiceDefinition for ProxmoxBackupServer {
    fn name(&self) -> &'static str {
        "Proxmox Backup Server"
    }
    fn description(&self) -> &'static str {
        "Encrypted, incremental and deduplicated backups for Proxmox VMs, LXCs, and hosts"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Backup
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AnyOf(vec![
            Pattern::Endpoint(PortType::new_tcp(8007), "/", "proxmox-backup-gui", None),
            Pattern::Port(PortType::new_tcp(8007)),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/proxmox.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<ProxmoxBackupServer>
));
