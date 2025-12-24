use crate::server::{
    config::AppState,
    groups::{r#impl::base::Group, service::GroupService},
    shared::{
        handlers::{query::NetworkFilterQuery, traits::CrudHandlers},
        types::entities::EntitySource,
    },
};

impl CrudHandlers for Group {
    type Service = GroupService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.group_service
    }

    fn set_source(&mut self, source: EntitySource) {
        self.base.source = source;
    }
}
