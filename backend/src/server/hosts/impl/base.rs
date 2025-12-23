use crate::server::hosts::r#impl::virtualization::HostVirtualization;
use crate::server::shared::entities::ChangeTriggersTopologyStaleness;
use crate::server::shared::types::api::deserialize_empty_string_as_none;
use crate::server::shared::types::entities::EntitySource;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::fmt::Display;
use std::hash::Hash;
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

/// Base data for a Host entity (stored in database).
/// Child entities (interfaces, ports, services) are stored in their own tables
/// and queried by `host_id`. They are NOT stored on the host.
#[derive(Debug, Clone, Serialize, Validate, Deserialize, Eq, PartialEq, Hash, ToSchema)]
pub struct HostBase {
    #[validate(length(min = 0, max = 100))]
    pub name: String,
    pub network_id: Uuid,
    pub hostname: Option<String>,
    #[validate(length(min = 0, max = 100))]
    #[serde(deserialize_with = "deserialize_empty_string_as_none")]
    pub description: Option<String>,
    pub source: EntitySource,
    pub virtualization: Option<HostVirtualization>,
    pub hidden: bool,
    #[serde(default)]
    pub tags: Vec<Uuid>,
}

impl Default for HostBase {
    fn default() -> Self {
        Self {
            name: String::new(),
            network_id: Uuid::nil(),
            hostname: None,
            description: None,
            source: EntitySource::Unknown,
            virtualization: None,
            hidden: false,
            tags: Vec::new(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Eq, Default, ToSchema)]
#[schema(example = crate::server::shared::types::examples::host)]
pub struct Host {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    pub base: HostBase,
}

impl Hash for Host {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.id.hash(state);
    }
}

impl PartialEq for Host {
    fn eq(&self, other: &Self) -> bool {
        self.id == other.id
    }
}

impl Display for Host {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}: {:?}", self.base.name, self.id)
    }
}

impl Host {
    pub fn new(base: HostBase) -> Self {
        let now = chrono::Utc::now();
        Self {
            id: uuid::Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base,
        }
    }
}

impl ChangeTriggersTopologyStaleness<Host> for Host {
    fn triggers_staleness(&self, other: Option<Host>) -> bool {
        if let Some(other_host) = other {
            self.base.hostname != other_host.base.hostname
                || self.base.virtualization != other_host.base.virtualization
                || self.base.hidden != other_host.base.hidden
        } else {
            true
        }
    }
}
