use crate::server::{
    discovery::types::base::{DiscoveryType, EntitySource},
    hosts::service::HostService,
    subnets::{storage::SubnetStorage, types::base::Subnet},
};
use anyhow::Result;
use futures::future::try_join_all;
use std::sync::Arc;
use uuid::Uuid;

pub struct SubnetService {
    storage: Arc<dyn SubnetStorage>,
    host_service: Arc<HostService>,
}

impl SubnetService {
    pub fn new(storage: Arc<dyn SubnetStorage>, host_service: Arc<HostService>) -> Self {
        Self {
            storage,
            host_service,
        }
    }

    /// Create a new subnet
    pub async fn create_subnet(&self, subnet: Subnet) -> Result<Subnet> {
        let all_subnets = self.storage.get_all(&vec!(subnet.base.network_id)).await?;

        let subnet = if subnet.id == Uuid::nil() {
            Subnet::new(subnet.base)
        } else {
            subnet
        };

        tracing::debug!("Creating subnet {:?}", subnet);

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
                                    match (metadata.discovery_type, other_m.discovery_type) {
                                        // Only return existing if they originate from the same host
                                        (
                                            DiscoveryType::Docker { host_id },
                                            DiscoveryType::Docker {
                                                host_id: other_host_id,
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
                    "Duplicate subnet for {}: {} found, returning existing {}: {}",
                    subnet.base.name,
                    subnet.id,
                    existing_subnet.base.name,
                    existing_subnet.id
                );
                existing_subnet.clone()
            }
            // If there's no existing subnet, create a new one
            _ => {
                self.storage.create(&subnet).await?;
                tracing::info!("Created subnet {}: {}", subnet.base.name, subnet.id);
                subnet
            }
        };
        Ok(subnet_from_storage)
    }

    pub async fn get_subnet(&self, id: &Uuid) -> Result<Option<Subnet>> {
        self.storage.get_by_id(id).await
    }

    pub async fn get_by_ids(&self, ids: &[Uuid]) -> Result<Vec<Subnet>> {
        self.storage.get_by_ids(ids).await
    }

    pub async fn get_all_subnets(&self, network_ids: &[Uuid]) -> Result<Vec<Subnet>> {
        self.storage.get_all(network_ids).await
    }

    pub async fn update_subnet(&self, mut subnet: Subnet) -> Result<Subnet> {
        subnet.updated_at = chrono::Utc::now();
        self.storage.update(&subnet).await?;
        tracing::info!("Updated subnet {}: {}", subnet.base.name, subnet.id);
        Ok(subnet)
    }

    pub async fn delete_subnet(&self, id: &Uuid) -> Result<()> {
        let subnet = self
            .get_subnet(id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Subnet not found"))?;

        let hosts = self
            .host_service
            .get_all_hosts(&vec!(subnet.base.network_id))
            .await?;
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

        try_join_all(update_futures).await?;

        self.storage.delete(id).await?;
        tracing::info!("Deleted subnet {}: {}", subnet.base.name, subnet.id);
        Ok(())
    }
}
