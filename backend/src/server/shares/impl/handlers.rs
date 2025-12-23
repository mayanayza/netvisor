use crate::server::{
    config::AppState,
    shared::handlers::{query::NetworkFilterQuery, traits::CrudHandlers},
    shares::{r#impl::base::Share, service::ShareService},
};

impl CrudHandlers for Share {
    type Service = ShareService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.share_service
    }
}
