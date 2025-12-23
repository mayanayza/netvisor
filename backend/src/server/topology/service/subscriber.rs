use std::collections::HashMap;

use anyhow::Error;
use async_trait::async_trait;
use uuid::Uuid;

use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    shared::{
        entities::{Entity, EntityDiscriminants},
        events::{
            bus::{EventFilter, EventSubscriber},
            types::{EntityOperation, Event},
        },
        services::traits::CrudService,
        storage::filter::EntityFilter as StorageFilter,
    },
    topology::service::main::TopologyService,
};

#[derive(Default)]
struct TopologyChanges {
    updated_hosts: bool,
    updated_interfaces: bool,
    updated_services: bool,
    updated_subnets: bool,
    updated_groups: bool,
    removed_hosts: std::collections::HashSet<Uuid>,
    removed_interfaces: std::collections::HashSet<Uuid>,
    removed_services: std::collections::HashSet<Uuid>,
    removed_subnets: std::collections::HashSet<Uuid>,
    removed_groups: std::collections::HashSet<Uuid>,
    should_mark_stale: bool,
    clear_stale: bool,
}

#[async_trait]
impl EventSubscriber for TopologyService {
    fn event_filter(&self) -> EventFilter {
        EventFilter::entity_only(HashMap::from([
            (EntityDiscriminants::Host, None),
            (EntityDiscriminants::Interface, None),
            (EntityDiscriminants::Service, None),
            (EntityDiscriminants::Subnet, None),
            (EntityDiscriminants::Group, None),
            (
                EntityDiscriminants::Topology,
                Some(vec![EntityOperation::Created, EntityOperation::Updated]),
            ),
        ]))
    }

    async fn handle_events(&self, events: Vec<Event>) -> Result<(), Error> {
        if events.is_empty() {
            return Ok(());
        }

        // Collect all affected network IDs
        let mut network_ids = std::collections::HashSet::new();

        // Group events by network_id -> topology changes
        let mut topology_updates: HashMap<Uuid, TopologyChanges> = HashMap::new();

        for event in events {
            if let Event::Entity(entity_event) = event
                && let Some(network_id) = entity_event.network_id
            {
                // Check if any event triggers staleness
                let trigger_stale = entity_event
                    .metadata
                    .get("trigger_stale")
                    .and_then(|v| serde_json::from_value::<bool>(v.clone()).ok())
                    .unwrap_or(false);

                // Check if any event clears staleness (only set on topology create to avoid showing topology as stale on first load)
                let clear_stale = entity_event
                    .metadata
                    .get("clear_stale")
                    .and_then(|v| serde_json::from_value::<bool>(v.clone()).ok())
                    .unwrap_or(false);

                // Topology updates from changes to options should be applied immediately and not processed alongside
                // other changes, otherwise another call to topology_service.update will be made which will trigger
                // an infinite loop
                if let Entity::Topology(boxed_topology) = entity_event.entity_type.clone()
                    && entity_event.operation == EntityOperation::Updated
                {
                    let mut topology = *boxed_topology;
                    if trigger_stale {
                        topology.base.is_stale = true;
                    }

                    topology.base.services = self
                        .get_service_data(network_id, &topology.base.options)
                        .await?;

                    let _ = self.staleness_tx.send(topology).inspect_err(|e| {
                        tracing::debug!("Staleness notification skipped (no receivers): {}", e)
                    });
                    continue;
                }

                network_ids.insert(network_id);

                let changes = topology_updates.entry(network_id).or_default();

                // Track removed entities
                if entity_event.operation == EntityOperation::Deleted {
                    match entity_event.entity_type {
                        Entity::Host(_) => changes.removed_hosts.insert(entity_event.entity_id),
                        Entity::Interface(_) => {
                            changes.removed_interfaces.insert(entity_event.entity_id)
                        }
                        Entity::Service(_) => {
                            changes.removed_services.insert(entity_event.entity_id)
                        }
                        Entity::Subnet(_) => changes.removed_subnets.insert(entity_event.entity_id),
                        Entity::Group(_) => changes.removed_groups.insert(entity_event.entity_id),
                        _ => false,
                    };
                }

                if trigger_stale {
                    // User will be prompted to update entities
                    changes.should_mark_stale = true;
                } else if clear_stale {
                    changes.clear_stale = true;
                } else {
                    // It's safe to automatically update entities
                    match entity_event.entity_type {
                        Entity::Host(_) => changes.updated_hosts = true,
                        Entity::Interface(_) => changes.updated_interfaces = true,
                        Entity::Service(_) => changes.updated_services = true,
                        Entity::Subnet(_) => changes.updated_subnets = true,
                        Entity::Group(_) => changes.updated_groups = true,
                        _ => (),
                    };
                }
            }
        }

        // Apply changes to all topologies in affected networks
        for network_id in network_ids {
            let network_filter = StorageFilter::unfiltered().network_ids(&[network_id]);
            let topologies = self.get_all(network_filter).await?;

            let (hosts, interfaces, subnets, groups) = self.get_entity_data(network_id).await?;

            if let Some(changes) = topology_updates.get(&network_id) {
                for mut topology in topologies {
                    let services = self
                        .get_service_data(network_id, &topology.base.options)
                        .await?;

                    // Apply removed entities
                    for host_id in &changes.removed_hosts {
                        if !topology.base.removed_hosts.contains(host_id) {
                            topology.base.removed_hosts.push(*host_id);
                        }
                    }
                    for interface_id in &changes.removed_interfaces {
                        if !topology.base.removed_interfaces.contains(interface_id) {
                            topology.base.removed_interfaces.push(*interface_id);
                        }
                    }
                    for service_id in &changes.removed_services {
                        if !topology.base.removed_services.contains(service_id) {
                            topology.base.removed_services.push(*service_id);
                        }
                    }
                    for subnet_id in &changes.removed_subnets {
                        if !topology.base.removed_subnets.contains(subnet_id) {
                            topology.base.removed_subnets.push(*subnet_id);
                        }
                    }
                    for group_id in &changes.removed_groups {
                        if !topology.base.removed_groups.contains(group_id) {
                            topology.base.removed_groups.push(*group_id);
                        }
                    }

                    // Mark stale if needed
                    if changes.should_mark_stale && !changes.clear_stale {
                        topology.base.is_stale = true;
                    }

                    // Clear stale - this only happens on topology create to avoid a stale state when loading app for the first time
                    if changes.clear_stale {
                        topology.base.is_stale = false;
                    }

                    if changes.updated_hosts {
                        topology.base.hosts = hosts.clone()
                    }

                    if changes.updated_interfaces {
                        topology.base.interfaces = interfaces.clone()
                    }

                    if changes.updated_services {
                        topology.base.services = services
                    }

                    if changes.updated_subnets {
                        topology.base.subnets = subnets.clone()
                    }

                    if changes.updated_groups {
                        topology.base.groups = groups.clone();
                    }

                    // Update topology in database
                    let updated = self
                        .update(&mut topology, AuthenticatedEntity::System)
                        .await?;

                    // Send the UPDATED topology to SSE
                    let _ = self.staleness_tx.send(updated).inspect_err(|e| {
                        tracing::debug!("Staleness notification skipped (no receivers): {}", e)
                    });
                }
            }
        }

        Ok(())
    }

    fn debounce_window_ms(&self) -> u64 {
        200 // Batch events within 200ms window
    }

    fn name(&self) -> &str {
        "topology_stale"
    }
}
