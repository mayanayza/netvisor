use crate::server::{
    daemons::service::DaemonService,
    discovery::types::base::{EntitySource, EntitySourceDiscriminants},
    hosts::{storage::HostStorage, types::base::Host},
    services::{service::ServiceService, types::base::Service},
};
use anyhow::{Error, Result, anyhow};
use futures::future::{join_all, try_join_all};
use itertools::{Either, Itertools};
use std::{collections::HashMap, sync::Arc};
use strum::IntoDiscriminant;
use tokio::sync::Mutex;
use uuid::Uuid;

pub struct HostService {
    storage: Arc<dyn HostStorage>,
    service_service: Arc<ServiceService>,
    daemon_service: Arc<DaemonService>,
    host_locks: Arc<Mutex<HashMap<Uuid, Arc<Mutex<()>>>>>,
}

impl HostService {
    pub fn new(
        storage: Arc<dyn HostStorage>,
        service_service: Arc<ServiceService>,
        daemon_service: Arc<DaemonService>,
    ) -> Self {
        Self {
            storage,
            service_service,
            daemon_service,
            host_locks: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    async fn get_host_lock(&self, host_id: &Uuid) -> Arc<Mutex<()>> {
        let mut locks = self.host_locks.lock().await;
        locks
            .entry(*host_id)
            .or_insert_with(|| Arc::new(Mutex::new(())))
            .clone()
    }

    pub async fn get_host(&self, id: &Uuid) -> Result<Option<Host>> {
        self.storage.get_by_id(id).await
    }

    pub async fn get_all_hosts(&self, network_ids: &[Uuid]) -> Result<Vec<Host>> {
        self.storage.get_all(network_ids).await
    }

    pub async fn create_host_with_services(
        &self,
        host: Host,
        services: Vec<Service>,
    ) -> Result<(Host, Vec<Service>)> {
        // Create host first (handles duplicates via upsert_host)
        let mut created_host = self.create_host(host.clone()).await?;

        // Create services, handling case where created_host was upserted instead of created anew (ie during discovery), which means that host ID + interfaces/port IDs
        // are different from what's mapped to the service and they need to be updated
        let transfer_service_futures = services.into_iter().map(|service| {
            self.service_service
                .reassign_service_interface_bindings(service, &host, &created_host)
        });

        let transferred_services = join_all(transfer_service_futures).await;

        let create_service_futures: Vec<_> = transferred_services
            .into_iter()
            .map(|s| self.service_service.create_service(s))
            .collect();

        let created_services = try_join_all(create_service_futures).await?;

        // Add all successfully created/found services to the host
        for service in &created_services {
            if !created_host.base.services.contains(&service.id) {
                created_host.base.services.push(service.id);
            }
        }

        let host_with_final_services = self.update_host(created_host).await?;

        Ok((host_with_final_services, created_services))
    }

    /// Create a new host
    pub async fn create_host(&self, host: Host) -> Result<Host> {

        // Manually created and needs actual UUID
        let host = if host.id == Uuid::nil() {
            Host::new(host.base.clone())
        } else {
            host
        };

        let lock = self.get_host_lock(&host.id).await;
        let _guard = lock.lock().await;

        tracing::debug!("Creating host {:?}", host);

        let all_hosts = self.storage.get_all(&[host.base.network_id]).await?;

        let host_from_storage = match all_hosts.into_iter().find(|h| host.eq(h)) {
            // If both are from discovery, or if they have the same ID, upsert data
            Some(existing_host)
                if (host.base.source.discriminant() == EntitySourceDiscriminants::Discovery
                    && existing_host.base.source.discriminant()
                        == EntitySourceDiscriminants::Discovery)
                    || host.id == existing_host.id =>
            {
                tracing::warn!(
                    "Duplicate host for {}: {} found, {}: {} - upserting discovery data...",
                    host.base.name,
                    host.id,
                    existing_host.base.name,
                    existing_host.id
                );

                self.upsert_host(existing_host, host).await?
            }
            _ => {
                self.storage.create(&host).await?;
                tracing::info!("Created host {}: {}", host.base.name, host.id);
                tracing::debug!("Result: {:?}", host);
                host
            }
        };

        Ok(host_from_storage)
    }

    pub async fn update_host(&self, mut host: Host) -> Result<Host, Error> {
        let lock = self.get_host_lock(&host.id).await;
        let _guard = lock.lock().await;

        tracing::debug!("Updating host {:?}", host);

        let current_host = self
            .get_host(&host.id)
            .await?
            .ok_or_else(|| anyhow!("Host '{}' not found", host.id))?;

        self.update_host_services(&current_host, &host).await?;

        host.updated_at = chrono::Utc::now();

        self.storage.update(&host).await?;

        tracing::info!("Updated host {:?}: {:?}", host.base.name, host.id);
        tracing::debug!("Result: {:?}", host);

        Ok(host)
    }

    /// Merge new discovery data with existing host
    async fn upsert_host(&self, mut existing_host: Host, new_host_data: Host) -> Result<Host> {
        let mut interface_updates = 0;
        let mut port_updates = 0;
        let mut hostname_update = false;
        let mut description_update = false;

        tracing::debug!(
            "Upserting new host data {:?} to host {:?}",
            new_host_data,
            existing_host
        );

        // Merge interfaces - add any new interfaces not already present
        for new_host_data_interface in new_host_data.base.interfaces {
            if !existing_host
                .base
                .interfaces
                .contains(&new_host_data_interface)
            {
                interface_updates += 1;
                existing_host.base.interfaces.push(new_host_data_interface);
            }
        }

        // Merge open ports - add any new ports not already present
        for new_port in new_host_data.base.ports {
            if !existing_host.base.ports.contains(&new_port) {
                port_updates += 1;
                existing_host.base.ports.push(new_port);
            }
        }

        existing_host.base.services =
            [existing_host.base.services, new_host_data.base.services].concat();

        // Update other fields if they have more information
        if existing_host.base.hostname.is_none() && new_host_data.base.hostname.is_some() {
            hostname_update = true;
            existing_host.base.hostname = new_host_data.base.hostname;
        }

        if existing_host.base.description.is_none() && new_host_data.base.description.is_some() {
            description_update = true;
            existing_host.base.description = new_host_data.base.description;
        }

        // Update entity source for new discovery session data
        existing_host.base.source = match (existing_host.base.source, new_host_data.base.source) {
            (
                EntitySource::Discovery {
                    metadata: existing_metadata,
                },
                EntitySource::Discovery {
                    metadata: new_metadata,
                },
            ) => EntitySource::Discovery {
                metadata: [new_metadata, existing_metadata].concat(),
            },
            (
                _,
                EntitySource::Discovery {
                    metadata: new_metadata,
                },
            ) => EntitySource::Discovery {
                metadata: new_metadata,
            },
            (
                EntitySource::Discovery {
                    metadata: existing_metadata,
                },
                _,
            ) => EntitySource::Discovery {
                metadata: existing_metadata,
            },
            (existing_source, _) => existing_source,
        };

        existing_host.updated_at = chrono::Utc::now();

        // Update the existing host
        self.storage.update(&existing_host).await?;
        let mut data = Vec::new();

        if port_updates > 0 {
            data.push(format!("{} ports", port_updates))
        };
        if interface_updates > 0 {
            data.push(format!("{} interfaces", interface_updates))
        };
        if hostname_update {
            data.push("new hostname".to_string())
        }
        if description_update {
            data.push("new description".to_string())
        }

        if !data.is_empty() {
            tracing::info!(
                "Upserted new discovery data: {} to host {}: {}",
                existing_host.base.name,
                existing_host.id,
                data.join(", ")
            );
            tracing::debug!("Result: {:?}", existing_host);
        } else {
            tracing::info!(
                "No new information to upsert from host {} to host {}: {}",
                new_host_data.base.name,
                existing_host.base.name,
                existing_host.id
            );
        }

        Ok(existing_host)
    }

    pub async fn consolidate_hosts(
        &self,
        destination_host: Host,
        other_host: Host,
    ) -> Result<Host> {
        if destination_host.id == other_host.id {
            return Err(anyhow!("Can't consolidate a host with itself"));
        }

        if self
            .daemon_service
            .get_host_daemon(&other_host.id)
            .await?
            .is_some()
        {
            return Err(anyhow!(
                "Can't consolidate a host with an associated daemon. Delete the daemon first."
            ));
        }

        let lock = self.get_host_lock(&destination_host.id).await;
        let _guard1 = lock.lock().await;

        tracing::debug!(
            "Consolidating host {:?} into host {:?}",
            other_host,
            destination_host
        );

        let destination_host_services = self
            .service_service
            .get_services_for_host(&destination_host.id)
            .await?;

        let other_host_services = self
            .service_service
            .get_services_for_host(&other_host.id)
            .await?;

        let other_host_daemon = self.daemon_service.get_host_daemon(&other_host.id).await?;

        if let Some(mut other_host_daemon) = other_host_daemon {
            other_host_daemon.base.host_id = destination_host.id;
            self.daemon_service.update_daemon(other_host_daemon).await?;
        }

        // Add bindings, interfaces, sources from old host to new
        let updated_host = self
            .upsert_host(destination_host.clone(), other_host.clone())
            .await?;

        // Update host_id, network_id, and interface/port binding IDs to what's available on new host
        // bindings IDs from old host may no longer exist if new host already had the port / interface
        let service_transfer_futures: Vec<_> = other_host_services
            .into_iter()
            .map(|s| {
                self.service_service.reassign_service_interface_bindings(
                    s,
                    &other_host,
                    &updated_host,
                )
            })
            .collect();

        let prepped_for_transfer_services: Vec<Service> = join_all(service_transfer_futures).await;

        let ((upsert_futures, delete_futures), update_futures): ((Vec<_>, Vec<_>), Vec<_>) =
            prepped_for_transfer_services
                .iter()
                .partition_map(|prepped_service| {
                    // If there's an existing service on the host, upsert the transferred service so to avoid duplicates
                    // If not, just update the transferred service
                    if let Some(existing_service) = destination_host_services
                        .iter()
                        .find(|s| *s == prepped_service)
                    {
                        Either::Left((
                            self.service_service
                                .upsert_service(existing_service.clone(), prepped_service.clone()),
                            self.service_service.delete_service(&prepped_service.id),
                        ))
                    } else {
                        Either::Right(self.service_service.update_service(prepped_service.clone()))
                    }
                });

        // Save the updated services to DB
        let _upserted_services = try_join_all(upsert_futures).await?;
        let _deleted_services = try_join_all(delete_futures).await?;
        let _updated_services = try_join_all(update_futures).await?;

        // Delete host, ignore services because they are just being moved to other host
        self.delete_host(&other_host.id, false).await?;
        tracing::info!("Consolidated host {} into {}", other_host, updated_host);
        tracing::debug!("Result: {:?}", updated_host);
        Ok(updated_host)
    }

    async fn update_host_services(&self, current_host: &Host, updates: &Host) -> Result<(), Error> {
        let services = self
            .service_service
            .get_services_for_host(&current_host.id)
            .await?;

        tracing::debug!(
            "Updating host {:?} services {:?} due to host updates: {:?}",
            current_host,
            services,
            updates
        );

        let (update_services, delete_services): (Vec<Service>, Vec<Service>) = services
            .into_iter()
            .partition(|s| updates.base.services.contains(&s.id));

        let delete_service_futures = delete_services
            .iter()
            .map(|s| self.service_service.delete_service(&s.id));

        try_join_all(delete_service_futures).await?;

        let update_service_futures = update_services.into_iter().map(|service| {
            let service_service = self.service_service.clone();
            let current_host = current_host.clone();
            let updates = updates.clone();
            async move {
                let updated = service_service
                    .reassign_service_interface_bindings(service, &current_host, &updates)
                    .await;
                service_service.update_service(updated).await
            }
        });

        let updated_services = try_join_all(update_service_futures).await?;

        tracing::info!("Updated host {} services", updates);
        tracing::debug!(
            "Result - host: {:?}, updated services: {:?}, deleted services: {:?}",
            updates,
            updated_services,
            delete_services
        );

        Ok(())
    }

    pub async fn delete_host(&self, id: &Uuid, delete_services: bool) -> Result<()> {
        if self.daemon_service.get_host_daemon(id).await?.is_some() {
            return Err(anyhow!(
                "Can't delete a host with an associated daemon. Delete the daemon first."
            ));
        }

        let host = self
            .get_host(id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Host {} not found", id))?;

        let lock = self.get_host_lock(id).await;
        let _guard = lock.lock().await;

        if delete_services {
            for service_id in &host.base.services {
                let _ = self.service_service.delete_service(service_id).await;
            }
        }

        self.storage.delete(id).await?;
        tracing::info!(
            "Deleted host {}: {}; deleted service + associated subnet/group bindings: {}",
            host.base.name,
            host.id,
            !delete_services
        );
        Ok(())
    }
}
