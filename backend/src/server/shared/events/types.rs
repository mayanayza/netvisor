use crate::server::{auth::middleware::AuthenticatedEntity, shared::entities::Entity};
use chrono::{DateTime, Utc};
use serde::Serialize;
use std::{fmt::Display, net::IpAddr};
use strum::IntoDiscriminant;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize)]
pub enum Event {
    Entity(Box<EntityEvent>),
    Auth(AuthEvent),
}

impl Event {
    pub fn id(&self) -> Uuid {
        match self {
            Event::Auth(a) => a.id,
            Event::Entity(e) => e.id,
        }
    }

    pub fn org_id(&self) -> Option<Uuid> {
        match self {
            Event::Auth(a) => a.organization_id,
            Event::Entity(e) => e.organization_id,
        }
    }

    pub fn network_id(&self) -> Option<Uuid> {
        match self {
            Event::Auth(_) => None,
            Event::Entity(e) => e.network_id,
        }
    }

    pub fn log(&self) {
        match self {
            Event::Entity(event) => {
                let network_id_str = event
                    .network_id
                    .map(|n| n.to_string())
                    .unwrap_or("N/A".to_string());
                let org_id_str = event
                    .organization_id
                    .map(|n| n.to_string())
                    .unwrap_or("N/A".to_string());

                tracing::info!(
                    entity_type = %event.entity_type,
                    entity_id = %event.entity_id,
                    network_id = %network_id_str,
                    organization_id = %org_id_str,
                    operation = %event.operation,
                    "Entity Event Logged"
                );
            }
            Event::Auth(event) => {
                let user_id_str = event
                    .user_id
                    .map(|n| n.to_string())
                    .unwrap_or("N/A".to_string());
                let user_agent_str = event
                    .user_agent
                    .as_ref()
                    .map(|u| u.to_owned())
                    .unwrap_or("unknown".to_string());
                let org_id_str = event
                    .organization_id
                    .map(|u| u.to_string())
                    .unwrap_or("None".to_string());

                tracing::info!(
                    ip = %event.ip_address,
                    organization_id = %org_id_str,
                    user_id = %user_id_str,
                    user_agent = %user_agent_str,
                    operation = %event.operation,
                    "Auth Event Logged"
                );
            }
        }
    }
}

impl Display for Event {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Event::Auth(a) => write!(
                f,
                "{{ id: {}, user_id: {}, organization_id: {}, operation: {}, timestamp: {}, ip_address: {}, user_agent: {}, metadata: {}, authentication: {} }}",
                a.id,
                a.user_id
                    .map(|u| u.to_string())
                    .unwrap_or("None".to_string()),
                a.organization_id
                    .map(|u| u.to_string())
                    .unwrap_or("None".to_string()),
                a.operation,
                a.timestamp,
                a.ip_address,
                a.user_agent.clone().unwrap_or("Unknown".to_string()),
                a.metadata,
                a.authentication
            ),
            Event::Entity(e) => write!(
                f,
                "{{ id: {}, entity_type: {}, entity_id: {}, network_id: {}, organization_id: {}, operation: {}, timestamp: {}, metadata: {}, authentication: {} }}",
                e.id,
                e.entity_type.discriminant(),
                e.entity_id,
                e.network_id
                    .map(|u| u.to_string())
                    .unwrap_or("None".to_string()),
                e.organization_id
                    .map(|u| u.to_string())
                    .unwrap_or("None".to_string()),
                e.operation,
                e.timestamp,
                e.metadata,
                e.authentication
            ),
        }
    }
}

impl PartialEq for Event {
    fn eq(&self, other: &Self) -> bool {
        match (self, other) {
            (Event::Auth(a1), Event::Auth(a2)) => a1 == a2,
            (Event::Entity(e1), Event::Entity(e2)) => e1 == e2,
            _ => false,
        }
    }
}

#[derive(Debug, Clone, Serialize, PartialEq, Eq, strum::Display)]
pub enum AuthOperation {
    Register,
    LoginSuccess,
    LoginFailed,
    PasswordResetRequested,
    PasswordResetCompleted,
    PasswordChanged,
    EmailVerified,
    SessionExpired,
    OidcLinked,
    OidcUnlinked,
    LoggedOut,
}

#[derive(Debug, Clone, Serialize)]
pub struct AuthEvent {
    pub id: Uuid,
    pub user_id: Option<Uuid>, // None for failed login with unknown user
    pub organization_id: Option<Uuid>,
    pub operation: AuthOperation,
    pub timestamp: DateTime<Utc>,
    pub ip_address: IpAddr,
    pub user_agent: Option<String>,
    pub metadata: serde_json::Value,
    pub authentication: AuthenticatedEntity,
}

impl PartialEq for AuthEvent {
    fn eq(&self, other: &Self) -> bool {
        self.user_id == other.user_id
            && self.organization_id == other.organization_id
            && self.operation == other.operation
            && self.ip_address == other.ip_address
            && self.user_agent == other.user_agent
            && self.metadata == other.metadata
            && self.authentication == other.authentication
    }
}

#[derive(Debug, Clone, Serialize, PartialEq, Eq, strum::Display)]
pub enum EntityOperation {
    Get,
    GetAll,
    Created,
    Updated,
    Deleted,
    DiscoveryStarted,
    DiscoveryCancelled,
    Custom(&'static str),
}

#[derive(Debug, Clone, Serialize, Eq)]
pub struct EntityEvent {
    pub id: Uuid,
    pub entity_type: Entity,
    pub entity_id: Uuid,
    pub network_id: Option<Uuid>, // Some entities might belong to an org, not a network (ie users)
    pub organization_id: Option<Uuid>, // Some entities might belong to a network, not an org
    pub operation: EntityOperation,
    pub timestamp: DateTime<Utc>,
    pub authentication: AuthenticatedEntity,
    pub metadata: serde_json::Value,
}

impl PartialEq for EntityEvent {
    fn eq(&self, other: &Self) -> bool {
        self.entity_id == other.entity_id
            && self.network_id == other.network_id
            && self.organization_id == other.organization_id
            && self.operation == other.operation
            && self.authentication == other.authentication
            && self.metadata == other.metadata
    }
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
