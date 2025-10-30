use std::{fmt::Display, net::IpAddr};

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize, Serializer};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DaemonBase {
    pub host_id: Uuid,
    pub network_id: Uuid,
    pub ip: IpAddr,
    pub port: u16,
    #[serde(serialize_with = "serialize_api_key_status")]
    pub api_key: Option<String>,
}

fn serialize_api_key_status<S>(key: &Option<String>, serializer: S) -> Result<S::Ok, S::Error>
where
    S: Serializer,
{
    if key.is_none() {
        serializer.serialize_none()
    } else {
        serializer.serialize_str("***REDACTED***")
    }
}


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Daemon {
    pub id: Uuid,
    pub last_seen: DateTime<Utc>,
    pub registered_at: DateTime<Utc>,
    #[serde(flatten)]
    pub base: DaemonBase,
}

impl Daemon {
    pub fn new(id: Uuid, base: DaemonBase) -> Self {
        let now = Utc::now();
        Self {
            id,
            base,
            last_seen: now,
            registered_at: now,
        }
    }
}

impl Display for Daemon {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}: {}", self.base.ip, self.id)
    }
}
