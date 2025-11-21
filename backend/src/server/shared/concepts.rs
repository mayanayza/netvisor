use serde::{Deserialize, Serialize};
use strum_macros::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};

use crate::server::shared::types::metadata::{EntityMetadataProvider, HasId};

#[derive(
    Debug,
    Clone,
    PartialEq,
    Eq,
    Hash,
    EnumDiscriminants,
    EnumIter,
    IntoStaticStr,
    Serialize,
    Deserialize,
    Display,
)]
#[strum_discriminants(derive(Display, Hash, EnumIter, IntoStaticStr))]
pub enum Concept {
    Dns,
    Vpn,
    Gateway,
    ReverseProxy,
    IoT,
    Storage,
    Virtualization,
}

impl HasId for Concept {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for Concept {
    fn color(&self) -> &'static str {
        match self {
            Concept::Dns => "emerald",
            Concept::Vpn => "green",
            Concept::Gateway => "teal",
            Concept::ReverseProxy => "cyan",
            Concept::IoT => "yellow",
            Concept::Storage => "green",
            Concept::Virtualization => "indigo",
        }
    }

    fn icon(&self) -> &'static str {
        match self {
            Concept::Dns => "Search",
            Concept::Vpn => "VenetianMask",
            Concept::Gateway => "Router",
            Concept::ReverseProxy => "Split",
            Concept::IoT => "Cpu",
            Concept::Storage => "HardDrive",
            Concept::Virtualization => "MonitorCog",
        }
    }
}
