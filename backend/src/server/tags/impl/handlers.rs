use crate::server::{
    shared::handlers::traits::CrudHandlers,
    tags::{r#impl::base::Tag, service::TagService},
};

impl CrudHandlers for Tag {
    type Service = TagService;

    fn get_service(state: &crate::server::config::AppState) -> &Self::Service {
        &state.services.tag_service
    }
}
