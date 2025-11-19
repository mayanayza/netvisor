use crate::server::{auth::middleware::AuthenticatedEntity, shared::entities::Entity};
use chrono::{DateTime, Utc};
use serde::Serialize;
use std::fmt::Display;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, PartialEq, Eq, strum::Display)]
pub enum EntityOperation {
    Created,
    Updated,
    Deleted,
    Custom(&'static str),
}

#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
pub struct EntityEvent {
    pub id: Uuid,
    pub entity_type: Entity,
    pub entity_id: Uuid,
    pub network_id: Option<Uuid>, // Some entities might belong to an org, not a network
    pub organization_id: Option<Uuid>, // Some entities might belong to a network, not an org
    pub operation: EntityOperation,
    pub timestamp: DateTime<Utc>,
    pub authentication: AuthenticatedEntity,

    // Optional: store change details
    pub metadata: serde_json::Value,
}

impl Display for EntityEvent {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "Event: {{ id: {}, entity_type: {}, entity_id: {} }}",
            self.id, self.entity_type, self.entity_id
        )
    }
}
