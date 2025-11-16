use crate::server::{
    organizations::{r#impl::base::Organization, service::OrganizationService},
    shared::handlers::traits::CrudHandlers,
};

impl CrudHandlers for Organization {
    type Service = OrganizationService;

    fn get_service(state: &crate::server::config::AppState) -> &Self::Service {
        &state.services.organization_service
    }
}
