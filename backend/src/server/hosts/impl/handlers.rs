use crate::server::{
    hosts::{r#impl::base::Host, service::HostService},
    shared::handlers::traits::CrudHandlers,
};

impl CrudHandlers for Host {
    type Service = HostService;

    fn get_service(state: &crate::server::config::AppState) -> &Self::Service {
        &state.services.host_service
    }
}
