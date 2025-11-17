use crate::server::daemons::r#impl::base::DaemonMode;
use crate::server::discovery::r#impl::types::RunType;
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::storage::generic::GenericPostgresStorage;
use crate::server::shared::storage::traits::{StorableEntity, Storage};
use anyhow::anyhow;
use anyhow::{Error, Result};
use async_trait::async_trait;
use chrono::Utc;
use std::{collections::HashMap, sync::Arc};
use tokio::sync::{RwLock, broadcast};
use tokio_cron_scheduler::{Job, JobScheduler};
use uuid::Uuid;

use crate::server::discovery::r#impl::base::Discovery;
use crate::{
    daemon::discovery::types::base::DiscoveryPhase,
    server::daemons::{
        r#impl::api::{DaemonDiscoveryRequest, DiscoveryUpdatePayload},
        service::DaemonService,
    },
};

/// Server-side session management for discovery
pub struct DiscoveryService {
    discovery_storage: Arc<GenericPostgresStorage<Discovery>>,
    daemon_service: Arc<DaemonService>,
    sessions: RwLock<HashMap<Uuid, DiscoveryUpdatePayload>>, // session_id -> session state mapping
    daemon_sessions: RwLock<HashMap<Uuid, Vec<Uuid>>>,       // daemon_id -> session_id mapping
    daemon_pull_cancellations: RwLock<HashMap<Uuid, bool>>, // daemon_id -> boolean mapping for pull mode cancellations of current session on daemon
    update_tx: broadcast::Sender<DiscoveryUpdatePayload>,
    scheduler: Option<Arc<RwLock<JobScheduler>>>,
}

#[async_trait]
impl CrudService<Discovery> for DiscoveryService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Discovery>> {
        &self.discovery_storage
    }
}

impl DiscoveryService {
    pub async fn new(
        discovery_storage: Arc<GenericPostgresStorage<Discovery>>,
        daemon_service: Arc<DaemonService>,
    ) -> Result<Arc<Self>> {
        let (tx, _rx) = broadcast::channel(100); // Buffer 100 messages
        let scheduler = JobScheduler::new().await?;

        Ok(Arc::new(Self {
            discovery_storage,
            daemon_service,
            sessions: RwLock::new(HashMap::new()),
            daemon_sessions: RwLock::new(HashMap::new()),
            daemon_pull_cancellations: RwLock::new(HashMap::new()),
            update_tx: tx,
            scheduler: Some(Arc::new(RwLock::new(scheduler))),
        }))
    }

    /// Create a new scheduled discovery
    pub async fn create_discovery(self: &Arc<Self>, discovery: Discovery) -> Result<Discovery> {
        let mut created_discovery = if discovery.id == Uuid::nil() {
            self.discovery_storage
                .create(&Discovery::new(discovery.base))
                .await?
        } else {
            self.discovery_storage.create(&discovery).await?
        };

        // If it's a scheduled discovery, add it to the scheduler
        if matches!(created_discovery.base.run_type, RunType::Scheduled { .. })
            && let Err(e) = Self::schedule_discovery(self, &created_discovery).await
        {
            // Disable and save to DB
            created_discovery.disable();
            let disabled_discovery = self
                .discovery_storage
                .update(&mut created_discovery)
                .await?;

            tracing::error!(
                "Failed to schedule discovery {}. Discovery created but disabled. Error: {}",
                disabled_discovery.id,
                e
            );

            return Ok(disabled_discovery);
        }

        tracing::info!(
            "Created discovery {}: {}",
            created_discovery.base.name,
            created_discovery.id
        );
        Ok(created_discovery)
    }

    /// Update discovery
    pub async fn update_discovery(
        self: &Arc<Self>,
        mut discovery: Discovery,
    ) -> Result<Discovery, Error> {
        discovery.updated_at = Utc::now();

        // If it's a scheduled discovery, need to reschedule
        if matches!(discovery.base.run_type, RunType::Scheduled { .. }) {
            // Remove old schedule first
            if let Some(scheduler) = &self.scheduler {
                let _ = scheduler.write().await.remove(&discovery.id).await;
            }

            // Update in DB first
            let mut updated = self.discovery_storage.update(&mut discovery).await?;

            // Try to reschedule with new cron expression
            if let Err(e) = Self::schedule_discovery(self, &updated).await {
                // Disable and save again
                updated.disable();
                let disabled_discovery = self.discovery_storage.update(&mut updated).await?;

                tracing::error!(
                    "Failed to reschedule discovery {}. Discovery updated but disabled. Error: {}",
                    disabled_discovery.id,
                    e
                );

                return Ok(disabled_discovery);
            }

            tracing::info!(
                "Updated and rescheduled discovery {}: {}",
                updated.base.name,
                updated.id
            );
            Ok(updated)
        } else {
            // For non-scheduled, just update
            let updated = self.discovery_storage.update(&mut discovery).await?;
            tracing::info!("Updated discovery {}: {}", updated.base.name, updated.id);
            Ok(updated)
        }
    }

    /// Delete group
    pub async fn delete_discovery(self: &Arc<Self>, id: &Uuid) -> Result<(), Error> {
        let discovery = self
            .get_by_id(id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Discovery not found"))?;

        // If it's scheduled, remove from scheduler first
        if matches!(discovery.base.run_type, RunType::Scheduled { .. })
            && let Some(scheduler) = &self.scheduler
        {
            let _ = scheduler.write().await.remove(id).await;
            tracing::debug!("Removed scheduled job for discovery {}", id);
        }

        self.discovery_storage.delete(id).await?;
        tracing::info!(
            "Deleted discovery {}: {}",
            discovery.base.name,
            discovery.id
        );
        Ok(())
    }

    /// Initialize scheduler with all scheduled discoveries
    pub async fn start_scheduler(self: &Arc<Self>) -> Result<()> {
        let scheduler = self
            .scheduler
            .as_ref()
            .ok_or_else(|| anyhow::anyhow!("Scheduler not initialized"))?;

        let filter = EntityFilter::unfiltered().scheduled_discovery();

        let discoveries = self.discovery_storage.get_all(filter).await?;
        let count = discoveries.len();

        let mut failed_count = 0;
        for mut discovery in discoveries {
            if let Err(e) = Self::schedule_discovery(self, &discovery).await {
                tracing::error!(
                    "Failed to schedule discovery {}: {}. Disabling.",
                    discovery.id,
                    e
                );

                // Disable and save
                discovery.disable();
                let _ = self.discovery_storage.update(&mut discovery).await;
                failed_count += 1;
            }
        }

        scheduler.write().await.start().await?;

        if failed_count == 0 {
            tracing::info!("Discovery scheduler started with {} jobs", count);
        } else {
            tracing::warn!(
                "Discovery scheduler started with {}/{} jobs. {} failed and were disabled.",
                count - failed_count,
                count,
                failed_count
            );
        }

        Ok(())
    }

    /// Schedule a single discovery
    async fn schedule_discovery(
        service: &Arc<DiscoveryService>,
        discovery: &Discovery,
    ) -> Result<Uuid> {
        let _ = service
            .scheduler
            .as_ref()
            .ok_or_else(|| anyhow::anyhow!("Scheduler not initialized"))?;

        let RunType::Scheduled {
            cron_schedule,
            enabled,
            ..
        } = &discovery.base.run_type
        else {
            return Err(anyhow::anyhow!("Discovery is not scheduled"));
        };

        if !enabled {
            return Err(anyhow::anyhow!("Discovery is not enabled"));
        }

        let scheduler = service
            .scheduler
            .as_ref()
            .ok_or_else(|| anyhow::anyhow!("Scheduler not initialized"))?;

        let discovery = discovery.clone();
        let discovery_id = discovery.id;
        let storage = service.discovery_storage.clone();

        // Clone self to use start_session
        let service_clone = Arc::clone(service);

        let job = Job::new_async(cron_schedule.as_str(), move |_uuid, _lock| {
            let mut discovery = discovery.clone();
            let storage = storage.clone();
            let service = service_clone.clone();

            Box::pin(async move {
                tracing::info!("Running scheduled discovery {}", &discovery.id);

                match service.start_session(discovery.clone()).await {
                    Ok(_) => {
                        // Update last_run
                        if let RunType::Scheduled {
                            last_run: mut _last_run,
                            ..
                        } = discovery.base.run_type
                        {
                            _last_run = Some(Utc::now());
                            if let Err(e) = storage.update(&mut discovery).await {
                                tracing::error!("Failed to update schedule times: {}", e);
                            }
                        };
                    }
                    Err(e) => {
                        tracing::error!("Scheduled discovery {} failed: {}", discovery_id, e);
                    }
                }
            })
        })?;

        let job_id = scheduler.write().await.add(job).await?;

        tracing::info!(
            "Scheduled discovery {} with cron: {}",
            discovery_id,
            cron_schedule
        );
        Ok(job_id)
    }

    /// Expose stream to handler
    pub fn subscribe(&self) -> broadcast::Receiver<DiscoveryUpdatePayload> {
        self.update_tx.subscribe()
    }

    /// Get session state
    pub async fn get_session(&self, session_id: &Uuid) -> Option<DiscoveryUpdatePayload> {
        self.sessions.read().await.get(session_id).cloned()
    }

    /// Get session state
    pub async fn get_all_sessions(&self, network_ids: &[Uuid]) -> Vec<DiscoveryUpdatePayload> {
        let all_sessions = self.sessions.read().await;
        all_sessions
            .values()
            .filter(|v| network_ids.contains(&v.network_id))
            .cloned()
            .collect()
    }

    pub async fn get_sessions_for_daemon(&self, daemon_id: &Uuid) -> Vec<DiscoveryUpdatePayload> {
        let daemon_session_ids = self.daemon_sessions.read().await;
        let session_ids = daemon_session_ids
            .get(daemon_id)
            .cloned()
            .unwrap_or_default();

        let all_sessions = self.sessions.read().await;

        all_sessions
            .iter()
            .filter(|(session_id, _)| session_ids.contains(session_id))
            .map(|(_, session)| session.clone())
            .collect()
    }

    pub async fn pull_cancellation_for_daemon(&self, daemon_id: &Uuid) -> bool {
        let mut daemon_cancellation_ids = self.daemon_pull_cancellations.write().await;
        daemon_cancellation_ids.remove(daemon_id).unwrap_or(false)
    }

    /// Create a new discovery session
    pub async fn start_session(
        &self,
        discovery: Discovery,
    ) -> Result<DiscoveryUpdatePayload, anyhow::Error> {
        let session_id = Uuid::new_v4();

        let session_payload = DiscoveryUpdatePayload::new(
            session_id,
            discovery.base.daemon_id,
            discovery.base.network_id,
            discovery.base.discovery_type.clone(),
        );

        // Add to session map
        self.sessions
            .write()
            .await
            .insert(session_id, session_payload.clone());

        // Check if daemon has any sessions running
        let daemon_is_running_discovery = if let Some(daemon_sessions) = self
            .daemon_sessions
            .read()
            .await
            .get(&discovery.base.daemon_id)
        {
            !daemon_sessions.is_empty()
        } else {
            false
        };

        // Add session to queue
        self.daemon_sessions
            .write()
            .await
            .entry(discovery.base.daemon_id)
            .or_default()
            .push(session_id);

        let daemon_is_push = self
            .daemon_service
            .get_by_id(&discovery.base.daemon_id)
            .await?
            .map(|d| d.base.mode == DaemonMode::Push)
            .unwrap_or(false);

        // Initiate session on daemon if none are running and daemon is push
        if !daemon_is_running_discovery && daemon_is_push {
            self.daemon_service
                .send_discovery_request(
                    &discovery.base.daemon_id,
                    DaemonDiscoveryRequest {
                        discovery_type: discovery.base.discovery_type,
                        session_id,
                    },
                )
                .await?;
        }

        let _ = self.update_tx.send(session_payload.clone());

        tracing::info!(
            "Created discovery session {} for daemon {}",
            session_id,
            discovery.base.daemon_id
        );
        Ok(session_payload)
    }

    /// Update progress for a session
    pub async fn update_session(&self, update: DiscoveryUpdatePayload) -> Result<(), Error> {
        tracing::debug!("Updated session {:?}", update);

        let mut sessions = self.sessions.write().await;

        let session = sessions
            .get_mut(&update.session_id)
            .ok_or_else(|| anyhow::anyhow!("Session not found"))?;

        let daemon_id = session.daemon_id;
        tracing::debug!(
            "Updated session {}: {} ({}/{})",
            update.session_id,
            update.phase,
            update.processed,
            update.total_to_process
        );

        let _ = self.update_tx.send(update.clone());

        *session = update.clone();

        let is_terminal = matches!(
            session.phase,
            DiscoveryPhase::Cancelled | DiscoveryPhase::Complete | DiscoveryPhase::Failed
        );

        if is_terminal {
            // Create historical discovery record
            let historical_discovery = Discovery {
                id: Uuid::new_v4(),
                created_at: session.started_at.unwrap_or(Utc::now()),
                updated_at: Utc::now(),
                base: crate::server::discovery::r#impl::base::DiscoveryBase {
                    daemon_id: session.daemon_id,
                    network_id: session.network_id,
                    name: "Discovery Run".to_string(),
                    discovery_type: session.discovery_type.clone(),
                    run_type: RunType::Historical {
                        results: session.clone(),
                    },
                },
            };

            // User cancelled session, but it finished before we could send cancellation so remove key so it doesn't cancel upcoming sessions
            self.pull_cancellation_for_daemon(&session.daemon_id).await;

            // Save to database
            if let Err(e) = self.discovery_storage.create(&historical_discovery).await {
                tracing::error!(
                    "Failed to create historical discovery record for session {}: {}",
                    session.session_id,
                    e
                );
            } else {
                tracing::debug!(
                    "Created historical discovery record {} for session {}",
                    historical_discovery.id,
                    session.session_id
                );
            }

            // Get next session info BEFORE trying to send request
            let next_session_info = if let Some(daemon_sessions) = self
                .daemon_sessions
                .write()
                .await
                .get_mut(&session.daemon_id)
            {
                daemon_sessions.retain(|s| *s != session.session_id);

                // Get info about next session if it exists
                daemon_sessions
                    .first()
                    .and_then(|next_session_id| sessions.get_mut(next_session_id))
                    .map(|next_session| {
                        next_session.phase = DiscoveryPhase::Pending;
                        (next_session.discovery_type.clone(), next_session.session_id)
                    })
            } else {
                None
            };

            // Remove the completed session
            sessions.remove(&update.session_id);

            // Drop the sessions lock before sending the request
            drop(sessions);

            // If any in queue and daemon is running push mode, initiate next session
            // If daemon is pull mode, it will request next session on its next pull
            let daemon_is_push = self
                .daemon_service
                .get_by_id(&daemon_id)
                .await?
                .map(|d| d.base.mode == DaemonMode::Push)
                .unwrap_or(false);

            if let Some((discovery_type, session_id)) = next_session_info
                && daemon_is_push
            {
                tracing::debug!("Starting next session");

                self.daemon_service
                    .send_discovery_request(
                        &daemon_id,
                        DaemonDiscoveryRequest {
                            discovery_type,
                            session_id,
                        },
                    )
                    .await?;
            }
        }

        Ok(())
    }

    pub async fn cancel_session(&self, session_id: Uuid) -> Result<(), Error> {
        // Get the session
        let session = match self.get_session(&session_id).await {
            Some(session) => session,
            None => {
                return Err(anyhow!("Session '{}' not found", session_id));
            }
        };

        let network_id = session.network_id;
        let daemon_id = session.daemon_id;
        let phase = session.phase;

        // Handle based on current phase
        match phase {
            // Pending sessions: just remove from queue
            DiscoveryPhase::Pending => {
                let mut sessions = self.sessions.write().await;
                let mut daemon_sessions = self.daemon_sessions.write().await;

                // Remove from sessions map
                sessions.remove(&session_id);

                // Remove from daemon queue
                if let Some(queue) = daemon_sessions.get_mut(&daemon_id) {
                    queue.retain(|id| *id != session_id);
                }

                drop(sessions);
                drop(daemon_sessions);

                // Broadcast cancellation update so frontend knows
                let cancelled_update = DiscoveryUpdatePayload {
                    session_id,
                    network_id,
                    daemon_id,
                    phase: DiscoveryPhase::Cancelled,
                    processed: 0,
                    total_to_process: session.total_to_process,
                    error: None,
                    started_at: session.started_at,
                    finished_at: Some(Utc::now()),
                    discovery_type: session.discovery_type,
                };
                let _ = self.update_tx.send(cancelled_update);

                tracing::info!("Cancelled pending session {} from queue", session_id);
                Ok(())
            }

            // Starting phase: wait briefly then retry
            DiscoveryPhase::Starting => Err(anyhow!(
                "Session is starting on daemon. Please try again in a moment."
            )),

            // Active phases: send cancellation to daemon
            DiscoveryPhase::Started | DiscoveryPhase::Scanning => {
                if let Some(daemon) = self.daemon_service.get_by_id(&daemon_id).await? {
                    match daemon.base.mode {
                        DaemonMode::Push => {
                            self.daemon_service
                                .send_discovery_cancellation(&daemon, session_id)
                                .await
                                .map_err(|e| {
                                    anyhow!(
                                        "Failed to send discovery cancellation to daemon {} for session {}: {}",
                                        daemon_id,
                                        session_id,
                                        e
                                    )
                                })?;

                            tracing::info!(
                                "Cancellation request sent to daemon {} for active session {}",
                                daemon_id,
                                session_id
                            );
                            Ok(())
                        }
                        DaemonMode::Pull => {
                            // Add to pull cancellations
                            self.daemon_pull_cancellations
                                .write()
                                .await
                                .entry(daemon_id)
                                .insert_entry(true);

                            tracing::info!(
                                "Marked session {} for cancellation on next pull by daemon {}",
                                session_id,
                                daemon_id
                            );
                            Ok(())
                        }
                    }
                } else {
                    Err(anyhow!(
                        "Daemon {} not found when trying to cancel discovery session {}",
                        daemon_id,
                        session_id
                    ))
                }
            }

            // Terminal phases: already done
            DiscoveryPhase::Complete | DiscoveryPhase::Failed | DiscoveryPhase::Cancelled => {
                tracing::info!(
                    "Session {} is already in terminal state: {}, nothing to cancel",
                    session_id,
                    phase
                );
                Ok(())
            }
        }
    }

    /// Cleanup old completed sessions (call periodically)
    pub async fn cleanup_old_sessions(&self, max_age_hours: i64) {
        let cutoff = Utc::now() - chrono::Duration::hours(max_age_hours);
        let mut sessions = self.sessions.write().await;
        let mut daemon_sessions = self.daemon_sessions.write().await;
        let mut daemon_pull_cancellations = self.daemon_pull_cancellations.write().await;

        let mut to_remove = Vec::new();
        for (session_id, session) in sessions.iter() {
            if let Some(finished_at) = session.finished_at
                && finished_at < cutoff
            {
                to_remove.push(*session_id);
            }
        }

        for session_id in to_remove {
            if let Some(session) = sessions.remove(&session_id) {
                daemon_pull_cancellations.remove(&session.daemon_id);

                if let Some(daemon_sessions) = daemon_sessions.get_mut(&session.daemon_id) {
                    daemon_sessions.retain(|s| *s != session.session_id);
                }

                tracing::debug!("Cleaned up old discovery session {}", session_id);
            }
        }
    }
}
