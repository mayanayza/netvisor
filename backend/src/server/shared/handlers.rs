use crate::server::discovery::types::base::DiscoveryType;
use crate::server::groups::types::GroupType;
use crate::server::hosts::types::ports::PortBase;
use crate::server::services::definitions::ServiceDefinitionRegistry;
use crate::server::shared::constants::Entity;
use crate::server::shared::types::metadata::{MetadataProvider, MetadataRegistry};
use crate::server::topology::types::edges::EdgeType;
use crate::server::{
    auth::handlers as auth_handlers,
    config::AppState,
    daemons::handlers as daemon_handlers,
    discovery::handlers as discovery_handlers,
    groups::handlers as group_handlers,
    hosts::handlers as host_handlers,
    networks::handlers as network_handlers,
    services::handlers as service_handlers,
    shared::types::api::ApiResponse,
    subnets::{handlers as subnet_handlers, types::base::SubnetType},
    topology::handlers as topology_handlers,
    users::handlers as user_handlers,
};
use axum::{Json, Router, routing::get};
use std::sync::Arc;
use strum::{IntoDiscriminant, IntoEnumIterator};

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .nest("/api/hosts", host_handlers::create_router())
        .route("/api/metadata", get(get_metadata_registry))
        .nest("/api/groups", group_handlers::create_router())
        .nest("/api/daemons", daemon_handlers::create_router())
        .nest("/api/discovery", discovery_handlers::create_router())
        .nest("/api/subnets", subnet_handlers::create_router())
        .nest("/api/topology", topology_handlers::create_router())
        .nest("/api/services", service_handlers::create_router())
        .nest("/api/networks", network_handlers::create_router())
        .nest("/api/users", user_handlers::create_router())
        .nest("/api/auth", auth_handlers::create_router())
        .route("/api/health", get(get_health))
}

async fn get_metadata_registry() -> Json<ApiResponse<MetadataRegistry>> {
    let registry = MetadataRegistry {
        service_definitions: ServiceDefinitionRegistry::all_service_definitions()
            .iter()
            .map(|t| t.to_metadata())
            .collect(),
        subnet_types: SubnetType::iter().map(|t| t.to_metadata()).collect(),
        group_types: GroupType::iter()
            .map(|t| t.discriminant().to_metadata())
            .collect(),
        edge_types: EdgeType::iter()
            .map(|t| t.to_metadata())
            .collect(),
        entities: Entity::iter().map(|e| e.to_metadata()).collect(),
        ports: PortBase::iter().map(|p| p.to_metadata()).collect(),
        discovery_types: DiscoveryType::iter().map(|d| d.to_metadata()).collect(),
    };

    Json(ApiResponse::success(registry))
}

async fn get_health() -> Json<ApiResponse<String>> {
    Json(ApiResponse::success("Netvisor Server Running".to_string()))
}
