use std::net::IpAddr;

use crate::{
    daemon::discovery::types::base::{
        DiscoveryPhase, DiscoverySessionInfo, DiscoverySessionUpdate,
    },
    server::{daemons::types::base::Daemon, discovery::types::base::DiscoveryType},
};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DaemonResponse {
    pub daemon: Daemon,
}

/// Daemon registration request from daemon to server
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DaemonRegistrationRequest {
    pub daemon_id: Uuid,
    pub network_id: Uuid,
    pub daemon_ip: IpAddr,
    pub daemon_port: u16,
}

/// Daemon registration response from server to daemon
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DaemonRegistrationResponse {
    pub daemon: Daemon,
    pub api_key: String,
    pub host_id: Uuid,
}

/// Daemon discovery request from server to daemon
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DaemonDiscoveryRequest {
    pub session_id: Uuid,
    pub discovery_type: DiscoveryType,
}

/// Daemon discovery response (for immediate acknowledgment)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DaemonDiscoveryResponse {
    pub session_id: Uuid,
}

/// Cancellation request from server to daemon
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DaemonDiscoveryCancellationRequest {
    pub session_id: Uuid,
}

/// Cancellation response
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DaemonDiscoveryCancellationResponse {
    pub session_id: Uuid,
}

/// Progress update from daemon to server during discovery
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DiscoveryUpdatePayload {
    pub session_id: Uuid,
    pub daemon_id: Uuid,
    pub phase: DiscoveryPhase,
    pub completed: usize,
    pub total: usize,
    pub discovered_count: usize,
    pub error: Option<String>,
    pub started_at: Option<DateTime<Utc>>,
    pub finished_at: Option<DateTime<Utc>>,
}

impl DiscoveryUpdatePayload {
    pub fn new(session_id: Uuid, daemon_id: Uuid) -> Self {
        Self {
            session_id,
            daemon_id,
            phase: DiscoveryPhase::Initiated,
            completed: 0,
            total: 0,
            discovered_count: 0,
            error: None,
            started_at: None,
            finished_at: None,
        }
    }

    pub fn from_state_and_update(
        info: DiscoverySessionInfo,
        update: DiscoverySessionUpdate,
    ) -> Self {
        Self {
            session_id: info.session_id,
            daemon_id: info.daemon_id,
            phase: update.phase,
            completed: update.completed,
            total: info.total_to_scan,
            discovered_count: update.discovered_count,
            error: update.error,
            started_at: info.started_at,
            finished_at: update.finished_at,
        }
    }
}
