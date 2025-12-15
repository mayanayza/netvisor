use crate::server::auth::middleware::{
    auth::AuthenticatedUser,
    features::{CreateNetworkFeature, RequireFeature},
    permissions::RequireAdmin,
};
use crate::server::networks::api::CreateNetworkRequest;
use crate::server::shared::handlers::traits::{
    CrudHandlers, bulk_delete_handler, delete_handler, get_by_id_handler, update_handler,
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
        .route("/bulk-delete", post(bulk_delete_handler::<Network>))
}

pub async fn create_handler(
    State(state): State<Arc<AppState>>,
    RequireAdmin(user): RequireAdmin,
    RequireFeature { .. }: RequireFeature<CreateNetworkFeature>,
    Json(request): Json<CreateNetworkRequest>,
) -> ApiResult<Json<ApiResponse<Network>>> {
    if let Err(err) = request.network.validate() {
        return Err(ApiError::bad_request(&format!(
            "Network validation failed: {}",
            err
        )));
    }

    let service = Network::get_service(&state);
    let created = service
        .create(request.network, user.clone().into())
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    if request.seed_baseline_data {
        service.seed_default_data(created.id, user.into()).await?;
    }

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
