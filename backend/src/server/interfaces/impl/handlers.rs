use crate::server::{
    config::AppState,
    interfaces::{r#impl::base::Interface, service::InterfaceService},
    shared::handlers::{
        query::{HostIdQuery, NetworkFilterQuery},
        traits::{ChildCrudHandlers, CrudHandlers},
    },
};

impl CrudHandlers for Interface {
    type Service = InterfaceService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.interface_service
    }
}

impl ChildCrudHandlers for Interface {
    type ParentQuery = HostIdQuery;
}
