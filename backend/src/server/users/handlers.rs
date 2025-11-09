use crate::server::shared::handlers::traits::{
    create_handler, delete_handler, get_by_id_handler, update_handler,
};
use crate::server::{config::AppState, users::r#impl::base::User};
use axum::Router;
use axum::routing::{delete, get, post, put};
use std::sync::Arc;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", post(create_handler::<User>))
        .route("/{id}", put(update_handler::<User>))
        .route("/{id}", delete(delete_handler::<User>))
        .route("/{id}", get(get_by_id_handler::<User>))
}
