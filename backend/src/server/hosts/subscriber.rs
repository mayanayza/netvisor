use std::collections::HashMap;

use anyhow::Error;
use async_trait::async_trait;

use crate::server::{
    auth::middleware::AuthenticatedEntity,
    hosts::service::HostService,
    shared::{
        entities::EntityDiscriminants,
        events::{
            bus::{EventFilter, EventSubscriber},
            types::{EntityOperation, Event},
        },
        services::traits::CrudService,
        storage::filter::EntityFilter,
    },
};

#[async_trait]
impl EventSubscriber for HostService {
    fn event_filter(&self) -> EventFilter {
        EventFilter::entity_only(HashMap::from([(
            EntityDiscriminants::Subnet,
            Some(vec![EntityOperation::Deleted]),
        )]))
    }

    async fn handle_events(&self, events: Vec<Event>) -> Result<(), Error> {
        if events.is_empty() {
            return Ok(());
        }

        // Collect all deleted subnet IDs and affected network IDs
        let mut deleted_subnets = std::collections::HashSet::new();
        let mut network_ids = std::collections::HashSet::new();

        for event in events {
            if let Event::Entity(entity_event) = event {
                deleted_subnets.insert(entity_event.entity_id);
                if let Some(network_id) = entity_event.network_id {
                    network_ids.insert(network_id);
                }

                tracing::debug!(
                    entity_type = %entity_event.entity_type,
                    entity_operation = %entity_event.operation,
                    subnet_id = %entity_event.entity_id,
                    "Host subscriber handling subnet deletion event",
                );
            }
        }

        // Process all affected networks
        for network_id in network_ids {
            let filter = EntityFilter::unfiltered().network_ids(&[network_id]);
            let hosts = self.get_all(filter).await?;

            let mut updated_count = 0;

            for mut host in hosts {
                // Check if host has interfaces referencing any deleted subnet
                let has_deleted_subnet = host
                    .base
                    .interfaces
                    .iter()
                    .any(|i| deleted_subnets.contains(&i.base.subnet_id));

                if has_deleted_subnet {
                    // Remove interfaces for all deleted subnets in this batch
                    host.base.interfaces = host
                        .base
                        .interfaces
                        .iter()
                        .filter(|i| !deleted_subnets.contains(&i.base.subnet_id))
                        .cloned()
                        .collect();

                    self.update(&mut host, AuthenticatedEntity::System).await?;
                    updated_count += 1;
                }
            }

            if updated_count > 0 {
                tracing::info!(
                    deleted_subnets = deleted_subnets.len(),
                    affected_hosts = updated_count,
                    network_id = %network_id,
                    "Cleaned up host interfaces referencing deleted subnets"
                );
            }
        }

        Ok(())
    }

    fn debounce_window_ms(&self) -> u64 {
        50 // Small window to batch bulk subnet deletions
    }

    fn name(&self) -> &str {
        "subnet_deleted_interface_removal"
    }
}
