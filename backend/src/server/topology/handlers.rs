use crate::server::{
    auth::extractor::AuthenticatedUser,
    config::AppState,
    shared::types::api::{ApiResponse, ApiResult},
    topology::types::api::TopologyRequestOptions,
};
use axum::{Router, extract::State, response::Json, routing::post};
use std::sync::Arc;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new().route("/", post(get_topology))
}

async fn get_topology(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Json(request): Json<TopologyRequestOptions>,
) -> ApiResult<Json<ApiResponse<serde_json::Value>>> {
    let service = &state.services.topology_service;
    let graph = service.build_graph(request).await?;

    let json = serde_json::to_value(&graph)?;

    Ok(Json(ApiResponse::success(json)))
}
