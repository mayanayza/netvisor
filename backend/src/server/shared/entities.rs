use strum_macros::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};

use crate::server::shared::types::metadata::{EntityMetadataProvider, HasId};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, EnumDiscriminants, EnumIter, IntoStaticStr)]
#[strum_discriminants(derive(Display))]
pub enum Entity {
    Network,
    Discovery,
    Daemon,

    Host,
    Service,
    Port,
    Interface,

    Subnet,
    Group,
    Topology,

    Dns,
    Vpn,
    Gateway,
    ReverseProxy,
    IoT,
    Storage,
    Virtualization,
}

impl HasId for Entity {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for Entity {
    fn color(&self) -> &'static str {
        match self {
            Entity::Network => "gray",
            Entity::Daemon => "green",
            Entity::Discovery => "green",

            Entity::Host => "blue",
            Entity::Service => "purple",
            Entity::Interface => "cyan",
            Entity::Port => "cyan",

            Entity::Dns => "emerald",
            Entity::Vpn => "green",
            Entity::Gateway => "teal",
            Entity::ReverseProxy => "cyan",

            Entity::Subnet => "orange",
            Entity::Group => "rose",
            Entity::Topology => "pink",

            Entity::IoT => "yellow",
            Entity::Storage => "green",
            Entity::Virtualization => "indigo",
        }
    }

    fn icon(&self) -> &'static str {
        match self {
            Entity::Network => "Globe",
            Entity::Daemon => "SatelliteDish",
            Entity::Discovery => "Radar",
            Entity::Host => "Server",
            Entity::Service => "Layers",
            Entity::Interface => "Binary",
            Entity::Dns => "Search",
            Entity::Vpn => "VenetianMask",
            Entity::Port => "EthernetPort",
            Entity::Gateway => "Router",
            Entity::ReverseProxy => "Split",
            Entity::Subnet => "Network",
            Entity::Group => "Group",
            Entity::Topology => "ChartNetwork",
            Entity::IoT => "Cpu",
            Entity::Storage => "HardDrive",
            Entity::Virtualization => "MonitorCog",
        }
    }
}
