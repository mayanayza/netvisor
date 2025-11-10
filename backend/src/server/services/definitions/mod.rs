use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::shared::types::metadata::HasId;
use inventory;

#[derive(Debug, Clone, Copy)]
pub struct ServiceDefinitionFactory(pub fn() -> Box<dyn ServiceDefinition>);

impl ServiceDefinitionFactory {
    pub const fn new(factory: fn() -> Box<dyn ServiceDefinition>) -> Self {
        Self(factory)
    }

    pub fn create(&self) -> Box<dyn ServiceDefinition> {
        (self.0)()
    }
}

pub fn create_service<T>() -> Box<dyn ServiceDefinition>
where
    T: ServiceDefinition + Default + 'static,
{
    Box::new(T::default())
}

inventory::collect!(ServiceDefinitionFactory);

pub struct ServiceDefinitionRegistry;

impl ServiceDefinitionRegistry {
    /// Get all registered services as instances
    pub fn all_service_definitions() -> Vec<Box<dyn ServiceDefinition>> {
        inventory::iter::<ServiceDefinitionFactory>()
            .map(|factory| factory.create())
            .collect()
    }

    pub fn service_exists(id: &str) -> bool {
        inventory::iter::<ServiceDefinitionFactory>().any(|factory| factory.create().id() == id)
    }

    pub fn find_by_id(id: &str) -> Option<Box<dyn ServiceDefinition>> {
        inventory::iter::<ServiceDefinitionFactory>().find_map(|factory| {
            let service_definition = factory.create();
            if service_definition.id() == id {
                Some(service_definition)
            } else {
                None
            }
        })
    }
}

pub mod access_point;
pub mod adguard_home;
pub mod amazon_echo;
pub mod apc;
pub mod audiobookshelf;
pub mod authentik;
pub mod autobrr;
pub mod backrest;
pub mod bazarr;
pub mod bind9;
pub mod camera;
pub mod chromecast;
pub mod cleanuparr;
pub mod client;
pub mod cloudflared;
pub mod coolercontrol;
pub mod cups;
pub mod dhcp_server;
pub mod dns_server;
pub mod docker_container;
pub mod docker_daemon;
pub mod docker_swarm;
pub mod duplicati;
pub mod eero_gateway;
pub mod eero_repeater;
pub mod emby;
pub mod file_server;
pub mod fios_extender;
pub mod fios_gateway;
pub mod firewall;
pub mod fortigate;
pub mod gateway;
pub mod gatus;
pub mod glances;
pub mod google_home;
pub mod google_nest_repeater;
pub mod google_nest_router;
pub mod grafana;
pub mod graylog;
pub mod grocy;
pub mod homarr;
pub mod home_assistant;
pub mod homepage;
pub mod hp_printer;
pub mod huntarr;
pub mod immich;
pub mod iot;
pub mod jellyfin;
pub mod jellyseerr;
pub mod jellystat;
pub mod jump;
pub mod karakeep;
pub mod komga;
pub mod kubernetes;
pub mod lidarr;
pub mod linkstack;
pub mod lubelogger;
pub mod mealie;
pub mod memos;
pub mod nas_device;
pub mod nest_protect;
pub mod nest_thermostat;
pub mod netbootxyz;
pub mod netvisor_daemon;
pub mod netvisor_server;
pub mod next_cloud;
pub mod nginx_proxy_manager;
pub mod nut;
pub mod open_media_vault;
pub mod open_webui;
pub mod opn_sense;
pub mod overseerr;
pub mod paperless_ngx;
pub mod peanut;
pub mod pf_blocker_ng;
pub mod pf_sense;
pub mod philips_hue_bridge;
pub mod pi_hole;
pub mod plex;
pub mod pocket_id;
pub mod portainer;
pub mod power_dns;
pub mod print_server;
pub mod prometheus;
pub mod prowlarr;
pub mod proxmox;
pub mod proxmox_backup_server;
pub mod pulse;
pub mod qbittorrent;
pub mod qnap;
pub mod radarr;
pub mod restic;
pub mod ring_doorbell;
pub mod roku;
pub mod slskd;
pub mod sonarr;
pub mod sonos_speaker;
pub mod switch;
pub mod syncthing;
pub mod synology;
pub mod tautulli;
pub mod tp_link_eap;
pub mod traefik;
pub mod true_nas;
pub mod unbound;
pub mod unifi_access_point;
pub mod unifi_controller;
pub mod uptime_kuma;
pub mod vaultwarden;
pub mod web_service;
pub mod wg_dashboard;
pub mod workstation;
pub mod zigbee2mqtt;
