use crate::server::{
    groups::{r#impl::base::Group, service::GroupService},
    shared::handlers::traits::CrudHandlers,
};

impl CrudHandlers for Group {
    type Service = GroupService;

    fn get_service(state: &crate::server::config::AppState) -> &Self::Service {
        &state.services.group_service
    }
}
