use std::net::IpAddr;

use crate::{
    daemon::discovery::types::base::{
        DiscoveryPhase, DiscoverySessionInfo, DiscoverySessionUpdate,
    },
    server::{daemons::r#impl::base::Daemon, discovery::r#impl::types::DiscoveryType},
};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// Daemon registration request from daemon to server
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct DaemonCapabilities {
    #[serde(default)]
    pub has_docker_socket: bool,
    #[serde(default)]
    pub interfaced_subnet_ids: Vec<Uuid>,
}

/// Daemon registration request from daemon to server
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DaemonRegistrationRequest {
    pub daemon_id: Uuid,
    pub network_id: Uuid,
    pub daemon_ip: IpAddr,
    pub daemon_port: u16,
    pub api_key: String,
    pub capabilities: DaemonCapabilities,
}

/// Daemon registration response from server to daemon
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DaemonRegistrationResponse {
    pub daemon: Daemon,
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

/// Progress update from daemon to server during discovery
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DiscoveryUpdatePayload {
    pub session_id: Uuid,
    pub daemon_id: Uuid,
    pub network_id: Uuid,
    pub phase: DiscoveryPhase,
    pub discovery_type: DiscoveryType,
    pub processed: usize,
    pub total_to_process: usize,
    pub error: Option<String>,
    pub started_at: Option<DateTime<Utc>>,
    pub finished_at: Option<DateTime<Utc>>,
}

impl DiscoveryUpdatePayload {
    pub fn new(
        session_id: Uuid,
        daemon_id: Uuid,
        network_id: Uuid,
        discovery_type: DiscoveryType,
    ) -> Self {
        Self {
            session_id,
            daemon_id,
            network_id,
            phase: DiscoveryPhase::Pending,
            processed: 0,
            discovery_type,
            total_to_process: 0,
            error: None,
            started_at: None,
            finished_at: None,
        }
    }

    pub fn from_state_and_update(
        discovery_type: DiscoveryType,
        info: DiscoverySessionInfo,
        update: DiscoverySessionUpdate,
    ) -> Self {
        Self {
            session_id: info.session_id,
            discovery_type,
            network_id: info.network_id,
            daemon_id: info.daemon_id,
            phase: update.phase,
            processed: update.processed,
            total_to_process: info.total_to_process,
            error: update.error,
            started_at: info.started_at,
            finished_at: update.finished_at,
        }
    }
}
