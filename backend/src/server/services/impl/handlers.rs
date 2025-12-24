use crate::server::{
    config::AppState,
    services::{r#impl::base::Service, service::ServiceService},
    shared::{
        handlers::{
            query::{HostChildQuery},
            traits::{CrudHandlers},
        },
        types::entities::EntitySource,
    },
};

impl CrudHandlers for Service {
    type Service = ServiceService;
    type FilterQuery = HostChildQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.service_service
    }

    fn set_source(&mut self, source: EntitySource) {
        self.base.source = source;
    }
}