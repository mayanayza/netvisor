use crate::server::bindings::r#impl::base::Binding;
use crate::server::interfaces::r#impl::base::Interface;
use crate::server::invites::r#impl::base::Invite;
use crate::server::ports::r#impl::base::Port;
use crate::server::services::r#impl::base::Service;
use crate::server::shares::r#impl::base::Share;
use crate::server::subnets::r#impl::base::Subnet;
use crate::server::topology::types::base::Topology;
use crate::server::{groups::r#impl::base::Group, tags::r#impl::base::Tag};
use serde::{Deserialize, Serialize};
use strum_macros::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};

use crate::server::{
    api_keys::r#impl::base::ApiKey,
    daemons::r#impl::base::Daemon,
    discovery::r#impl::base::Discovery,
    hosts::r#impl::base::Host,
    networks::r#impl::Network,
    organizations::r#impl::base::Organization,
    shared::types::metadata::{EntityMetadataProvider, HasId},
    users::r#impl::base::User,
};

// Trait use to determine whether a given property change on an entity should trigger a rebuild of topology
pub trait ChangeTriggersTopologyStaleness<T> {
    fn triggers_staleness(&self, _other: Option<T>) -> bool;
}

#[derive(
    Debug,
    Clone,
    PartialEq,
    Eq,
    Hash,
    EnumDiscriminants,
    IntoStaticStr,
    Serialize,
    Deserialize,
    Display,
)]
#[strum_discriminants(derive(Display, Hash, EnumIter, IntoStaticStr))]
pub enum Entity {
    Organization(Organization),
    Invite(Invite),
    Share(Share),
    Network(Network),
    ApiKey(ApiKey),
    User(User),
    Tag(Tag),

    Discovery(Discovery),
    Daemon(Daemon),

    Host(Host),
    Service(Service),
    Port(Port),
    Binding(Binding),
    Interface(Interface),

    Subnet(Subnet),
    Group(Group),
    Topology(Box<Topology>),
}

impl HasId for EntityDiscriminants {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for EntityDiscriminants {
    fn color(&self) -> &'static str {
        match self {
            EntityDiscriminants::Organization => "blue",
            EntityDiscriminants::Network => "gray",
            EntityDiscriminants::Daemon => "green",
            EntityDiscriminants::Discovery => "green",
            EntityDiscriminants::ApiKey => "yellow",
            EntityDiscriminants::User => "blue",
            EntityDiscriminants::Invite => "green",
            EntityDiscriminants::Share => "teal",
            EntityDiscriminants::Tag => "yellow",

            EntityDiscriminants::Host => "blue",
            EntityDiscriminants::Service => "purple",
            EntityDiscriminants::Interface => "cyan",
            EntityDiscriminants::Port => "cyan",
            EntityDiscriminants::Binding => "purple",

            EntityDiscriminants::Subnet => "orange",
            EntityDiscriminants::Group => "rose",
            EntityDiscriminants::Topology => "pink",
        }
    }

    fn icon(&self) -> &'static str {
        match self {
            EntityDiscriminants::Organization => "Building",
            EntityDiscriminants::Network => "Globe",
            EntityDiscriminants::User => "User",
            EntityDiscriminants::Tag => "Tag",
            EntityDiscriminants::Invite => "UserPlus",
            EntityDiscriminants::Share => "Share2",
            EntityDiscriminants::ApiKey => "Key",
            EntityDiscriminants::Daemon => "SatelliteDish",
            EntityDiscriminants::Discovery => "Radar",
            EntityDiscriminants::Host => "Server",
            EntityDiscriminants::Service => "Layers",
            EntityDiscriminants::Interface => "Binary",
            EntityDiscriminants::Port => "EthernetPort",
            EntityDiscriminants::Binding => "Link",
            EntityDiscriminants::Subnet => "Network",
            EntityDiscriminants::Group => "Group",
            EntityDiscriminants::Topology => "ChartNetwork",
        }
    }
}

impl From<Organization> for Entity {
    fn from(value: Organization) -> Self {
        Self::Organization(value)
    }
}

impl From<Invite> for Entity {
    fn from(value: Invite) -> Self {
        Self::Invite(value)
    }
}

impl From<Share> for Entity {
    fn from(value: Share) -> Self {
        Self::Share(value)
    }
}

impl From<Network> for Entity {
    fn from(value: Network) -> Self {
        Self::Network(value)
    }
}

impl From<ApiKey> for Entity {
    fn from(value: ApiKey) -> Self {
        Self::ApiKey(value)
    }
}

impl From<User> for Entity {
    fn from(value: User) -> Self {
        Self::User(value)
    }
}

impl From<Discovery> for Entity {
    fn from(value: Discovery) -> Self {
        Self::Discovery(value)
    }
}

impl From<Daemon> for Entity {
    fn from(value: Daemon) -> Self {
        Self::Daemon(value)
    }
}

impl From<Host> for Entity {
    fn from(value: Host) -> Self {
        Self::Host(value)
    }
}

impl From<Service> for Entity {
    fn from(value: Service) -> Self {
        Self::Service(value)
    }
}

impl From<Port> for Entity {
    fn from(value: Port) -> Self {
        Self::Port(value)
    }
}

impl From<Binding> for Entity {
    fn from(value: Binding) -> Self {
        Self::Binding(value)
    }
}

impl From<Interface> for Entity {
    fn from(value: Interface) -> Self {
        Self::Interface(value)
    }
}

impl From<Subnet> for Entity {
    fn from(value: Subnet) -> Self {
        Self::Subnet(value)
    }
}

impl From<Group> for Entity {
    fn from(value: Group) -> Self {
        Self::Group(value)
    }
}

impl From<Topology> for Entity {
    fn from(value: Topology) -> Self {
        Self::Topology(Box::new(value))
    }
}

impl From<Tag> for Entity {
    fn from(value: Tag) -> Self {
        Self::Tag(value)
    }
}
