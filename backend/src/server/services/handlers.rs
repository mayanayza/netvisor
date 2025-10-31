use crate::server::{
    auth::middleware::AuthenticatedUser,
    config::AppState,
    services::types::base::Service,
    shared::types::api::{ApiResponse, ApiResult},
};
use axum::{Router, extract::State, response::Json, routing::get};
use std::sync::Arc;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new().route("/", get(get_all_services))
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
