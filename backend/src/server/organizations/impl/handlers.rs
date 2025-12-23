use crate::server::{
    config::AppState,
    organizations::{r#impl::base::Organization, service::OrganizationService},
    shared::handlers::{query::OrganizationEntityFilterQuery, traits::CrudHandlers},
};

impl CrudHandlers for Organization {
    type Service = OrganizationService;
    type FilterQuery = OrganizationEntityFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.organization_service
    }
}
