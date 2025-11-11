
use crate::server::organizations::r#impl::base::Organization;
use crate::server::shared::handlers::traits::{
    get_by_id_handler, update_handler,
};
use crate::server::{config::AppState};
use axum::Router;
use axum::routing::{get, put};
use std::sync::Arc;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/{id}", put(update_handler::<Organization>))
        .route("/{id}", get(get_by_id_handler::<Organization>))
}
