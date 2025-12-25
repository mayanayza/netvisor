use crate::server::{
    config::AppState,
    organizations::{r#impl::base::Organization, service::OrganizationService},
    shared::handlers::{query::NoFilterQuery, traits::CrudHandlers},
};

impl CrudHandlers for Organization {
    type Service = OrganizationService;
    type FilterQuery = NoFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.organization_service
    }

    fn preserve_immutable_fields(&mut self, existing: &Self) {
        // Billing fields are managed by Stripe integration, not user-editable
        self.base.stripe_customer_id = existing.base.stripe_customer_id.clone();
        self.base.plan = existing.base.plan;
        self.base.plan_status = existing.base.plan_status.clone();
        // Onboarding state is server-managed
        self.base.onboarding = existing.base.onboarding.clone();
    }
}
