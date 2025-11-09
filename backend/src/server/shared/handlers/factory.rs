use crate::server::config::PublicConfigResponse;
use crate::server::discovery::r#impl::types::DiscoveryType;
use crate::server::groups::r#impl::types::GroupType;
use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::ServiceDefinitionRegistry;
use crate::server::shared::entities::Entity;
use crate::server::shared::types::metadata::{MetadataProvider, MetadataRegistry};
use crate::server::subnets::r#impl::types::SubnetType;
use crate::server::topology::types::edges::EdgeType;
use crate::server::{
    auth::handlers as auth_handlers, config::AppState, daemons::handlers as daemon_handlers,
    discovery::handlers as discovery_handlers, groups::handlers as group_handlers,
    hosts::handlers as host_handlers, networks::handlers as network_handlers,
    services::handlers as service_handlers, shared::types::api::ApiResponse,
    subnets::handlers as subnet_handlers, topology::handlers as topology_handlers,
    users::handlers as user_handlers,
};
use axum::extract::State;
use axum::{Json, Router, routing::get};
use std::sync::Arc;
use strum::{IntoDiscriminant, IntoEnumIterator};

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .nest("/api/hosts", host_handlers::create_router())
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
        .route("/api/metadata", get(get_metadata_registry))
        .route("/api/config", get(get_public_config))
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
        edge_types: EdgeType::iter().map(|t| t.to_metadata()).collect(),
        entities: Entity::iter().map(|e| e.to_metadata()).collect(),
        ports: PortBase::iter().map(|p| p.to_metadata()).collect(),
        discovery_types: DiscoveryType::iter().map(|d| d.to_metadata()).collect(),
    };

    Json(ApiResponse::success(registry))
}

async fn get_health() -> Json<ApiResponse<String>> {
    Json(ApiResponse::success("Netvisor Server Running".to_string()))
}

pub async fn get_public_config(
    State(state): State<Arc<AppState>>,
) -> Json<ApiResponse<PublicConfigResponse>> {
    Json(ApiResponse::success(PublicConfigResponse {
        server_port: state.config.server_port,
        disable_registration: state.config.disable_registration,
        oidc_enabled: state.config.oidc_client_id.is_some()
            && state.config.oidc_client_secret.is_some()
            && state.config.oidc_issuer_url.is_some()
            && state.config.oidc_provider_name.is_some()
            && state.config.oidc_redirect_url.is_some(),
        oidc_provider_name: state
            .config
            .oidc_provider_name
            .clone()
            .unwrap_or("OIDC Provider".to_string()),
    }))
}
