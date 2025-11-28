use serial_test::serial;

use crate::{
    server::{
        auth::middleware::auth::AuthenticatedEntity,
        services::r#impl::bindings::Binding,
        shared::{
            services::traits::CrudService,
            storage::{filter::EntityFilter, traits::Storage},
            types::entities::{DiscoveryMetadata, EntitySource},
        },
    },
    tests::*,
};

#[tokio::test]
#[serial]
async fn test_host_deduplication_on_create() {
    let (storage, services, _container) = test_services().await;

    let organization = services
        .organization_service
        .create(organization(), AuthenticatedEntity::System)
        .await
        .unwrap();
    let network = services
        .network_service
        .create(network(&organization.id), AuthenticatedEntity::System)
        .await
        .unwrap();

    let filter = EntityFilter::unfiltered().network_ids(&[network.id]);

    let start_host_count = storage.hosts.get_all(filter.clone()).await.unwrap().len();

    // Create first host
    let mut host1 = host(&network.id);
    host1.base.source = EntitySource::Discovery {
        metadata: vec![DiscoveryMetadata::default()],
    };
    let (created1, _) = services
        .host_service
        .create_host_with_services(host1.clone(), vec![], AuthenticatedEntity::System)
        .await
        .unwrap();

    // Try to create duplicate (same interfaces)
    let mut host2 = host(&network.id);
    host2.base.source = EntitySource::Discovery {
        metadata: vec![DiscoveryMetadata::default()],
    };
    let (created2, _) = services
        .host_service
        .create_host_with_services(host2.clone(), vec![], AuthenticatedEntity::System)
        .await
        .unwrap();

    // Should return same host (upserted)
    assert_eq!(created1.id, created2.id);

    // Verify only one host in DB
    let end_host_count = storage.hosts.get_all(filter).await.unwrap().len();
    assert_eq!(start_host_count + 1, end_host_count);
}

#[tokio::test]
#[serial]
async fn test_host_upsert_merges_new_data() {
    let (_, services, _container) = test_services().await;

    let organization = services
        .organization_service
        .create(organization(), AuthenticatedEntity::System)
        .await
        .unwrap();
    let network = services
        .network_service
        .create(network(&organization.id), AuthenticatedEntity::System)
        .await
        .unwrap();

    // Create host with one interface
    let mut host1 = host(&network.id);
    host1.base.source = EntitySource::Discovery {
        metadata: vec![DiscoveryMetadata::default()],
    };
    let subnet1 = subnet(&network.id);
    services
        .subnet_service
        .create(subnet1.clone(), AuthenticatedEntity::System)
        .await
        .unwrap();
    host1.base.interfaces = vec![interface(&subnet1.id)];

    let (created, _) = services
        .host_service
        .create_host_with_services(host1.clone(), vec![], AuthenticatedEntity::System)
        .await
        .unwrap();

    // Create "duplicate" with additional interface
    let mut host2 = host(&network.id);
    host2.base.source = EntitySource::Discovery {
        metadata: vec![DiscoveryMetadata::default()],
    };
    let subnet2 = subnet(&network.id);
    services
        .subnet_service
        .create(subnet2.clone(), AuthenticatedEntity::System)
        .await
        .unwrap();
    host2.base.interfaces = vec![interface(&subnet1.id), interface(&subnet2.id)];

    let (upserted, _) = services
        .host_service
        .create_host_with_services(host2.clone(), vec![], AuthenticatedEntity::System)
        .await
        .unwrap();

    // Should have merged interfaces + discovery data
    assert_eq!(upserted.id, created.id);
    assert_eq!(upserted.base.interfaces.len(), 2);
    if let EntitySource::Discovery { metadata } = upserted.base.source {
        assert_eq!(metadata.len(), 2)
    } else {
        panic!("Got a different type of source after upserting")
    }
}

#[tokio::test]
#[serial]
async fn test_host_consolidation() {
    let (_, services, _container) = test_services().await;

    let organization = services
        .organization_service
        .create(organization(), AuthenticatedEntity::System)
        .await
        .unwrap();
    let network = services
        .network_service
        .create(network(&organization.id), AuthenticatedEntity::System)
        .await
        .unwrap();

    let subnet_obj = subnet(&network.id);
    services
        .subnet_service
        .create(subnet_obj.clone(), AuthenticatedEntity::System)
        .await
        .unwrap();

    let mut host1 = host(&network.id);
    host1.base.interfaces = Vec::new();

    let (created1, _) = services
        .host_service
        .create_host_with_services(host1.clone(), vec![], AuthenticatedEntity::System)
        .await
        .unwrap();

    let mut host2 = host(&network.id);
    host2.base.interfaces = vec![interface(&subnet_obj.id)];

    let mut svc = service(&network.id, &host2.id);
    svc.base.bindings = vec![Binding::new_port(
        host2.base.ports[0].id,
        Some(host2.base.interfaces[0].id),
    )];

    let (created2, created_svcs) = services
        .host_service
        .create_host_with_services(host2.clone(), vec![svc], AuthenticatedEntity::System)
        .await
        .unwrap();

    let created_svc = &created_svcs[0];

    // Consolidate host2 into host1
    let consolidated = services
        .host_service
        .consolidate_hosts(
            created1.clone(),
            created2.clone(),
            AuthenticatedEntity::System,
        )
        .await
        .unwrap();

    // Host1 should have host2's service
    assert!(consolidated.base.services.contains(&created_svc.id));

    // Host2 should be deleted
    let host2_after = services.host_service.get_by_id(&created2.id).await.unwrap();
    assert!(host2_after.is_none());

    // Service should now belong to host1
    let svc_after = services
        .service_service
        .get_by_id(&created_svc.id)
        .await
        .unwrap()
        .unwrap();

    assert_eq!(svc_after.base.host_id, consolidated.id);
}
