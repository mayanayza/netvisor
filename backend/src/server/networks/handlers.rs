use crate::server::auth::middleware::{AuthenticatedUser, RequireAdmin};
use crate::server::shared::handlers::traits::{
    BulkDeleteResponse, CrudHandlers, bulk_delete_handler, delete_handler, get_by_id_handler,
    update_handler,
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
use axum::extract::Path;
use axum::{
    Router,
    extract::State,
    response::Json,
    routing::{delete, get, post, put},
};
use std::sync::Arc;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", post(create_handler))
        .route("/", get(get_all_networks))
        .route("/{id}", put(update_network))
        .route("/{id}", delete(delete_network))
        .route("/{id}", get(get_by_id_handler::<Network>))
        .route("/bulk-delete", post(bulk_delete_network))
}

pub async fn create_handler(
    State(state): State<Arc<AppState>>,
    RequireAdmin(user): RequireAdmin,
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
        .create(request, user.into())
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(created)))
}

async fn get_all_networks(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> ApiResult<Json<ApiResponse<Vec<Network>>>> {
    let service = &state.services.network_service;

    let filter = EntityFilter::unfiltered().entity_ids(&user.network_ids);

    let networks = service.get_all(filter).await?;

    Ok(Json(ApiResponse::success(networks)))
}

async fn update_network(
    state: State<Arc<AppState>>,
    admin: RequireAdmin,
    id: Path<Uuid>,
    request: Json<Network>,
) -> ApiResult<Json<ApiResponse<Network>>> {
    update_handler::<Network>(state, admin.into(), id, request).await
}

async fn delete_network(
    admin: RequireAdmin,
    state: State<Arc<AppState>>,
    id: Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    delete_handler::<Network>(state, admin.into(), id).await
}

async fn bulk_delete_network(
    admin: RequireAdmin,
    state: State<Arc<AppState>>,
    ids: Json<Vec<Uuid>>,
) -> ApiResult<Json<ApiResponse<BulkDeleteResponse>>> {
    bulk_delete_handler::<Network>(state, admin.into(), ids).await
}
