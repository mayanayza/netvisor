use std::collections::HashMap;

use anyhow::Error;
use async_trait::async_trait;

use crate::server::{
    auth::middleware::AuthenticatedEntity,
    shared::{
        entities::Entity,
        events::{
            bus::{EventFilter, EventSubscriber},
            types::{EntityEvent, EntityOperation},
        },
        services::traits::CrudService,
        storage::filter::EntityFilter,
    },
    topology::service::main::TopologyService,
};

#[async_trait]
impl EventSubscriber for TopologyService {
    fn event_filter(&self) -> EventFilter {
        EventFilter {
            entity_operations: Some(HashMap::from([
                (Entity::Host, None),
                (Entity::Service, None),
                (Entity::Subnet, None),
                (Entity::Group, None),
            ])),
            network_ids: None, // All networks
        }
    }

    async fn handle_event(&self, event: &EntityEvent) -> Result<(), Error> {
        if let Some(network_id) = event.network_id {
            tracing::debug!(
                "Topology validation subscriber handling {} event for {}",
                event.operation,
                event.entity_type
            );
            let network_filter = EntityFilter::unfiltered().network_ids(&[network_id]);

            let topologies = self.get_all(network_filter).await?;

            for mut topology in topologies {
                if !topology.base.is_locked {
                    // Track removed entities for staleness alerts
                    if event.operation == EntityOperation::Deleted {
                        match event.entity_type {
                            Entity::Host => {
                                topology.base.removed_hosts = {
                                    topology.base.removed_hosts.push(event.entity_id);
                                    topology.base.removed_hosts
                                }
                            }
                            Entity::Service => {
                                topology.base.removed_services = {
                                    topology.base.removed_services.push(event.entity_id);
                                    topology.base.removed_services
                                }
                            }
                            Entity::Subnet => {
                                topology.base.removed_subnets = {
                                    topology.base.removed_subnets.push(event.entity_id);
                                    topology.base.removed_subnets
                                }
                            }
                            Entity::Group => {
                                topology.base.removed_groups = {
                                    topology.base.removed_groups.push(event.entity_id);
                                    topology.base.removed_groups
                                }
                            }
                            _ => (),
                        }
                    }

                    topology.base.is_stale = true;
                    self.update(&mut topology, AuthenticatedEntity::System)
                        .await?;
                }
            }
        } else {
            tracing::warn!(
                entity_type = %event.entity_type,
                operation = %event.operation,
                "Topology validation subscriber received event with no network_id",
            );
        }

        Ok(())
    }

    fn name(&self) -> &str {
        "topology_validation"
    }
}
