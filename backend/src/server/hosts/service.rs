use crate::server::{
    auth::middleware::AuthenticatedEntity,
    daemons::service::DaemonService,
    hosts::r#impl::base::Host,
    services::{r#impl::base::Service, service::ServiceService},
    shared::{
        entities::Entity,
        events::{
            bus::EventBus,
            types::{EntityEvent, EntityOperation},
        },
        services::traits::CrudService,
        storage::{
            filter::EntityFilter,
            generic::GenericPostgresStorage,
            traits::{StorableEntity, Storage},
        },
        types::entities::{EntitySource, EntitySourceDiscriminants},
    },
};
use anyhow::{Error, Result, anyhow};
use async_trait::async_trait;
use chrono::Utc;
use futures::future::{join_all, try_join_all};
use std::{collections::HashMap, sync::Arc};
use strum::IntoDiscriminant;
use tokio::sync::Mutex;
use uuid::Uuid;

pub struct HostService {
    storage: Arc<GenericPostgresStorage<Host>>,
    service_service: Arc<ServiceService>,
    daemon_service: Arc<DaemonService>,
    host_locks: Arc<Mutex<HashMap<Uuid, Arc<Mutex<()>>>>>,
    event_bus: Arc<EventBus>,
}

#[async_trait]
impl CrudService<Host> for HostService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Host>> {
        &self.storage
    }

    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn entity_type() -> Entity {
        Entity::Host
    }
    fn get_network_id(&self, entity: &Host) -> Option<Uuid> {
        Some(entity.base.network_id)
    }
    fn get_organization_id(&self, _entity: &Host) -> Option<Uuid> {
        None
    }

    /// Create a new host
    async fn create(&self, host: Host, authentication: AuthenticatedEntity) -> Result<Host> {
        // Manually created and needs actual UUID
        let host = if host.id == Uuid::nil() {
            Host::new(host.base.clone())
        } else {
            host
        };

        let lock = self.get_host_lock(&host.id).await;
        let _guard = lock.lock().await;

        tracing::trace!("Creating host {:?}", host);

        let filter = EntityFilter::unfiltered().network_ids(&[host.base.network_id]);
        let all_hosts = self.storage.get_all(filter).await?;

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

                self.upsert_host(existing_host, host, authentication)
                    .await?
            }
            _ => {
                let created = self.storage.create(&host).await?;

                self.event_bus()
                    .publish(EntityEvent {
                        id: Uuid::new_v4(),
                        entity_type: Self::entity_type(),
                        entity_id: created.id(),
                        network_id: self.get_network_id(&created),
                        organization_id: self.get_organization_id(&created),
                        operation: EntityOperation::Created,
                        timestamp: Utc::now(),
                        metadata: serde_json::json!({}),
                        authentication,
                    })
                    .await?;

                tracing::info!(
                    name = %host.base.name,
                    id = %host.id,
                    "Created host"
                );
                tracing::trace!("Result: {:?}", host);
                host
            }
        };

        Ok(host_from_storage)
    }

    async fn update(
        &self,
        host: &mut Host,
        authentication: AuthenticatedEntity,
    ) -> Result<Host, Error> {
        let lock = self.get_host_lock(&host.id).await;
        let _guard = lock.lock().await;

        tracing::trace!("Updating host {:?}", host);

        let current_host = self
            .get_by_id(&host.id)
            .await?
            .ok_or_else(|| anyhow!("Host '{}' not found", host.id))?;

        self.update_host_services(&current_host, host, authentication.clone())
            .await?;

        let updated = self.storage.update(host).await?;

        self.event_bus()
            .publish(EntityEvent {
                id: Uuid::new_v4(),
                entity_type: Self::entity_type(),
                entity_id: updated.id(),
                network_id: self.get_network_id(&updated),
                organization_id: self.get_organization_id(&updated),
                operation: EntityOperation::Updated,
                timestamp: Utc::now(),
                metadata: serde_json::json!({}),
                authentication,
            })
            .await?;

        tracing::info!(
            id = %host.id,
            "Updated host"
        );
        tracing::trace!("Result: {:?}", host);

        Ok(updated)
    }
}

impl HostService {
    pub fn new(
        storage: Arc<GenericPostgresStorage<Host>>,
        service_service: Arc<ServiceService>,
        daemon_service: Arc<DaemonService>,
        event_bus: Arc<EventBus>,
    ) -> Self {
        Self {
            storage,
            service_service,
            daemon_service,
            host_locks: Arc::new(Mutex::new(HashMap::new())),
            event_bus,
        }
    }

    async fn get_host_lock(&self, host_id: &Uuid) -> Arc<Mutex<()>> {
        let mut locks = self.host_locks.lock().await;
        locks
            .entry(*host_id)
            .or_insert_with(|| Arc::new(Mutex::new(())))
            .clone()
    }

    pub async fn create_host_with_services(
        &self,
        host: Host,
        services: Vec<Service>,
        authentication: AuthenticatedEntity,
    ) -> Result<(Host, Vec<Service>)> {
        // Create host first (handles duplicates via upsert_host)
        let mut created_host = self.create(host.clone(), authentication.clone()).await?;

        // Create services, handling case where created_host was upserted instead of created anew (ie during discovery), which means that host ID + interfaces/port IDs
        // are different from what's mapped to the service and they need to be updated
        let transfer_service_futures = services.into_iter().map(|service| {
            self.service_service
                .reassign_service_interface_bindings(service, &host, &created_host)
        });

        let transferred_services = join_all(transfer_service_futures).await;

        let create_service_futures: Vec<_> = transferred_services
            .into_iter()
            .map(|s| self.service_service.create(s, authentication.clone()))
            .collect();

        let created_services = try_join_all(create_service_futures).await?;

        // Add all successfully created/found services to the host
        for service in &created_services {
            if !created_host.base.services.contains(&service.id) {
                created_host.base.services.push(service.id);
            }
        }

        // Now we need to update just the service IDs, without triggering
        // the deletion logic in update_host_services
        // Since bindings were already reassigned above, we just update the host record
        let host_with_final_services = self.storage.update(&mut created_host).await?;

        tracing::info!(
            host_id = %created_host.id,
            host_name = %created_host.base.name,
            service_count = %created_services.len(),
            "Created host with services"
        );

        Ok((host_with_final_services, created_services))
    }

    /// Merge new discovery data with existing host
    async fn upsert_host(
        &self,
        mut existing_host: Host,
        new_host_data: Host,
        authentication: AuthenticatedEntity,
    ) -> Result<Host> {
        let mut interface_updates = 0;
        let mut port_updates = 0;
        let mut hostname_update = false;
        let mut description_update = false;

        tracing::trace!(
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

        // Update the existing host
        self.storage.update(&mut existing_host).await?;
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
            self.event_bus()
                .publish(EntityEvent {
                    id: Uuid::new_v4(),
                    entity_type: Self::entity_type(),
                    entity_id: existing_host.id(),
                    network_id: self.get_network_id(&existing_host),
                    organization_id: self.get_organization_id(&existing_host),
                    operation: EntityOperation::Updated,
                    timestamp: Utc::now(),
                    metadata: serde_json::json!({}),
                    authentication,
                })
                .await?;

            tracing::info!(
                host_id = %existing_host.id,
                host_name = %existing_host.base.name,
                updates = %data.join(", "),
                "Upserted discovery data to host"
            );
            tracing::trace!("Result: {:?}", existing_host);
        } else {
            tracing::debug!(
                "No new data to upsert from host {} to {}",
                new_host_data.base.name,
                existing_host.base.name
            );
        }

        Ok(existing_host)
    }

    pub async fn consolidate_hosts(
        &self,
        destination_host: Host,
        other_host: Host,
        authentication: AuthenticatedEntity,
    ) -> Result<Host> {
        if destination_host.id == other_host.id {
            return Err(anyhow!("Can't consolidate a host with itself"));
        }

        let lock = self.get_host_lock(&destination_host.id).await;
        let _guard1 = lock.lock().await;

        tracing::trace!(
            "Consolidating host {:?} into host {:?}",
            other_host,
            destination_host
        );

        let destination_host_filter = EntityFilter::unfiltered().host_id(&destination_host.id);
        let other_host_filter = EntityFilter::unfiltered().host_id(&other_host.id);

        let destination_host_services = self
            .service_service
            .get_all(destination_host_filter)
            .await?;

        let other_host_services = self.service_service.get_all(other_host_filter).await?;

        let host_filter = EntityFilter::unfiltered().host_id(&other_host.id);
        let other_host_daemon = self.daemon_service.get_one(host_filter).await?;

        if let Some(mut other_host_daemon) = other_host_daemon {
            other_host_daemon.base.host_id = destination_host.id;
            self.daemon_service
                .update(&mut other_host_daemon, authentication.clone())
                .await?;
        }

        // Add bindings, interfaces, sources from old host to new
        let updated_host = self
            .upsert_host(
                destination_host.clone(),
                other_host.clone(),
                authentication.clone(),
            )
            .await?;

        // Update host_id, network_id, and interface/port binding IDs to what's available on new host
        // bindings IDs from old host may no longer exist if new host already had the port / interface
        let service_transfer_futures: Vec<_> = other_host_services
            .clone()
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

        // First, execute updates sequentially
        for prepped_service in &prepped_for_transfer_services {
            if !destination_host_services
                .iter()
                .any(|s| s == prepped_service)
            {
                let mut owned_service = prepped_service.clone();
                self.service_service
                    .update(&mut owned_service, authentication.clone())
                    .await?;
            }
        }

        // Then collect upsert/delete futures for concurrent execution
        let (upsert_futures, delete_futures): (Vec<_>, Vec<_>) = prepped_for_transfer_services
            .iter()
            .filter_map(|prepped_service| {
                destination_host_services
                    .iter()
                    .find(|s| *s == prepped_service)
                    .map(|existing_service| {
                        (
                            self.service_service.upsert_service(
                                existing_service.clone(),
                                prepped_service.clone(),
                                authentication.clone(),
                            ),
                            self.service_service
                                .delete(&prepped_service.id, authentication.clone()),
                        )
                    })
            })
            .unzip();

        // Execute upsert/delete concurrently
        let (_, _) = tokio::join!(
            futures::future::join_all(upsert_futures),
            futures::future::join_all(delete_futures),
        );

        // Delete host, ignore services because they are just being moved to other host
        self.delete_host(&other_host.id, false, authentication)
            .await?;
        tracing::info!(
            source_host_id = %other_host.id,
            source_host_name = %other_host.base.name,
            dest_host_id = %updated_host.id,
            dest_host_name = %updated_host.base.name,
            transferred_services = %other_host_services.len(),
            "Hosts consolidated"
        );
        tracing::trace!("Consolidation result: {:?}", updated_host);
        Ok(updated_host)
    }

    async fn update_host_services(
        &self,
        current_host: &Host,
        updates: &Host,
        authentication: AuthenticatedEntity,
    ) -> Result<(), Error> {
        let host_filter = EntityFilter::unfiltered().host_id(&current_host.id);

        let services = self.service_service.get_all(host_filter).await?;

        tracing::trace!(
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
            .map(|s| self.service_service.delete(&s.id, authentication.clone()));

        try_join_all(delete_service_futures).await?;

        let update_service_futures = update_services.into_iter().map(|service| {
            let service_service = self.service_service.clone();
            let current_host = current_host.clone();
            let updates = updates.clone();
            let authentication = authentication.clone();
            async move {
                let mut updated = service_service
                    .reassign_service_interface_bindings(service, &current_host, &updates)
                    .await;
                service_service.update(&mut updated, authentication).await
            }
        });

        let updated_services = try_join_all(update_service_futures).await?;

        tracing::info!(
            host_id = %current_host.id,
            host_name = %current_host.base.name,
            updated_services = %updated_services.len(),
            deleted_services = %delete_services.len(),
            "Host services updated"
        );
        tracing::trace!(
            "Full update - host: {:?}, updated: {:?}, deleted: {:?}",
            updates,
            updated_services,
            delete_services
        );

        Ok(())
    }

    pub async fn delete_host(
        &self,
        id: &Uuid,
        delete_services: bool,
        authentication: AuthenticatedEntity,
    ) -> Result<()> {
        let host_filter = EntityFilter::unfiltered().host_id(id);
        if self.daemon_service.get_one(host_filter).await?.is_some() {
            return Err(anyhow!(
                "Can't delete a host with an associated daemon. Delete the daemon first."
            ));
        }

        let host = self
            .get_by_id(id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Host {} not found", id))?;

        let lock = self.get_host_lock(id).await;
        let _guard = lock.lock().await;

        if delete_services {
            for service_id in &host.base.services {
                let _ = self
                    .service_service
                    .delete(service_id, authentication.clone())
                    .await;
            }
        }

        self.storage.delete(id).await?;

        self.event_bus()
            .publish(EntityEvent {
                id: Uuid::new_v4(),
                entity_type: Self::entity_type(),
                entity_id: host.id(),
                network_id: self.get_network_id(&host),
                organization_id: self.get_organization_id(&host),
                operation: EntityOperation::Deleted,
                timestamp: Utc::now(),
                metadata: serde_json::json!({}),
                authentication,
            })
            .await?;

        tracing::info!(
            host_id = %host.id,
            host_name = %host.base.name,
            service_count = %host.base.services.len(),
            deleted_services = %delete_services,
            "Host deleted"
        );
        Ok(())
    }
}
