use serial_test::serial;

use crate::{
    server::{
        auth::middleware::auth::AuthenticatedEntity,
        bindings::r#impl::base::Binding,
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

    // Create a subnet first for interfaces
    let subnet1 = subnet(&network.id);
    services
        .subnet_service
        .create(subnet1.clone(), AuthenticatedEntity::System)
        .await
        .unwrap();

    let filter = EntityFilter::unfiltered().network_ids(&[network.id]);

    let start_host_count = storage.hosts.get_all(filter.clone()).await.unwrap().len();

    // Create first host with an interface
    let mut host1 = host(&network.id);
    host1.base.source = EntitySource::Discovery {
        metadata: vec![DiscoveryMetadata::default()],
    };
    let iface1 = interface(&network.id, &subnet1.id);
    let created1 = services
        .host_service
        .discover_host(
            host1.clone(),
            vec![iface1.clone()],
            vec![],
            vec![],
            AuthenticatedEntity::System,
        )
        .await
        .unwrap();

    // Verify interface was created - use the returned HostResponse directly
    assert!(
        !created1.interfaces.is_empty(),
        "Interface should have been created with host"
    );
    let host1_interface = &created1.interfaces[0];

    // Try to create duplicate (same interfaces - matching by IP+subnet or MAC)
    let mut host2 = host(&network.id);
    host2.base.source = EntitySource::Discovery {
        metadata: vec![DiscoveryMetadata::default()],
    };
    // Use the same interface data to trigger deduplication
    let created2 = services
        .host_service
        .discover_host(
            host2.clone(),
            vec![host1_interface.clone()],
            vec![],
            vec![],
            AuthenticatedEntity::System,
        )
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

    // Create subnets
    let subnet1 = subnet(&network.id);
    services
        .subnet_service
        .create(subnet1.clone(), AuthenticatedEntity::System)
        .await
        .unwrap();
    let subnet2 = subnet(&network.id);
    services
        .subnet_service
        .create(subnet2.clone(), AuthenticatedEntity::System)
        .await
        .unwrap();

    // Create host with one interface
    let mut host1 = host(&network.id);
    host1.base.source = EntitySource::Discovery {
        metadata: vec![DiscoveryMetadata::default()],
    };
    let iface1 = interface(&network.id, &subnet1.id);

    let created = services
        .host_service
        .discover_host(
            host1.clone(),
            vec![iface1.clone()],
            vec![],
            vec![],
            AuthenticatedEntity::System,
        )
        .await
        .unwrap();

    // Verify interface was created
    assert!(
        !created.interfaces.is_empty(),
        "Interface should have been created with host"
    );
    let created_iface1 = &created.interfaces[0];

    // Create "duplicate" with additional interface (matching first interface triggers upsert)
    let mut host2 = host(&network.id);
    host2.base.source = EntitySource::Discovery {
        metadata: vec![DiscoveryMetadata::default()],
    };
    let iface2 = interface(&network.id, &subnet2.id);

    // Use the CREATED interface to ensure deduplication matching works
    let upserted = services
        .host_service
        .discover_host(
            host2.clone(),
            vec![created_iface1.clone(), iface2],
            vec![],
            vec![],
            AuthenticatedEntity::System,
        )
        .await
        .unwrap();

    // Should have merged - same host ID
    assert_eq!(upserted.id, created.id);

    // Check interface count - use returned HostResponse
    assert_eq!(upserted.interfaces.len(), 2, "Upserted host should have 2 interfaces");

    if let EntitySource::Discovery { metadata } = upserted.source {
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

    // Create host1 without interfaces
    let host1 = host(&network.id);
    let created1 = services
        .host_service
        .discover_host(
            host1.clone(),
            vec![],
            vec![],
            vec![],
            AuthenticatedEntity::System,
        )
        .await
        .unwrap();

    // Create host2 with an interface
    let host2 = host(&network.id);
    let port = port(&network.id, &host2.id);
    let iface = interface(&network.id, &subnet_obj.id);

    let mut svc = service(&network.id, &host2.id);
    svc.base.bindings = vec![Binding::new_port_serviceless(port.id, Some(iface.id))];

    let created2 = services
        .host_service
        .discover_host(
            host2.clone(),
            vec![iface],
            vec![port],
            vec![svc],
            AuthenticatedEntity::System,
        )
        .await
        .unwrap();

    let created_svc = &created2.services[0];

    // Consolidate host2 into host1
    let consolidated = services
        .host_service
        .consolidate_hosts(
            created1.to_host(),
            created2.to_host(),
            AuthenticatedEntity::System,
        )
        .await
        .unwrap();

    // Host1 should have host2's service
    assert!(consolidated.services.contains(&created_svc));

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
