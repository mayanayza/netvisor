use axum::Router;
use axum::routing::{delete, get, post, put};

use crate::server::config::AppState;
use crate::server::groups::r#impl::base::Group;
use crate::server::shared::handlers::traits::{
    bulk_delete_handler, create_handler, delete_handler, get_all_handler, get_by_id_handler,
    update_handler,
};
use std::sync::Arc;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/", post(create_handler::<Group>))
        .route("/", get(get_all_handler::<Group>))
        .route("/{id}", put(update_handler::<Group>))
        .route("/{id}", delete(delete_handler::<Group>))
        .route("/{id}", get(get_by_id_handler::<Group>))
        .route("/bulk-delete", post(bulk_delete_handler::<Group>))
}
