use crate::{
    daemon::{
        discovery::handlers as discovery_handlers,
        runtime::types::{DaemonAppState, InitializeDaemonRequest},
    },
    server::shared::types::api::{ApiResponse, ApiResult},
};
use axum::{
    Json, Router,
    extract::State,
    routing::{get, post},
};
use std::sync::Arc;

pub fn create_router() -> Router<Arc<DaemonAppState>> {
    Router::new()
        .nest("/api/discovery", discovery_handlers::create_router())
        .route("/api/health", get(get_health))
        .route("/api/initialize", post(initialize))
}

async fn get_health() -> ApiResult<Json<ApiResponse<String>>> {
    tracing::info!("Received healthcheck request");

    Ok(Json(ApiResponse::success(
        "Netvisor Daemon Running".to_string(),
    )))
}

async fn initialize(
    State(state): State<Arc<DaemonAppState>>,
    Json(request): Json<InitializeDaemonRequest>,
) -> ApiResult<Json<ApiResponse<String>>> {
    tracing::info!(
        "Received initialization signal with network_id: {}, api_key: [redacted]",
        request.network_id,
    );

    state
        .services
        .runtime_service
        .initialize_services(request.network_id, request.api_key)
        .await?;

    Ok(Json(ApiResponse::success(
        "Daemon initialized successfully".to_string(),
    )))
}
