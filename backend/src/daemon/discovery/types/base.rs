use std::fmt::Display;

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, Copy)]
pub enum DiscoveryPhase {
    Pending, // Initial state, set by server; all subsequent states until Finished are set by Daemon
    Starting,
    Started,
    Scanning,
    Complete,
    Failed,
    Cancelled,
}

#[derive(Debug, Clone)]
pub struct DiscoverySessionInfo {
    pub total_to_scan: usize,
    pub session_id: Uuid,
    pub daemon_id: Uuid,
    pub started_at: Option<DateTime<Utc>>,
}

#[derive(Debug, Clone)]
pub struct DiscoverySessionUpdate {
    pub phase: DiscoveryPhase,
    pub completed: usize,
    pub discovered_count: usize,
    pub error: Option<String>,
    pub finished_at: Option<DateTime<Utc>>,
}

impl DiscoverySessionUpdate {
    pub fn scanning(completed: usize, discovered_count: usize) -> Self {
        Self {
            phase: DiscoveryPhase::Scanning,
            completed,
            discovered_count,
            error: None,
            finished_at: None,
        }
    }
}

impl std::fmt::Display for DiscoveryPhase {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            DiscoveryPhase::Pending => {
                write!(f, "Session created, waiting for daemon availability")
            }
            DiscoveryPhase::Starting => write!(f, "Sending session to daemon"),
            DiscoveryPhase::Started => write!(f, "Session started in daemon"),
            DiscoveryPhase::Scanning => write!(f, "Scanning for active hosts"),
            DiscoveryPhase::Complete => write!(f, "Discovery complete"),
            DiscoveryPhase::Cancelled => write!(f, "Discovery cancelled"),
            DiscoveryPhase::Failed => write!(f, "Discovery failed"),
        }
    }
}

pub enum DiscoveryCriticalError {
    ResourceExhaustion,
}

impl DiscoveryCriticalError {
    pub fn is_critical_error(error_str: String) -> bool {
        Self::from_error_string(error_str).is_some()
    }

    pub fn from_error_string(error_str: String) -> Option<Self> {
        let lower_error = error_str.to_lowercase();

        if lower_error.contains("too many open files")
            || lower_error.contains("file descriptor limit")
            || lower_error.contains("cannot allocate memory")
            || lower_error.contains("out of memory")
            || lower_error.contains("os error 24")
            || lower_error.contains("emfile")
        {
            return Some(DiscoveryCriticalError::ResourceExhaustion);
        }

        None
    }
}

impl Display for DiscoveryCriticalError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            DiscoveryCriticalError::ResourceExhaustion => {
                write!(
                    f,
                    "Resource exhaustion during scan: too many open files - CONCURRENT_SCANS is likely too high for this system. Check README.md for troubleshooting."
                )
            }
        }
    }
}
