use crate::server::discovery::r#impl::base::Discovery;
use crate::server::discovery::service::DiscoveryService;
use crate::server::shared::handlers::traits::CrudHandlers;

impl CrudHandlers for Discovery {
    type Service = DiscoveryService;

    fn get_service(state: &crate::server::config::AppState) -> &Self::Service {
        &state.services.discovery_service
    }
}
