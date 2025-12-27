use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    discovery::r#impl::types::DiscoveryType,
    shared::{
        entities::ChangeTriggersTopologyStaleness,
        events::{
            bus::EventBus,
            types::{EntityEvent, EntityOperation},
        },
        services::traits::{CrudService, EventBusService},
        storage::{
            filter::EntityFilter,
            generic::GenericPostgresStorage,
            traits::{StorableEntity, Storage},
        },
        types::entities::EntitySource,
    },
    subnets::r#impl::base::Subnet,
};
use anyhow::Result;
use async_trait::async_trait;
use chrono::Utc;
use std::sync::Arc;
use uuid::Uuid;

pub struct SubnetService {
    storage: Arc<GenericPostgresStorage<Subnet>>,
    event_bus: Arc<EventBus>,
}

impl EventBusService<Subnet> for SubnetService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, entity: &Subnet) -> Option<Uuid> {
        Some(entity.base.network_id)
    }
    fn get_organization_id(&self, _entity: &Subnet) -> Option<Uuid> {
        None
    }
}

#[async_trait]
impl CrudService<Subnet> for SubnetService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Subnet>> {
        &self.storage
    }

    async fn create(
        &self,
        subnet: Subnet,
        authentication: AuthenticatedEntity,
    ) -> Result<Subnet, anyhow::Error> {
        let filter = EntityFilter::unfiltered().network_ids(&[subnet.base.network_id]);
        let all_subnets = self.storage.get_all(filter).await?;

        let subnet = if subnet.id == Uuid::nil() {
            Subnet::new(subnet.base)
        } else {
            subnet
        };

        tracing::debug!(
            subnet_id = %subnet.id,
            subnet_name = %subnet.base.name,
            subnet_cidr = %subnet.base.cidr,
            network_id = %subnet.base.network_id,
            "Creating subnet"
        );

        let subnet_from_storage = match all_subnets.iter().find(|s| subnet.eq(s)) {
            // Docker will default to the same subnet range for bridge networks, so we need a way to distinguish docker bridge subnets
            // with the same CIDR but which originate from different hosts

            // This branch returns the existing subnet for docker bridge subnets created from the same host
            // And the same subnet for all other sources provided CIDRs match
            Some(existing_subnet)
                if {
                    match (&existing_subnet.base.source, &subnet.base.source) {
                        (
                            EntitySource::Discovery {
                                metadata: existing_metadata,
                            },
                            EntitySource::Discovery { metadata },
                        ) => {
                            // Only one metadata entry will be present for subnet which is trying to be created bc it is brand new / just discovered
                            if let Some(metadata) = metadata.first() {
                                existing_metadata.iter().any(|other_m| {
                                    match (&metadata.discovery_type, &other_m.discovery_type) {
                                        // For Docker, only return existing if they originate from the same host
                                        // If not from the same host, they can have the same CIDR without being considered a collision
                                        // so create a new subnet rather than returning the existing
                                        (
                                            DiscoveryType::Docker { host_id, .. },
                                            DiscoveryType::Docker {
                                                host_id: other_host_id,
                                                ..
                                            },
                                        ) => host_id == other_host_id,
                                        // Always return existing for other types
                                        _ => true,
                                    }
                                })
                            } else {
                                return Err(anyhow::anyhow!(
                                    "Error comparing discovered subnets during creation: subnet missing discovery metadata"
                                ));
                            }
                        }
                        // System subnets are never going to be upserted to or from
                        (EntitySource::System, _) | (_, EntitySource::System) => false,
                        _ => true,
                    }
                } =>
            {
                tracing::info!(
                    existing_subnet_id = %existing_subnet.id,
                    existing_subnet_name = %existing_subnet.base.name,
                    new_subnet_id = %subnet.id,
                    new_subnet_name = %subnet.base.name,
                    subnet_cidr = %subnet.base.cidr,
                    "Duplicate subnet found, returning existing"
                );
                existing_subnet.clone()
            }
            // If there's no existing subnet, create a new one
            _ => {
                let created = self.storage.create(&subnet).await?;

                let trigger_stale = created.triggers_staleness(None);

                self.event_bus()
                    .publish_entity(EntityEvent {
                        id: Uuid::new_v4(),
                        entity_id: created.id,
                        network_id: self.get_network_id(&created),
                        organization_id: self.get_organization_id(&created),
                        entity_type: created.into(),
                        operation: EntityOperation::Created,
                        timestamp: Utc::now(),
                        metadata: serde_json::json!({
                            "trigger_stale": trigger_stale
                        }),
                        authentication,
                    })
                    .await?;

                subnet
            }
        };
        Ok(subnet_from_storage)
    }
}

impl SubnetService {
    pub fn new(storage: Arc<GenericPostgresStorage<Subnet>>, event_bus: Arc<EventBus>) -> Self {
        Self { storage, event_bus }
    }
}
