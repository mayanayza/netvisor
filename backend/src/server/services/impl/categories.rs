use serde::{Deserialize, Serialize};
use strum_macros::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};
use utoipa::ToSchema;

use crate::server::shared::{
    concepts::Concept,
    entities::EntityDiscriminants,
    types::{
        Color, Icon,
        metadata::{EntityMetadataProvider, HasId},
    },
};

#[derive(
    Debug,
    Copy,
    Clone,
    PartialEq,
    Eq,
    Hash,
    Serialize,
    Display,
    Deserialize,
    EnumDiscriminants,
    EnumIter,
    IntoStaticStr,
    ToSchema,
)]
pub enum ServiceCategory {
    // Infrastructure (always-on, core network services)
    NetworkCore,     // Routers, switches, core infrastructure
    NetworkAccess,   // WiFi APs, switches for end devices
    NetworkSecurity, // Firewalls, security appliances

    // Server Services
    Storage, // NAS, file servers
    Backup,
    Media,          // Plex, Jellyfin
    HomeAutomation, // Home Assistant
    Virtualization, // Proxmox, ESXi

    // Network Services
    DNS,        // All DNS services
    VPN,        // All VPN services
    Monitoring, // SNMP, monitoring tools
    AdBlock,
    ReverseProxy,

    // End Devices
    Workstation, // Desktops, laptops
    Mobile,      // Phones, tablets
    IoT,         // Smart devices, sensors
    Printer,     // All printing devices

    // Applications
    Database,    // DB servers
    Development, // Dev tools, CI/CD
    Dashboard,
    MessageQueue,
    IdentityAndAccess,

    // Office & Productivity
    Office,            // Document editing, notes, file management
    ProjectManagement, // Task tracking, wikis, kanban boards

    // Communication
    Messaging,    // Team chat (text-based)
    Conferencing, // Video/audio meetings
    Telephony,    // VoIP/PBX infrastructure
    Email,        // Email servers

    // Content
    Publishing, // CMS, blogs, forums

    // Special
    Unknown,
    Custom,
    Scanopy,
    OpenPorts,
}

impl HasId for ServiceCategory {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for ServiceCategory {
    fn icon(&self) -> Icon {
        match self {
            // Infrastructure (always-on, core network services)
            ServiceCategory::NetworkCore => Icon::Network,
            ServiceCategory::NetworkAccess => Icon::Router,
            ServiceCategory::NetworkSecurity => Icon::BrickWall,

            // Server Services
            ServiceCategory::Storage => Icon::HardDrive,
            ServiceCategory::Media => Icon::CirclePlay,
            ServiceCategory::HomeAutomation => Icon::House,
            ServiceCategory::Virtualization => Concept::Virtualization.icon(),
            ServiceCategory::Backup => Icon::DatabaseBackup,

            // Network Services
            ServiceCategory::DNS => Concept::Dns.icon(),
            ServiceCategory::VPN => Concept::Vpn.icon(),
            ServiceCategory::Monitoring => Icon::Activity,
            ServiceCategory::AdBlock => Icon::ShieldCheck,
            ServiceCategory::ReverseProxy => Concept::ReverseProxy.icon(),

            // End devices
            ServiceCategory::Workstation => Icon::Monitor,
            ServiceCategory::Mobile => Icon::Smartphone,
            ServiceCategory::IoT => Concept::IoT.icon(),
            ServiceCategory::Printer => Icon::Printer,

            // Applications
            ServiceCategory::Database => Icon::Database,
            ServiceCategory::Development => Icon::Code,
            ServiceCategory::MessageQueue => Icon::MessageSquareCode,
            ServiceCategory::Dashboard => Icon::LayoutDashboard,
            ServiceCategory::IdentityAndAccess => Icon::KeyRound,

            // Office & Productivity
            ServiceCategory::Office => Icon::FileText,
            ServiceCategory::ProjectManagement => Icon::SquareKanban,

            // Communication
            ServiceCategory::Messaging => Icon::MessageCircle,
            ServiceCategory::Conferencing => Icon::Video,
            ServiceCategory::Telephony => Icon::Phone,
            ServiceCategory::Email => Icon::Mail,

            // Content
            ServiceCategory::Publishing => Icon::PenLine,

            // Special
            ServiceCategory::Scanopy => Icon::Zap,
            ServiceCategory::Custom => Icon::Sparkle,
            ServiceCategory::OpenPorts => EntityDiscriminants::Port.icon(),
            ServiceCategory::Unknown => Icon::CircleQuestionMark,
        }
    }

    fn color(&self) -> Color {
        match self {
            // Infrastructure (always-on, core network services)
            ServiceCategory::NetworkCore => Color::Yellow,
            ServiceCategory::NetworkAccess => Color::Green,
            ServiceCategory::NetworkSecurity => Color::Red,

            // Server Services
            ServiceCategory::Storage => Color::Green,
            ServiceCategory::Media => Color::Blue,
            ServiceCategory::HomeAutomation => Color::Blue,
            ServiceCategory::Virtualization => Concept::Virtualization.color(),
            ServiceCategory::Backup => Color::Gray,

            // Network Services
            ServiceCategory::DNS => Concept::Dns.color(),
            ServiceCategory::VPN => Concept::Vpn.color(),
            ServiceCategory::Monitoring => Color::Orange,
            ServiceCategory::AdBlock => Concept::Dns.color(),
            ServiceCategory::ReverseProxy => Concept::ReverseProxy.color(),

            // End devices
            ServiceCategory::Workstation => Color::Green,
            ServiceCategory::Mobile => Color::Blue,
            ServiceCategory::IoT => Concept::IoT.color(),
            ServiceCategory::Printer => Color::Gray,

            // Applications
            ServiceCategory::Database => Color::Gray,
            ServiceCategory::Development => Color::Red,
            ServiceCategory::Dashboard => Color::Purple,
            ServiceCategory::MessageQueue => Color::Green,
            ServiceCategory::IdentityAndAccess => Color::Yellow,

            // Office & Productivity
            ServiceCategory::Office => Color::Blue,
            ServiceCategory::ProjectManagement => Color::Indigo,

            // Communication
            ServiceCategory::Messaging => Color::Green,
            ServiceCategory::Conferencing => Color::Teal,
            ServiceCategory::Telephony => Color::Orange,
            ServiceCategory::Email => Color::Rose,

            // Content
            ServiceCategory::Publishing => Color::Purple, // was "violet", mapped to purple

            // Special
            ServiceCategory::Scanopy => Color::Purple,
            ServiceCategory::Custom => Color::Rose,
            ServiceCategory::OpenPorts => EntityDiscriminants::Port.color(),
            ServiceCategory::Unknown => Color::Gray,
        }
    }
}
