use crate::server::{
    config::AppState,
    invites::{r#impl::base::Invite, service::InviteService},
    shared::handlers::{query::NoFilterQuery, traits::CrudHandlers},
};

impl CrudHandlers for Invite {
    type Service = InviteService;
    type FilterQuery = NoFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.invite_service
    }
}
