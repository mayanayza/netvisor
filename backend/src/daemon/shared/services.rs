use crate::daemon::{
    discovery::{manager::DaemonDiscoverySessionManager, service::base::DaemonDiscoveryService},
    runtime::service::DaemonRuntimeService,
    shared::config::ConfigStore,
};
use anyhow::Result;
use std::sync::Arc;

pub struct DaemonServiceFactory {
    pub discovery_service: Arc<DaemonDiscoveryService>,
    pub discovery_manager: Arc<DaemonDiscoverySessionManager>,
    pub runtime_service: Arc<DaemonRuntimeService>,
}

impl DaemonServiceFactory {
    pub async fn new(config: Arc<ConfigStore>) -> Result<Self> {
        // Initialize services with proper dependencies

        let discovery_service = Arc::new(DaemonDiscoveryService::new(config.clone()));
        let discovery_manager = Arc::new(DaemonDiscoverySessionManager::new(
            discovery_service.clone(),
        ));
        let runtime_service = Arc::new(DaemonRuntimeService::new(
            config.clone(),
            discovery_manager.clone(),
        ));

        Ok(Self {
            discovery_service,
            discovery_manager,
            runtime_service,
        })
    }
}
