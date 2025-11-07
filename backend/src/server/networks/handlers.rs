use crate::server::shared::handlers::traits::{
    create_handler, delete_handler, get_by_id_handler, update_handler,
};
use crate::server::{
    auth::middleware::AuthenticatedUser,
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
        .route("/", post(create_handler::<Network>))
        .route("/", get(get_all_networks))
        .route("/{id}", put(update_handler::<Network>))
        .route("/{id}", delete(delete_handler::<Network>))
        .route("/{id}", get(get_by_id_handler::<Network>))
}

async fn get_all_networks(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> ApiResult<Json<ApiResponse<Vec<Network>>>> {
    let service = &state.services.network_service;

    let filter = EntityFilter::unfiltered().user_id(&user.0);

    let networks = service.get_all(filter).await?;

    Ok(Json(ApiResponse::success(networks)))
}
