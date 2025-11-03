use std::sync::Arc;
use tokio::sync::RwLock;
use tokio::task::JoinHandle;
use tokio_util::sync::CancellationToken;

pub struct DaemonDiscoverySessionManager {
    current_task: Arc<RwLock<Option<tokio::task::JoinHandle<()>>>>,
    cancellation_token: Arc<RwLock<CancellationToken>>,
}

impl DaemonDiscoverySessionManager {
    pub fn new() -> Self {
        Self {
            current_task: Arc::new(RwLock::new(None)),
            cancellation_token: Arc::new(RwLock::new(CancellationToken::new())),
        }
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

impl Default for DaemonDiscoverySessionManager {
    fn default() -> Self {
        Self::new()
    }
}
