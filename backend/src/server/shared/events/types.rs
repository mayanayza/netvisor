use crate::server::{auth::middleware::auth::AuthenticatedEntity, shared::entities::Entity};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::{fmt::Display, net::IpAddr};
use strum::IntoDiscriminant;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize)]
pub enum Event {
    Entity(Box<EntityEvent>),
    Auth(AuthEvent),
    Telemetry(TelemetryEvent),
}

#[derive(Debug, Clone, Serialize)]
pub enum EventOperation {
    EntityOperation(EntityOperation),
    AuthOperation(AuthOperation),
    TelemetryOperation(TelemetryOperation),
}

#[derive(Debug, Clone, Serialize)]
pub enum EventLogLevel {
    Error,
    Warn,
    Info,
    Debug,
    Trace,
}

impl EventOperation {
    pub fn log_level(&self) -> EventLogLevel {
        match self {
            EventOperation::EntityOperation(entity_operation) => entity_operation.log_level(),
            EventOperation::AuthOperation(auth_operation) => auth_operation.log_level(),
            EventOperation::TelemetryOperation(telemetry_operation) => {
                telemetry_operation.log_level()
            }
        }
    }
}

impl Display for EventOperation {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let string = match self {
            EventOperation::EntityOperation(entity_operation) => entity_operation.to_string(),
            EventOperation::AuthOperation(auth_operation) => auth_operation.to_string(),
            EventOperation::TelemetryOperation(telemetry_operation) => {
                telemetry_operation.to_string()
            }
        };

        write!(f, "{}", string)
    }
}

impl From<EntityOperation> for EventOperation {
    fn from(value: EntityOperation) -> Self {
        Self::EntityOperation(value)
    }
}

impl From<AuthOperation> for EventOperation {
    fn from(value: AuthOperation) -> Self {
        Self::AuthOperation(value)
    }
}

impl From<TelemetryOperation> for EventOperation {
    fn from(value: TelemetryOperation) -> Self {
        Self::TelemetryOperation(value)
    }
}

impl Event {
    pub fn id(&self) -> Uuid {
        match self {
            Event::Auth(a) => a.id,
            Event::Entity(e) => e.id,
            Event::Telemetry(t) => t.id,
        }
    }

    pub fn org_id(&self) -> Option<Uuid> {
        match self {
            Event::Auth(a) => a.organization_id,
            Event::Entity(e) => e.organization_id,
            Event::Telemetry(t) => Some(t.organization_id),
        }
    }

    pub fn network_id(&self) -> Option<Uuid> {
        match self {
            Event::Auth(_) => None,
            Event::Entity(e) => e.network_id,
            Event::Telemetry(_) => None,
        }
    }

    pub fn metadata(&self) -> serde_json::Value {
        match self {
            Event::Auth(e) => e.metadata.clone(),
            Event::Entity(e) => e.metadata.clone(),
            Event::Telemetry(e) => e.metadata.clone(),
        }
    }

    pub fn authentication(&self) -> AuthenticatedEntity {
        match self {
            Event::Auth(e) => e.authentication.clone(),
            Event::Entity(e) => e.authentication.clone(),
            Event::Telemetry(e) => e.authentication.clone(),
        }
    }

    pub fn operation(&self) -> EventOperation {
        match self {
            Event::Auth(e) => e.operation.clone().into(),
            Event::Entity(e) => e.operation.clone().into(),
            Event::Telemetry(e) => e.operation.clone().into(),
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
                );
            }
            Event::Telemetry(event) => {
                tracing::info!(
                    organization_id = %event.organization_id,
                    operation = %event.operation,
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
            Event::Telemetry(t) => write!(
                f,
                "{{ id: {}, authentication: {}, organization_id: {}, operation: {}, timestamp: {}, metadata: {} }}",
                t.id, t.authentication, t.organization_id, t.operation, t.timestamp, t.metadata,
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
#[strum(serialize_all = "snake_case")]
pub enum AuthOperation {
    // User Auth
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

    // Api Key Auth
    RotateKey,
}

impl AuthOperation {
    fn log_level(&self) -> EventLogLevel {
        match self {
            AuthOperation::LoginFailed => EventLogLevel::Error,
            _ => EventLogLevel::Info,
        }
    }
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

impl Display for AuthEvent {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{{ id: {}, operation: {}, ip: {}, user_agent: {}, authentication: {} }}",
            self.id,
            self.operation,
            self.ip_address,
            self.user_agent.clone().unwrap_or("unknown".to_string()),
            self.authentication
        )
    }
}

#[derive(Debug, Clone, Serialize, PartialEq, Eq, strum::Display)]
#[strum(serialize_all = "snake_case")]
pub enum EntityOperation {
    Get,
    GetAll,
    Created,
    Updated,
    Deleted,
    DiscoveryStarted,
    DiscoveryCancelled,
}

impl EntityOperation {
    fn log_level(&self) -> EventLogLevel {
        EventLogLevel::Info
    }
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
            "{{ id: {}, entity_type: {}, entity_id: {}, operation: {} }}",
            self.id, self.entity_type, self.entity_id, self.operation
        )
    }
}

#[derive(Debug, Clone, Serialize, PartialEq, Eq, Hash, Deserialize, strum::Display, utoipa::ToSchema)]
#[strum(serialize_all = "snake_case")]
pub enum TelemetryOperation {
    // Onboarding funnel
    OrgCreated,
    OnboardingModalCompleted,
    PersonalPlanSelected,
    CommercialPlanSelected,
    FirstApiKeyCreated,
    FirstDaemonRegistered,
    FirstTopologyRebuild,
    // FirstDiscoveryStarted,
    // FirstDiscoveryCompleted,
    // FirstHostDiscovered,
}

impl TelemetryOperation {
    fn log_level(&self) -> EventLogLevel {
        EventLogLevel::Info
    }
}

#[derive(Debug, Clone, Serialize, PartialEq)]
pub struct TelemetryEvent {
    pub id: Uuid,
    pub organization_id: Uuid,
    pub operation: TelemetryOperation,
    pub timestamp: DateTime<Utc>,
    pub authentication: AuthenticatedEntity,
    pub metadata: serde_json::Value,
}

impl Display for TelemetryEvent {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{{ id: {}, organization_id: {}, operation: {}, authentication: {} }}",
            self.id, self.organization_id, self.operation, self.authentication
        )
    }
}
