use crate::server::{
    services::{r#impl::base::Service, service::ServiceService},
    shared::handlers::traits::CrudHandlers,
};

impl CrudHandlers for Service {
    type Service = ServiceService;

    fn get_service(state: &crate::server::config::AppState) -> &Self::Service {
        &state.services.service_service
    }
}
