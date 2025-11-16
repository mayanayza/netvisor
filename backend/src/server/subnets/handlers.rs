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
    MemberOrDaemon { entity, .. }: MemberOrDaemon,
    Json(request): Json<Subnet>,
) -> ApiResult<Json<ApiResponse<Subnet>>> {
    if let Err(err) = request.validate() {
        tracing::warn!(
            subnet_name = %request.base.name,
            subnet_cidr = %request.base.cidr,
            entity_id = %entity.entity_id(),
            error = %err,
            "Subnet validation failed"
        );
        return Err(ApiError::bad_request(&format!(
            "Subnet validation failed: {}",
            err
        )));
    }

    tracing::debug!(
        subnet_name = %request.base.name,
        subnet_cidr = %request.base.cidr,
        network_id = %request.base.network_id,
        entity_id = %entity.entity_id(),
        "Subnet create request received"
    );

    let service = Subnet::get_service(&state);
    let created = service.create(request).await.map_err(|e| {
        tracing::error!(
            error = %e,
            entity_id = %entity.entity_id(),
            "Failed to create subnet"
        );
        ApiError::internal_error(&e.to_string())
    })?;

    tracing::info!(
        subnet_id = %created.id,
        subnet_name = %created.base.name,
        entity_id = %entity.entity_id(),
        "Subnet created via API"
    );

    Ok(Json(ApiResponse::success(created)))
}

async fn get_all_subnets(
    State(state): State<Arc<AppState>>,
    entity: AuthenticatedEntity,
) -> ApiResult<Json<ApiResponse<Vec<Subnet>>>> {
    tracing::debug!(
        entity_id = %entity.entity_id(),
        network_count = %entity.network_ids().len(),
        "Get all subnets request received"
    );

    let service = &state.services.subnet_service;
    let filter = EntityFilter::unfiltered().network_ids(&entity.network_ids());

    let subnets = service.get_all(filter).await.map_err(|e| {
        tracing::error!(
            error = %e,
            entity_id = %entity.entity_id(),
            "Failed to fetch subnets"
        );
        ApiError::internal_error(&e.to_string())
    })?;

    tracing::debug!(
        entity_id = %entity.entity_id(),
        subnet_count = %subnets.len(),
        "Subnets fetched successfully"
    );

    Ok(Json(ApiResponse::success(subnets)))
}
