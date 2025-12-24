use crate::server::{
    config::AppState,
    ports::{r#impl::base::Port, service::PortService},
    shared::handlers::{
        query::HostChildQuery,
        traits::CrudHandlers,
    },
};
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};

impl CrudHandlers for Port {
    type Service = PortService;
    type FilterQuery = HostChildQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.port_service
    }
}

mod generated {
    use super::*;
    crate::crud_get_all_handler!(Port, "ports", "port");
    crate::crud_get_by_id_handler!(Port, "ports", "port");
    crate::crud_create_handler!(Port, "ports", "port");
    crate::crud_update_handler!(Port, "ports", "port");
    crate::crud_delete_handler!(Port, "ports", "port");
    crate::crud_bulk_delete_handler!(Port, "ports");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(generated::get_all, generated::create))
        .routes(routes!(generated::get_by_id, generated::update, generated::delete))
        .routes(routes!(generated::bulk_delete))
}
