use std::sync::Arc;
use tokio::sync::RwLock;
use tokio::task::JoinHandle;
use tokio_util::sync::CancellationToken;

use crate::daemon::discovery::service::base::{
    DaemonDiscoveryService, DiscoveryRunner, RunsDiscovery,
};
use crate::daemon::discovery::service::docker::DockerScanDiscovery;
use crate::daemon::discovery::service::network::NetworkScanDiscovery;
use crate::daemon::discovery::service::self_report::SelfReportDiscovery;
use crate::server::daemons::r#impl::api::DaemonDiscoveryRequest;
use crate::server::discovery::r#impl::types::DiscoveryType;

pub struct DaemonDiscoverySessionManager {
    current_task: Arc<RwLock<Option<tokio::task::JoinHandle<()>>>>,
    cancellation_token: Arc<RwLock<CancellationToken>>,
    discovery_service: Arc<DaemonDiscoveryService>,
}

impl DaemonDiscoverySessionManager {
    pub fn new(discovery_service: Arc<DaemonDiscoveryService>) -> Self {
        Self {
            current_task: Arc::new(RwLock::new(None)),
            cancellation_token: Arc::new(RwLock::new(CancellationToken::new())),
            discovery_service,
        }
    }

    pub async fn initiate_session(self: &Arc<Self>, request: DaemonDiscoveryRequest) {
        tracing::info!(
            discovery_type = %request.discovery_type,
            session_id = %request.session_id,
            "Initiating discovery"
        );

        let cancel_token = self.start_new_session().await;

        let handle = match &request.discovery_type {
            DiscoveryType::SelfReport { host_id } => self.clone().spawn_discovery(
                DiscoveryRunner::new(
                    self.discovery_service.clone(),
                    self.clone(),
                    SelfReportDiscovery::new(*host_id),
                ),
                request.clone(),
                cancel_token,
            ),
            DiscoveryType::Docker {
                host_id,
                host_naming_fallback,
            } => self.clone().spawn_discovery(
                DiscoveryRunner::new(
                    self.discovery_service.clone(),
                    self.clone(),
                    DockerScanDiscovery::new(*host_id, *host_naming_fallback),
                ),
                request.clone(),
                cancel_token,
            ),
            DiscoveryType::Network {
                subnet_ids,
                host_naming_fallback,
            } => self.clone().spawn_discovery(
                DiscoveryRunner::new(
                    self.discovery_service.clone(),
                    self.clone(),
                    NetworkScanDiscovery::new(subnet_ids.clone(), *host_naming_fallback),
                ),
                request.clone(),
                cancel_token,
            ),
        };

        self.set_current_task(handle).await;
    }

    fn spawn_discovery<T>(
        self: Arc<Self>,
        discovery: DiscoveryRunner<T>,
        request: DaemonDiscoveryRequest,
        cancel_token: CancellationToken,
    ) -> tokio::task::JoinHandle<()>
    where
        DiscoveryRunner<T>: RunsDiscovery + 'static,
        T: 'static + Send + Sync,
    {
        tokio::spawn(async move {
            match discovery.discover(request, cancel_token.clone()).await {
                Ok(()) => {
                    tracing::info!("Discovery completed successfully");
                }
                Err(e) => {
                    tracing::error!("Discovery failed: {}", e);
                }
            }
            // Only clear if NOT cancelled - the cancel handler will clear it
            if !cancel_token.is_cancelled() {
                self.clear_completed_task().await;
            }
        })
    }

    /// Check if discovery is currently running
    pub async fn is_discovery_running(&self) -> bool {
        tracing::debug!("Checking discovery running on manager instance: {:p}", self);
        let task_guard = self.current_task.read().await;
        let has_task = task_guard.is_some();
        let is_finished = if let Some(handle) = task_guard.as_ref() {
            handle.is_finished()
        } else {
            true
        };
        tracing::debug!("Has task: {}, Is finished: {}", has_task, is_finished);

        if let Some(handle) = task_guard.as_ref() {
            !handle.is_finished()
        } else {
            false
        }
    }

    /// Set the current discovery task for cancellation
    pub async fn start_new_session(&self) -> CancellationToken {
        *self.cancellation_token.write().await = CancellationToken::new();
        *self.current_task.write().await = None;

        self.cancellation_token.read().await.clone()
    }

    pub async fn set_current_task(&self, handle: JoinHandle<()>) {
        *self.current_task.write().await = Some(handle);
    }

    /// Cancel current discovery task
    pub async fn cancel_current_session(&self) -> bool {
        if !self.is_discovery_running().await {
            return false;
        }

        tracing::info!("Cancelling discovery session...");

        // Signal cooperative cancellation
        self.cancellation_token.write().await.cancel();

        // Don't wait - just return success
        // The spawned task will handle cleanup
        tracing::info!("Cancellation signal sent");
        true
    }

    pub async fn token(&self) -> CancellationToken {
        self.cancellation_token.read().await.clone()
    }

    /// Clear completed task
    pub async fn clear_completed_task(&self) {
        let mut task_guard = self.current_task.write().await;
        if let Some(handle) = task_guard.as_ref()
            && handle.is_finished()
        {
            *self.cancellation_token.write().await = CancellationToken::new();
            *task_guard = None;
        }
    }
}
