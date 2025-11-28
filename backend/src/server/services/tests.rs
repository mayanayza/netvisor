use serial_test::serial;

use crate::{
    server::{
        auth::middleware::auth::AuthenticatedEntity,
        groups::r#impl::types::GroupType,
        services::r#impl::{bindings::Binding, patterns::MatchDetails},
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
    let mut host_obj = host(&network.id);
    host_obj.base.interfaces = vec![interface(&subnet_obj.id)];

    let mut svc1 = service(&network.id, &host_obj.id);
    // Add bindings so the deduplication logic can match them
    svc1.base.bindings = vec![Binding::new_port(
        host_obj.base.ports[0].id,
        Some(host_obj.base.interfaces[0].id),
    )];
    // Set source to discovery so upsert route is used
    svc1.base.source = EntitySource::DiscoveryWithMatch {
        metadata: vec![],
        details: MatchDetails::new_certain("Test"),
    };

    let (created_host, created1) = services
        .host_service
        .create_host_with_services(
            host_obj.clone(),
            vec![svc1.clone()],
            AuthenticatedEntity::System,
        )
        .await
        .unwrap();

    // Try to create duplicate (same definition + matching bindings)
    // Must use created_host's IDs since host deduplication may have changed them
    let mut svc2 = service(&network.id, &created_host.id);
    svc2.base.service_definition = svc1.base.service_definition.clone();
    svc2.base.bindings = vec![Binding::new_port(
        created_host.base.ports[0].id,
        Some(created_host.base.interfaces[0].id),
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

    // Should return same service (upserted)
    assert_eq!(created1[0].id, created2.id);

    let filter = EntityFilter::unfiltered().host_id(&svc1.base.host_id);
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

    let mut host_obj = host(&network.id);
    host_obj.base.interfaces = vec![interface(&created_subnet.id)];

    // Create service in a group
    let mut svc = service(&network.id, &host_obj.id);
    let binding = Binding::new_port(
        host_obj.base.ports[0].id,
        Some(host_obj.base.interfaces[0].id),
    );
    svc.base.bindings = vec![binding];

    services
        .host_service
        .create_host_with_services(
            host_obj.clone(),
            vec![svc.clone()],
            AuthenticatedEntity::System,
        )
        .await
        .unwrap();

    let created_svc = services
        .service_service
        .get_by_id(&svc.id)
        .await
        .unwrap()
        .unwrap();

    let mut group_obj = group(&network.id);
    group_obj.base.group_type = GroupType::RequestPath {
        service_bindings: vec![created_svc.base.bindings[0].id()],
    };
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

    match group_after.base.group_type {
        GroupType::RequestPath { service_bindings }
        | GroupType::HubAndSpoke { service_bindings } => assert!(service_bindings.is_empty()),
    }
}
