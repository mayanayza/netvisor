use crate::server::{
    shared::handlers::traits::CrudHandlers,
    users::{r#impl::base::User, service::UserService},
};

impl CrudHandlers for User {
    type Service = UserService;

    fn get_service(state: &crate::server::config::AppState) -> &Self::Service {
        &state.services.user_service
    }
}
