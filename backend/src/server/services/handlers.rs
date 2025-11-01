use crate::server::{
    auth::middleware::AuthenticatedUser,
    config::AppState,
    services::types::base::Service,
    shared::types::api::{ApiError, ApiResponse, ApiResult},
};
use axum::{
    Router,
    extract::{Path, State},
    response::Json,
    routing::{delete, get, put},
};
use std::sync::Arc;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", get(get_all_services))
        .route("/{id}", delete(delete_service))
        .route("/{id}", put(update_service))
}

async fn get_all_services(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> ApiResult<Json<ApiResponse<Vec<Service>>>> {
    let service_service = &state.services.service_service;

    let network_ids: Vec<Uuid> = state
        .services
        .network_service
        .get_all_networks(&user.0)
        .await?
        .iter()
        .map(|n| n.id)
        .collect();

    let subnets = service_service.get_all_services(&network_ids).await?;

    Ok(Json(ApiResponse::success(subnets)))
}

async fn update_service(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Path(id): Path<Uuid>,
    Json(request): Json<Service>,
) -> ApiResult<Json<ApiResponse<Service>>> {
    let service_service = &state.services.service_service;

    let mut service = service_service
        .get_service(&id)
        .await?
        .ok_or_else(|| ApiError::not_found(format!("Service '{}' not found", &id)))?;

    service.base = request.base;
    let updated_service = service_service.update_service(service).await?;

    Ok(Json(ApiResponse::success(updated_service)))
}

async fn delete_service(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let service = &state.services.service_service;

    // Check if host exists
    if service.get_service(&id).await?.is_none() {
        return Err(ApiError::not_found(format!("Host '{}' not found", &id)));
    }

    service.delete_service(&id).await?;

    Ok(Json(ApiResponse::success(())))
}
