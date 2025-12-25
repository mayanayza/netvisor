use crate::server::{
    config::AppState,
    shared::handlers::{query::NoFilterQuery, traits::CrudHandlers},
    users::{r#impl::base::User, service::UserService},
};

impl CrudHandlers for User {
    type Service = UserService;
    type FilterQuery = NoFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.user_service
    }

    fn preserve_immutable_fields(&mut self, existing: &Self) {
        // terms_accepted_at is set when user accepts terms, cannot be changed
        self.base.terms_accepted_at = existing.base.terms_accepted_at;
    }
}
