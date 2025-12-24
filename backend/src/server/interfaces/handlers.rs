use crate::server::interfaces::r#impl::base::Interface;
use crate::server::{
    config::AppState,
};
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};

// Generated handlers for most CRUD operations
mod generated {
    use super::*;
    crate::crud_get_by_id_handler!(Interface, "interfaces", "interface");
    crate::crud_get_all_handler!(Interface, "interfaces", "interface");
    crate::crud_create_handler!(Interface, "interfaces", "interface");
    crate::crud_update_handler!(Interface, "interfaces", "interface");
    crate::crud_delete_handler!(Interface, "interfaces", "interface");
    crate::crud_bulk_delete_handler!(Interface, "interfaces");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(generated::get_all, generated::create))
        .routes(routes!(generated::get_by_id, generated::update, generated::delete))
        .routes(routes!(generated::bulk_delete))
}
