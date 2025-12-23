use crate::server::{
    config::AppState,
    ports::{r#impl::base::Port, service::PortService},
    shared::handlers::{
        query::{HostIdQuery, NetworkFilterQuery},
        traits::{ChildCrudHandlers, CrudHandlers},
    },
};

impl CrudHandlers for Port {
    type Service = PortService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.port_service
    }
}

impl ChildCrudHandlers for Port {
    type ParentQuery = HostIdQuery;
}
