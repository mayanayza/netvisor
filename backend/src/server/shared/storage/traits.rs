use std::net::IpAddr;

use async_trait::async_trait;
use chrono::{DateTime, Utc};
use cidr::IpCidr;
use email_address::EmailAddress;
use sqlx::postgres::PgRow;
use uuid::Uuid;

use crate::server::{
    daemons::r#impl::api::DaemonCapabilities,
    discovery::r#impl::types::{DiscoveryType, RunType},
    groups::r#impl::types::GroupType,
    hosts::r#impl::{
        interfaces::Interface, ports::Port, targets::HostTarget, virtualization::HostVirtualization,
    },
    services::r#impl::{
        bindings::Binding, definitions::ServiceDefinition, virtualization::ServiceVirtualization,
    },
    shared::{storage::filter::EntityFilter, types::entities::EntitySource},
    subnets::r#impl::types::SubnetType,
    topology::types::edges::EdgeStyle,
};

#[async_trait]
pub trait Storage<T: StorableEntity>: Send + Sync {
    async fn create(&self, entity: &T) -> Result<T, anyhow::Error>;
    async fn get_by_id(&self, id: &Uuid) -> Result<Option<T>, anyhow::Error>;
    async fn get_all(&self, filter: EntityFilter) -> Result<Vec<T>, anyhow::Error>;
    async fn get_one(&self, filter: EntityFilter) -> Result<Option<T>, anyhow::Error>;
    async fn update(&self, entity: &mut T) -> Result<T, anyhow::Error>;
    async fn delete(&self, id: &Uuid) -> Result<(), anyhow::Error>;
}

pub trait StorableEntity: Sized + Clone + Send + Sync + 'static {
    type BaseData;

    fn new(base: Self::BaseData) -> Self;

    fn get_base(&self) -> Self::BaseData;

    /// Entity metadata
    fn table_name() -> &'static str;

    /// Primary key
    fn id(&self) -> Uuid;
    fn created_at(&self) -> DateTime<Utc>;
    fn updated_at(&self) -> DateTime<Utc>;
    fn set_updated_at(&mut self, time: DateTime<Utc>);

    /// Serialization for database storage
    /// Returns (column_names, bind_values)
    fn to_params(&self) -> Result<(Vec<&'static str>, Vec<SqlValue>), anyhow::Error>;

    /// Deserialization from database
    fn from_row(row: &PgRow) -> Result<Self, anyhow::Error>;
}

/// Helper type for SQL values
#[derive(Clone)]
pub enum SqlValue {
    Uuid(Uuid),
    OptionalUuid(Option<Uuid>),
    String(String),
    OptionalString(Option<String>),
    I32(i32),
    U16(u16),
    Bool(bool),
    Json(serde_json::Value),
    Email(EmailAddress),
    Timestamp(DateTime<Utc>),
    OptionTimestamp(Option<DateTime<Utc>>),
    UuidArray(Vec<Uuid>),
    IpCidr(IpCidr),
    IpAddr(IpAddr),
    EntitySource(EntitySource),
    SubnetType(SubnetType),
    GroupType(GroupType),
    Bindings(Vec<Binding>),
    ServiceDefinition(Box<dyn ServiceDefinition>),
    OptionalServiceVirtualization(Option<ServiceVirtualization>),
    OptionalHostVirtualization(Option<HostVirtualization>),
    Ports(Vec<Port>),
    Interfaces(Vec<Interface>),
    HostTarget(HostTarget),
    RunType(RunType),
    DiscoveryType(DiscoveryType),
    DaemonCapabilities(DaemonCapabilities),
    EdgeStyle(EdgeStyle),
}
