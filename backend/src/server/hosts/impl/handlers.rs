use crate::server::{
    config::AppState,
    hosts::{r#impl::base::Host, service::HostService},
    shared::handlers::{query::NetworkFilterQuery, traits::CrudHandlers},
};

impl CrudHandlers for Host {
    type Service = HostService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.host_service
    }
}
