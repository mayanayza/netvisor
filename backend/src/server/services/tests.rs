use serial_test::serial;

use crate::{
    server::{
        auth::middleware::auth::AuthenticatedEntity,
        bindings::r#impl::base::Binding,
        services::r#impl::patterns::MatchDetails,
        shared::{
            services::traits::CrudService, storage::filter::EntityFilter,
            types::entities::EntitySource,
        },
    },
    tests::*,
};

#[tokio::test]
#[serial]
async fn test_service_deduplication_on_create() {
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

    // Create first service + host
    let host_obj = host(&network.id);
    let iface = interface(&network.id, &subnet_obj.id);
    let port = port(&network.id, &host_obj.id);

    let mut svc1 = service(&network.id, &host_obj.id);
    // Add bindings so the deduplication logic can match them
    svc1.base.bindings = vec![Binding::new_port_serviceless(port.id, Some(iface.id))];
    // Set source to discovery so upsert route is used
    svc1.base.source = EntitySource::DiscoveryWithMatch {
        metadata: vec![],
        details: MatchDetails::new_certain("Test"),
    };

    let created1 = services
        .host_service
        .discover_host(
            host_obj.clone(),
            vec![iface],
            vec![port],
            vec![svc1.clone()],
            AuthenticatedEntity::System,
        )
        .await
        .unwrap();

    // Verify children were created
    assert!(
        !created1.interfaces.is_empty(),
        "Interface should have been created with host"
    );
    assert!(
        !created1.ports.is_empty(),
        "Port should have been created with host"
    );
    assert!(
        !created1.services.is_empty(),
        "Service should have been created with host"
    );

    // Get created interface & port from returned HostResponse
    let created_iface = &created1.interfaces[0];
    let created_port = &created1.ports[0];

    // Try to create duplicate (same definition + matching bindings)
    // Must use created_host's IDs since host deduplication may have changed them
    let mut svc2 = service(&network.id, &created1.id);
    svc2.base.service_definition = svc1.base.service_definition.clone();
    svc2.base.bindings = vec![Binding::new_port_serviceless(
        created_port.id,
        Some(created_iface.id),
    )];
    svc2.base.source = EntitySource::DiscoveryWithMatch {
        metadata: vec![],
        details: MatchDetails::new_certain("Test"),
    };

    let created2 = services
        .service_service
        .create(svc2.clone(), AuthenticatedEntity::System)
        .await
        .unwrap();

    // Should return same service (upserted) - compare service IDs
    let created_svc1 = &created1.services[0];
    assert_eq!(created_svc1.id, created2.id, "Services should have been deduplicated");

    let filter = EntityFilter::unfiltered().host_id(&created1.id);
    // Verify only one service in DB
    let all_services = services.service_service.get_all(filter).await.unwrap();
    assert_eq!(all_services.len(), 1);
}

#[tokio::test]
#[serial]
async fn test_service_deletion_cleans_up_relationships() {
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
    let created_subnet = services
        .subnet_service
        .create(subnet_obj.clone(), AuthenticatedEntity::System)
        .await
        .unwrap();

    let host_obj = host(&network.id);
    let iface = interface(&network.id, &created_subnet.id);
    let port = port(&network.id, &host_obj.id);

    // Create service in a group
    let mut svc = service(&network.id, &host_obj.id);
    let binding = Binding::new_port_serviceless(port.id, Some(iface.id));
    svc.base.bindings = vec![binding];

    let created_host = services
        .host_service
        .discover_host(
            host_obj.clone(),
            vec![iface],
            vec![port],
            vec![svc.clone()],
            AuthenticatedEntity::System,
        )
        .await
        .unwrap();

    // Verify children were created
    assert!(
        !created_host.interfaces.is_empty(),
        "Interface should have been created"
    );
    assert!(
        !created_host.ports.is_empty(),
        "Port should have been created"
    );
    assert!(
        !created_host.services.is_empty(),
        "Service should have been created"
    );

    // Get the created service from the HostResponse
    let created_svc = &created_host.services[0];

    // Verify the service has bindings (they should be populated via reassign_service_interface_bindings)
    assert!(
        !created_svc.base.bindings.is_empty(),
        "Service should have bindings after creation"
    );

    let mut group_obj = group(&network.id);
    group_obj.base.binding_ids = vec![created_svc.base.bindings[0].id()];
    let created_group = services
        .group_service
        .create(group_obj, AuthenticatedEntity::System)
        .await
        .unwrap();

    // Delete service
    services
        .service_service
        .delete(&created_svc.id, AuthenticatedEntity::System)
        .await
        .unwrap();

    // Group should no longer have service binding
    let group_after = services
        .group_service
        .get_by_id(&created_group.id)
        .await
        .unwrap()
        .unwrap();

    assert!(group_after.base.binding_ids.is_empty());
}
