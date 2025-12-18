use crate::server::{
    invites::{r#impl::base::Invite, service::InviteService},
    shared::handlers::traits::CrudHandlers,
};

impl CrudHandlers for Invite {
    type Service = InviteService;

    fn get_service(state: &crate::server::config::AppState) -> &Self::Service {
        &state.services.invite_service
    }
}
