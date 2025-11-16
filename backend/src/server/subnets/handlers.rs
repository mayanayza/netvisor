use crate::server::auth::middleware::{AuthenticatedEntity, MemberOrDaemon};
use crate::server::shared::handlers::traits::{
    CrudHandlers, delete_handler, get_by_id_handler, update_handler,
};
use crate::server::shared::types::api::ApiError;
use crate::server::{
    config::AppState,
    shared::{
        services::traits::CrudService,
        storage::filter::EntityFilter,
        types::api::{ApiResponse, ApiResult},
    },
    subnets::r#impl::base::Subnet,
};
use axum::routing::{delete, get, post, put};
use axum::{Router, extract::State, response::Json};
use std::sync::Arc;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", post(create_handler))
        .route("/", get(get_all_subnets))
        .route("/{id}", put(update_handler::<Subnet>))
        .route("/{id}", delete(delete_handler::<Subnet>))
        .route("/{id}", get(get_by_id_handler::<Subnet>))
}

pub async fn create_handler(
    State(state): State<Arc<AppState>>,
    MemberOrDaemon { .. }: MemberOrDaemon,
    Json(request): Json<Subnet>,
) -> ApiResult<Json<ApiResponse<Subnet>>> {
    if let Err(err) = request.validate() {
        return Err(ApiError::bad_request(&format!(
            "Subnet validation failed: {}",
            err
        )));
    }

    let service = Subnet::get_service(&state);
    let created = service
        .create(request)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    Ok(Json(ApiResponse::success(created)))
}

async fn get_all_subnets(
    State(state): State<Arc<AppState>>,
    entity: AuthenticatedEntity,
) -> ApiResult<Json<ApiResponse<Vec<Subnet>>>> {
    let service = &state.services.subnet_service;

    let filter = EntityFilter::unfiltered().network_ids(&entity.network_ids());

    let subnets = service.get_all(filter).await?;

    Ok(Json(ApiResponse::success(subnets)))
}
