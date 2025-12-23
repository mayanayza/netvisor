use crate::server::{
    config::AppState,
    invites::{r#impl::base::Invite, service::InviteService},
    shared::handlers::{query::OrganizationFilterQuery, traits::CrudHandlers},
};

impl CrudHandlers for Invite {
    type Service = InviteService;
    type FilterQuery = OrganizationFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.invite_service
    }
}
