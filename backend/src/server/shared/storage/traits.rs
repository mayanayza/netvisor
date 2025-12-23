use std::net::IpAddr;

use crate::server::groups::r#impl::base::Group;
use crate::server::services::r#impl::base::Service;
use crate::server::shared::events::types::TelemetryOperation;
use crate::server::subnets::r#impl::base::Subnet;
use crate::server::{
    billing::types::base::BillingPlan,
    daemons::r#impl::{api::DaemonCapabilities, base::DaemonMode},
    discovery::r#impl::types::{DiscoveryType, RunType},
    hosts::r#impl::{base::Host, virtualization::HostVirtualization},
    interfaces::r#impl::base::Interface,
    ports::r#impl::base::Port,
    services::r#impl::{definitions::ServiceDefinition, virtualization::ServiceVirtualization},
    shared::{storage::filter::EntityFilter, types::entities::EntitySource},
    topology::types::{
        base::TopologyOptions,
        edges::{Edge, EdgeStyle},
        nodes::Node,
    },
    users::r#impl::permissions::UserOrgPermissions,
};
use async_trait::async_trait;
use chrono::{DateTime, Utc};
use cidr::IpCidr;
use email_address::EmailAddress;
use mac_address::MacAddress;
use sqlx::postgres::PgRow;
use stripe_billing::SubscriptionStatus;
use uuid::Uuid;

#[async_trait]
pub trait Storage<T: StorableEntity>: Send + Sync {
    async fn create(&self, entity: &T) -> Result<T, anyhow::Error>;
    async fn get_by_id(&self, id: &Uuid) -> Result<Option<T>, anyhow::Error>;
    async fn get_all(&self, filter: EntityFilter) -> Result<Vec<T>, anyhow::Error>;
    async fn get_all_ordered(
        &self,
        filter: EntityFilter,
        order_by: &str,
    ) -> Result<Vec<T>, anyhow::Error>;
    async fn get_one(&self, filter: EntityFilter) -> Result<Option<T>, anyhow::Error>;
    async fn update(&self, entity: &mut T) -> Result<T, anyhow::Error>;
    async fn delete(&self, id: &Uuid) -> Result<(), anyhow::Error>;
    async fn delete_many(&self, ids: &[Uuid]) -> Result<usize, anyhow::Error>;
    async fn delete_by_filter(&self, filter: EntityFilter) -> Result<usize, anyhow::Error>;
}

pub trait StorableEntity: Sized + Clone + Send + Sync + 'static {
    type BaseData;

    fn new(base: Self::BaseData) -> Self;

    fn get_base(&self) -> Self::BaseData;

    /// Entity metadata
    fn table_name() -> &'static str;

    /// Primary key
    fn id(&self) -> Uuid;
    fn network_id(&self) -> Option<Uuid>;
    fn organization_id(&self) -> Option<Uuid>;
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
    Email(EmailAddress),
    Timestamp(DateTime<Utc>),
    OptionTimestamp(Option<DateTime<Utc>>),
    UuidArray(Vec<Uuid>),
    IpCidr(IpCidr),
    IpAddr(IpAddr),
    EntitySource(EntitySource),
    ServiceDefinition(Box<dyn ServiceDefinition>),
    OptionalServiceVirtualization(Option<ServiceVirtualization>),
    OptionalHostVirtualization(Option<HostVirtualization>),
    Ports(Vec<Port>),
    Interfaces(Vec<Interface>),
    RunType(RunType),
    DiscoveryType(DiscoveryType),
    DaemonCapabilities(DaemonCapabilities),
    UserOrgPermissions(UserOrgPermissions),
    OptionBillingPlan(Option<BillingPlan>),
    OptionBillingPlanStatus(Option<SubscriptionStatus>),
    EdgeStyle(EdgeStyle),
    DaemonMode(DaemonMode),
    Nodes(Vec<Node>),
    Edges(Vec<Edge>),
    TopologyOptions(TopologyOptions),
    Hosts(Vec<Host>),
    Subnets(Vec<Subnet>),
    Services(Vec<Service>),
    Groups(Vec<Group>),
    TelemetryOperation(Vec<TelemetryOperation>),
    StringArray(Vec<String>),
    OptionalStringArray(Option<Vec<String>>),
    JsonValue(serde_json::Value),
    OptionalMacAddress(Option<MacAddress>),
}
