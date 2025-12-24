use crate::server::{
    config::AppState,
    discovery::{r#impl::base::Discovery, service::DiscoveryService},
    shared::handlers::{query::DiscoveryQuery, traits::CrudHandlers},
};

impl CrudHandlers for Discovery {
    type Service = DiscoveryService;
    type FilterQuery = DiscoveryQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.discovery_service
    }
}
