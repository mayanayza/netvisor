use crate::server::{
    bindings::{r#impl::base::Binding, service::BindingService},
    config::AppState,
    shared::handlers::{
        query::BindingQuery,
        traits::CrudHandlers,
    },
};
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};

impl CrudHandlers for Binding {
    type Service = BindingService;
    type FilterQuery = BindingQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.binding_service
    }
}

mod generated {
    use super::*;
    crate::crud_get_all_handler!(Binding, "bindings", "binding");
    crate::crud_get_by_id_handler!(Binding, "bindings", "binding");
    crate::crud_create_handler!(Binding, "bindings", "binding");
    crate::crud_update_handler!(Binding, "bindings", "binding");
    crate::crud_delete_handler!(Binding, "bindings", "binding");
    crate::crud_bulk_delete_handler!(Binding, "bindings");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(generated::get_all, generated::create))
        .routes(routes!(generated::get_by_id, generated::update, generated::delete))
        .routes(routes!(generated::bulk_delete))
}
