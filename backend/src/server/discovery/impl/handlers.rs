use crate::server::{
    config::AppState,
    discovery::{r#impl::base::Discovery, service::DiscoveryService},
    shared::handlers::{query::NetworkFilterQuery, traits::CrudHandlers},
};

impl CrudHandlers for Discovery {
    type Service = DiscoveryService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.discovery_service
    }
}
