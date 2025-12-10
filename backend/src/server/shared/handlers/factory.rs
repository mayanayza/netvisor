use crate::server::api_keys::r#impl::base::{ApiKey, ApiKeyBase};
use crate::server::auth::middleware::auth::{AuthenticatedEntity, AuthenticatedUser};
use crate::server::auth::middleware::permissions::RequireOwner;
use crate::server::billing::types::base::BillingPlan;
use crate::server::billing::types::features::Feature;
use crate::server::config::PublicConfigResponse;
use crate::server::discovery::r#impl::types::DiscoveryType;
use crate::server::github::handlers::get_stars;
use crate::server::groups::r#impl::types::GroupType;
use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::networks::r#impl::{Network, NetworkBase};
use crate::server::organizations::r#impl::base::Organization;
use crate::server::services::definitions::ServiceDefinitionRegistry;
use crate::server::shared::concepts::Concept;
use crate::server::shared::entities::EntityDiscriminants;
use crate::server::shared::events::types::{TelemetryEvent, TelemetryOperation};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::traits::StorableEntity;
use crate::server::shared::types::api::{ApiError, ApiResult};
use crate::server::shared::types::metadata::{MetadataProvider, MetadataRegistry};
use crate::server::subnets::r#impl::types::SubnetType;
use crate::server::topology::types::base::{Topology, TopologyBase};
use crate::server::topology::types::edges::EdgeType;
use crate::server::users::r#impl::permissions::UserOrgPermissions;
use crate::server::{
    auth::handlers as auth_handlers, billing::handlers as billing_handlers, config::AppState,
    daemons::handlers as daemon_handlers, discovery::handlers as discovery_handlers,
    groups::handlers as group_handlers, hosts::handlers as host_handlers,
    networks::handlers as network_handlers, organizations::handlers as organization_handlers,
    services::handlers as service_handlers, shared::types::api::ApiResponse,
    subnets::handlers as subnet_handlers, tags::handlers as tag_handlers,
    topology::handlers as topology_handlers, users::handlers as user_handlers,
};
use anyhow::anyhow;
use axum::extract::State;
use axum::http::HeaderValue;
use axum::routing::post;
use axum::{Json, Router, routing::get};
use chrono::Utc;
use reqwest::header;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use strum::{IntoDiscriminant, IntoEnumIterator};
use tower_http::set_header::SetResponseHeaderLayer;
use uuid::Uuid;

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
        .nest("/api/billing", billing_handlers::create_router())
        .nest("/api/auth", auth_handlers::create_router())
        .nest("/api/organizations", organization_handlers::create_router())
        .nest("/api/tags", tag_handlers::create_router())
        .route("/api/health", get(get_health))
        .route("/api/onboarding", post(onboarding))
        // Group cacheable routes together
        .merge(
            Router::new()
                .route("/api/metadata", get(get_metadata_registry))
                .route("/api/config", get(get_public_config))
                .route("/api/github-stars", get(get_stars))
                .layer(SetResponseHeaderLayer::if_not_present(
                    header::CACHE_CONTROL,
                    HeaderValue::from_static("max-age=3600, must-revalidate"),
                )),
        )
}

async fn get_metadata_registry(_user: AuthenticatedUser) -> Json<ApiResponse<MetadataRegistry>> {
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
        entities: EntityDiscriminants::iter()
            .map(|e| e.to_metadata())
            .collect(),
        concepts: Concept::iter().map(|e| e.to_metadata()).collect(),
        ports: PortBase::iter().map(|p| p.to_metadata()).collect(),
        discovery_types: DiscoveryType::iter().map(|d| d.to_metadata()).collect(),
        billing_plans: BillingPlan::iter().map(|p| p.to_metadata()).collect(),
        features: Feature::iter().map(|f| f.to_metadata()).collect(),
        permissions: UserOrgPermissions::iter()
            .map(|p| p.to_metadata())
            .collect(),
    };

    Json(ApiResponse::success(registry))
}

async fn get_health() -> Json<ApiResponse<String>> {
    Json(ApiResponse::success("Netvisor Server Running".to_string()))
}

pub async fn get_public_config(
    State(state): State<Arc<AppState>>,
) -> Json<ApiResponse<PublicConfigResponse>> {
    let oidc_providers = state
        .services
        .oidc_service
        .as_ref()
        .map(|o| o.as_ref().list_providers())
        .unwrap_or_default();

    Json(ApiResponse::success(PublicConfigResponse {
        server_port: state.config.server_port,
        disable_registration: state.config.disable_registration,
        oidc_providers,
        billing_enabled: state.config.stripe_secret.is_some(),
        has_integrated_daemon: state.config.integrated_daemon_url.is_some(),
        has_email_service: (state.config.smtp_password.is_some()
            && state.config.smtp_username.is_some()
            && state.config.smtp_email.is_some()
            && state.config.smtp_relay.is_some())
            || state.config.plunk_secret.is_some(),
        public_url: state.config.public_url.clone(),
        has_email_opt_in: state.config.plunk_secret.is_some(),
    }))
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OnboardingRequest {
    pub organization_name: String,
    pub network_name: String,
    pub populate_seed_data: bool,
}

pub async fn onboarding(
    State(state): State<Arc<AppState>>,
    RequireOwner(user): RequireOwner,
    Json(request): Json<OnboardingRequest>,
) -> ApiResult<Json<ApiResponse<Organization>>> {
    let mut org = state
        .services
        .organization_service
        .get_by_id(&user.organization_id)
        .await?
        .ok_or_else(|| anyhow!("Could not find organization."))?;

    if org.has_onboarded(&TelemetryOperation::OnboardingModalCompleted) {
        return Err(ApiError::bad_request(
            "Org has already completed onboarding modal",
        ));
    }

    // Billing not enabled = self hosted
    if state.config.stripe_secret.is_none() {
        org.base.plan = Some(BillingPlan::default())
    }

    org.base.name = request.organization_name;
    org.base
        .onboarding
        .push(TelemetryOperation::OnboardingModalCompleted);
    let updated_org = state
        .services
        .organization_service
        .update(&mut org, user.clone().into())
        .await?;

    let mut network = Network::new(NetworkBase::new(user.organization_id));
    network.base.name = request.network_name;

    let network = state
        .services
        .network_service
        .create(network, user.clone().into())
        .await?;

    if request.populate_seed_data {
        state
            .services
            .network_service
            .seed_default_data(network.id, user.clone().into())
            .await?;
    }

    let topology = Topology::new(TopologyBase::new("My Topology".to_string(), network.id));

    state
        .services
        .topology_service
        .create(topology, user.clone().into())
        .await?;

    if let Some(integrated_daemon_url) = &state.config.integrated_daemon_url {
        let api_key = state
            .services
            .api_key_service
            .create(
                ApiKey::new(ApiKeyBase {
                    key: state.services.api_key_service.generate_api_key(),
                    name: "Integrated Daemon API Key".to_string(),
                    last_used: None,
                    expires_at: None,
                    network_id: network.id,
                    is_enabled: true,
                    tags: Vec::new(),
                }),
                AuthenticatedEntity::System,
            )
            .await?;

        state
            .services
            .daemon_service
            .initialize_local_daemon(integrated_daemon_url.clone(), network.id, api_key.base.key)
            .await?;
    }

    state
        .services
        .event_bus
        .publish_telemetry(TelemetryEvent {
            id: Uuid::new_v4(),
            organization_id: org.id,
            operation: TelemetryOperation::OnboardingModalCompleted,
            timestamp: Utc::now(),
            authentication: user.into(),
            metadata: serde_json::json!({
                "is_onboarding_step": true
            }),
        })
        .await?;

    Ok(Json(ApiResponse::success(updated_org)))
}
