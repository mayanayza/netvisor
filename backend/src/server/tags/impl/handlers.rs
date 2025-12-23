use crate::server::{
    config::AppState,
    shared::handlers::{query::NetworkFilterQuery, traits::CrudHandlers},
    tags::{r#impl::base::Tag, service::TagService},
};

impl CrudHandlers for Tag {
    type Service = TagService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.tag_service
    }
}
