use crate::server::{
    auth::middleware::AuthenticatedUser,
    config::AppState,
    shared::{
        handlers::traits::{
            create_handler, delete_handler, get_all_handler, get_by_id_handler, update_handler,
        },
        types::api::{ApiResponse, ApiResult},
    },
    topology::types::{api::TopologyOptions, base::Topology},
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
        .route("/", post(create_handler::<Topology>))
        .route("/", get(get_all_handler::<Topology>))
        .route("/{id}", put(update_handler::<Topology>))
        .route("/{id}", delete(delete_handler::<Topology>))
        .route("/{id}", get(get_by_id_handler::<Topology>))
        .route("/generate", post(generate_topology))
}

async fn generate_topology(
    State(state): State<Arc<AppState>>,
    _user: AuthenticatedUser,
    Json(request): Json<TopologyOptions>,
) -> ApiResult<Json<ApiResponse<serde_json::Value>>> {
    let service = &state.services.topology_service;
    let graph = service.build_graph(request).await?;

    let json = serde_json::to_value(&graph)?;

    Ok(Json(ApiResponse::success(json)))
}
