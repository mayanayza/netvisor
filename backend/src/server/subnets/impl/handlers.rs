use crate::server::{
    shared::handlers::traits::CrudHandlers,
    subnets::{r#impl::base::Subnet, service::SubnetService},
};

impl CrudHandlers for Subnet {
    type Service = SubnetService;

    fn get_service(state: &crate::server::config::AppState) -> &Self::Service {
        &state.services.subnet_service
    }
}
