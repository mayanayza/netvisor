//! Test to generate TypeScript types from Rust structs.
//!
//! Run with: `cargo test export_typescript_types -- --nocapture`
//!
//! This test triggers ts-rs to export all types that have `#[ts(export)]`.
//! Types are exported to `ui/src/lib/generated/`.

#[cfg(test)]
mod tests {
    use ts_rs::TS;

    // Import key types that will pull in their dependencies
    use crate::server::api_keys::r#impl::base::ApiKey;
    use crate::server::bindings::r#impl::base::Binding;
    use crate::server::daemons::r#impl::api::DaemonCapabilities;
    use crate::server::daemons::r#impl::base::{Daemon, DaemonMode};
    use crate::server::discovery::r#impl::base::Discovery;
    use crate::server::discovery::r#impl::types::{DiscoveryType, RunType};
    use crate::server::groups::r#impl::base::Group;
    use crate::server::groups::r#impl::types::GroupType;
    use crate::server::hosts::r#impl::api::{
        CreateHostRequest, CreateInterfaceInput, CreatePortInput, UpdateHostRequest,
    };
    use crate::server::hosts::r#impl::virtualization::HostVirtualization;
    use crate::server::interfaces::r#impl::base::Interface;
    use crate::server::networks::r#impl::Network;
    use crate::server::organizations::r#impl::base::Organization;
    use crate::server::ports::r#impl::base::{Port, TransportProtocol};
    use crate::server::services::r#impl::base::Service;
    use crate::server::services::r#impl::virtualization::ServiceVirtualization;
    use crate::server::shared::types::entities::EntitySource;
    use crate::server::subnets::r#impl::base::Subnet;
    use crate::server::subnets::r#impl::types::SubnetType;
    use crate::server::tags::r#impl::base::Tag;
    use crate::server::topology::types::edges::EdgeStyle;
    use crate::server::users::r#impl::base::User;
    use crate::server::users::r#impl::permissions::UserOrgPermissions;

    #[test]
    fn export_typescript_types() {
        // Export all types - each export_all() also exports dependencies
        ApiKey::export_all().unwrap();
        Binding::export_all().unwrap();
        Daemon::export_all().unwrap();
        DaemonMode::export_all().unwrap();
        DaemonCapabilities::export_all().unwrap();
        Discovery::export_all().unwrap();
        DiscoveryType::export_all().unwrap();
        RunType::export_all().unwrap();
        Group::export_all().unwrap();
        GroupType::export_all().unwrap();
        EdgeStyle::export_all().unwrap();
        CreateHostRequest::export_all().unwrap();
        CreateInterfaceInput::export_all().unwrap();
        CreatePortInput::export_all().unwrap();
        UpdateHostRequest::export_all().unwrap();
        HostVirtualization::export_all().unwrap();
        Interface::export_all().unwrap();
        Network::export_all().unwrap();
        Organization::export_all().unwrap();
        Port::export_all().unwrap();
        TransportProtocol::export_all().unwrap();
        Service::export_all().unwrap();
        ServiceVirtualization::export_all().unwrap();
        EntitySource::export_all().unwrap();
        Subnet::export_all().unwrap();
        SubnetType::export_all().unwrap();
        Tag::export_all().unwrap();
        User::export_all().unwrap();
        UserOrgPermissions::export_all().unwrap();

        println!("TypeScript types exported to: ui/src/lib/generated/");
    }
}
