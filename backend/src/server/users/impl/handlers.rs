use crate::server::{
    config::AppState,
    shared::handlers::{query::OrganizationFilterQuery, traits::CrudHandlers},
    users::{r#impl::base::User, service::UserService},
};

impl CrudHandlers for User {
    type Service = UserService;
    type FilterQuery = OrganizationFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.user_service
    }
}
