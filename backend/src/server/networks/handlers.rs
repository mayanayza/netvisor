use crate::server::auth::middleware::{AuthenticatedUser, RequireMember};
use crate::server::shared::handlers::traits::{
    CrudHandlers, delete_handler, get_by_id_handler, update_handler,
};
use crate::server::shared::types::api::ApiError;
use crate::server::{
    config::AppState,
    networks::r#impl::Network,
    shared::{
        services::traits::CrudService,
        storage::filter::EntityFilter,
        types::api::{ApiResponse, ApiResult},
    },
};
use anyhow::anyhow;
use axum::{
    Router,
    extract::State,
    response::Json,
    routing::{delete, get, post, put},
};
use std::sync::Arc;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", post(create_handler))
        .route("/", get(get_all_networks))
        .route("/{id}", put(update_handler::<Network>))
        .route("/{id}", delete(delete_handler::<Network>))
        .route("/{id}", get(get_by_id_handler::<Network>))
}

pub async fn create_handler(
    State(state): State<Arc<AppState>>,
    RequireMember(user): RequireMember,
    Json(request): Json<Network>,
) -> ApiResult<Json<ApiResponse<Network>>> {
    if let Err(err) = request.validate() {
        return Err(ApiError::bad_request(&format!(
            "Network validation failed: {}",
            err
        )));
    }

    let organization = state
        .services
        .organization_service
        .get_by_id(&user.organization_id)
        .await?
        .ok_or_else(|| anyhow!("Failed to get organization for user {}", user.user_id))?;

    let networks = state
        .services
        .network_service
        .get_all(EntityFilter::unfiltered().organization_id(&organization.id))
        .await?;

    if let Some(plan) = organization.base.plan
        && let Some(max_networks) = plan.features().max_networks
        && networks.len() >= max_networks
    {
        return Err(ApiError::forbidden(&format!(
            "Current plan ({}) only allows for {} network(s). Please upgrade for additional networks.",
            plan, max_networks
        )));
    }

    let service = Network::get_service(&state);
    let created = service
        .create(request)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(created)))
}

async fn get_all_networks(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> ApiResult<Json<ApiResponse<Vec<Network>>>> {
    let service = &state.services.network_service;

    let filter = EntityFilter::unfiltered().organization_id(&user.organization_id);

    let networks = service.get_all(filter).await?;

    Ok(Json(ApiResponse::success(networks)))
}
