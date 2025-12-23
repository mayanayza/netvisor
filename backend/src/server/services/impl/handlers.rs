use crate::server::{
    config::AppState,
    services::{r#impl::base::Service, service::ServiceService},
    shared::handlers::{
        query::{HostIdQuery, NetworkFilterQuery},
        traits::{ChildCrudHandlers, CrudHandlers},
    },
};

impl CrudHandlers for Service {
    type Service = ServiceService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.service_service
    }
}

impl ChildCrudHandlers for Service {
    type ParentQuery = HostIdQuery;
}
