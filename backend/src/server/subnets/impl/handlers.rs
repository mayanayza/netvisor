use crate::server::{
    config::AppState,
    shared::{
        handlers::{query::NetworkFilterQuery, traits::CrudHandlers},
        types::entities::EntitySource,
    },
    subnets::{r#impl::base::Subnet, service::SubnetService},
};

impl CrudHandlers for Subnet {
    type Service = SubnetService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.subnet_service
    }

    fn set_source(&mut self, source: EntitySource) {
        self.base.source = source;
    }
}
