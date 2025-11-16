use crate::server::{
    discovery::r#impl::types::DiscoveryType,
    hosts::service::HostService,
    shared::{
        services::traits::CrudService,
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
use futures::future::try_join_all;
use std::sync::Arc;
use uuid::Uuid;

pub struct SubnetService {
    storage: Arc<GenericPostgresStorage<Subnet>>,
    host_service: Arc<HostService>,
}

#[async_trait]
impl CrudService<Subnet> for SubnetService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Subnet>> {
        &self.storage
    }

    async fn create(&self, subnet: Subnet) -> Result<Subnet, anyhow::Error> {
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
                                        // Only return existing if they originate from the same host
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
                tracing::warn!(
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
                self.storage.create(&subnet).await?;
                tracing::info!(
                    subnet_id = %subnet.id,
                    subnet_name = %subnet.base.name,
                    subnet_cidr = %subnet.base.cidr,
                    network_id = %subnet.base.network_id,
                    "Subnet created"
                );
                subnet
            }
        };
        Ok(subnet_from_storage)
    }

    async fn delete(&self, id: &Uuid) -> Result<()> {
        let subnet = self
            .get_by_id(id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Subnet not found"))?;

        tracing::info!(
            subnet_id = %subnet.id,
            subnet_name = %subnet.base.name,
            subnet_cidr = %subnet.base.cidr,
            "Deleting subnet"
        );

        let filter = EntityFilter::unfiltered().network_ids(&[subnet.base.network_id]);

        let hosts = self.host_service.get_all(filter).await?;
        let update_futures = hosts.into_iter().filter_map(|mut host| {
            let has_subnet = host.base.interfaces.iter().any(|i| &i.base.subnet_id == id);
            if has_subnet {
                host.base.interfaces = host
                    .base
                    .interfaces
                    .iter()
                    .filter(|i| &i.base.subnet_id != id)
                    .cloned()
                    .collect();
                return Some(self.host_service.update_host(host));
            }
            None
        });

        let updated_hosts = try_join_all(update_futures).await?;

        tracing::debug!(
            subnet_id = %subnet.id,
            affected_hosts = %updated_hosts.len(),
            "Cleaned up host interfaces referencing subnet"
        );

        self.storage.delete(id).await?;
        tracing::info!(
            subnet_id = %subnet.id,
            subnet_name = %subnet.base.name,
            affected_hosts = %updated_hosts.len(),
            "Subnet deleted"
        );
        Ok(())
    }
}

impl SubnetService {
    pub fn new(
        storage: Arc<GenericPostgresStorage<Subnet>>,
        host_service: Arc<HostService>,
    ) -> Self {
        Self {
            storage,
            host_service,
        }
    }
}
