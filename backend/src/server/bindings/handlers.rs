use crate::server::{
    bindings::{r#impl::base::Binding, service::BindingService},
    config::AppState,
    shared::handlers::{
        query::{NetworkFilterQuery, ServiceIdQuery},
        traits::{ChildCrudHandlers, CrudHandlers},
    },
};

impl CrudHandlers for Binding {
    type Service = BindingService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.binding_service
    }
}

impl ChildCrudHandlers for Binding {
    type ParentQuery = ServiceIdQuery;
}
