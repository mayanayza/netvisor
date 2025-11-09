use crate::server::shared::handlers::traits::{
    create_handler, delete_handler, get_all_handler, get_by_id_handler, update_handler,
};
use crate::server::{config::AppState, services::r#impl::base::Service};
use axum::Router;
use axum::routing::{delete, get, post, put};
use std::sync::Arc;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", post(create_handler::<Service>))
        .route("/", get(get_all_handler::<Service>))
        .route("/{id}", put(update_handler::<Service>))
        .route("/{id}", delete(delete_handler::<Service>))
        .route("/{id}", get(get_by_id_handler::<Service>))
}
