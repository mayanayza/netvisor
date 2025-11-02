use anyhow::{Error, anyhow};
use chrono::Utc;
use std::{collections::HashMap, sync::Arc};
use tokio::sync::{RwLock, broadcast};
use uuid::Uuid;

use crate::{
    daemon::discovery::types::base::DiscoveryPhase,
    server::{
        daemons::{
            service::DaemonService,
            types::api::{DaemonDiscoveryRequest, DiscoveryUpdatePayload},
        },
        discovery::types::base::DiscoveryType,
    },
};

/// Server-side session management for discovery
pub struct DiscoveryService {
    daemon_service: Arc<DaemonService>,
    sessions: RwLock<HashMap<Uuid, DiscoveryUpdatePayload>>, // session_id -> session state mapping
    daemon_sessions: RwLock<HashMap<Uuid, Vec<Uuid>>>,       // daemon_id -> session_id mapping
    update_tx: broadcast::Sender<DiscoveryUpdatePayload>,
}

impl DiscoveryService {
    pub fn new(daemon_service: Arc<DaemonService>) -> Self {
        let (tx, _rx) = broadcast::channel(100); // Buffer 100 messages
        Self {
            daemon_service,
            sessions: RwLock::new(HashMap::new()),
            daemon_sessions: RwLock::new(HashMap::new()),
            update_tx: tx,
        }
    }

    pub fn subscribe(&self) -> broadcast::Receiver<DiscoveryUpdatePayload> {
        self.update_tx.subscribe()
    }

    /// Get session state
    pub async fn get_session(&self, session_id: &Uuid) -> Option<DiscoveryUpdatePayload> {
        self.sessions.read().await.get(session_id).cloned()
    }

    /// Create a new discovery session
    pub async fn create_session(
        &self,
        daemon_id: Uuid,
        discovery_type: DiscoveryType,
    ) -> Result<DiscoveryUpdatePayload, anyhow::Error> {
        let session_id = Uuid::new_v4();

        let session_payload = DiscoveryUpdatePayload::new(session_id, daemon_id, discovery_type);

        // Add to session map
        self.sessions
            .write()
            .await
            .insert(session_id, session_payload.clone());

        // Check if daemon has any sessions running
        let daemon_is_running_discovery =
            if let Some(daemon_sessions) = self.daemon_sessions.read().await.get(&daemon_id) {
                !daemon_sessions.is_empty()
            } else {
                false
            };

        // Add session to queue
        self.daemon_sessions
            .write()
            .await
            .entry(daemon_id)
            .or_default()
            .push(session_id);

        // Initiate session on daemon if none are running
        if !daemon_is_running_discovery {
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

        let _ = self.update_tx.send(session_payload.clone());

        tracing::info!(
            "Created discovery session {} for daemon {}",
            session_id,
            daemon_id
        );
        Ok(session_payload)
    }

    /// Update progress for a session
    pub async fn update_session(&self, update: DiscoveryUpdatePayload) -> Result<Uuid, Error> {
        tracing::debug!("Updated session {:?}", update);

        let mut sessions = self.sessions.write().await;

        if let Some(session) = sessions.get_mut(&update.session_id) {
            let daemon_id = session.daemon_id;
            tracing::debug!(
                "Updated session {}: {} ({}/{})",
                update.session_id,
                update.phase,
                update.completed,
                update.total
            );

            let _ = self.update_tx.send(update.clone());

            *session = update;

            if matches!(
                session.phase,
                DiscoveryPhase::Cancelled | DiscoveryPhase::Complete | DiscoveryPhase::Failed
            ) {
                // Remove from daemon sessions mapping
                match &session.error {
                    Some(e) => tracing::error!(
                        "{} discovery session {} with error {}",
                        &session.phase,
                        &session.session_id,
                        e
                    ),
                    None => tracing::info!(
                        "{} discovery session {}",
                        &session.phase,
                        &session.session_id
                    ),
                }

                session.finished_at = Some(Utc::now());

                // Get next session info BEFORE trying to send request
                let next_session = if let Some(daemon_sessions) = self
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
                } else {
                    None
                };

                let next_session_info = if let Some(next_session) = next_session {
                    next_session.phase = DiscoveryPhase::Pending;
                    Some((next_session.discovery_type, next_session.session_id))
                } else {
                    None
                };

                // Drop the sessions lock before sending the request
                drop(sessions);

                // If any in queue, initiate next session
                if let Some((discovery_type, session_id)) = next_session_info {
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

                return Ok(daemon_id);
            }

            Ok(daemon_id)
        } else {
            Err(anyhow::anyhow!("Session not found"))
        }
    }

    pub async fn cancel_session(&self, session_id: Uuid) -> Result<(), Error> {
        // Get the session
        let session = match self.get_session(&session_id).await {
            Some(session) => session,
            None => {
                return Err(anyhow!("Session '{}' not found", session_id));
            }
        };

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
                    daemon_id,
                    phase: DiscoveryPhase::Cancelled,
                    completed: 0,
                    total: session.total,
                    discovered_count: 0,
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
                if let Some(daemon) = self.daemon_service.get_daemon(&daemon_id).await? {
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
                if let Some(daemon_sessions) = daemon_sessions.get_mut(&session.daemon_id) {
                    daemon_sessions.retain(|s| *s != session.session_id);
                }

                tracing::debug!("Cleaned up old discovery session {}", session_id);
            }
        }
    }
}
