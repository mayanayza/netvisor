use crate::server::{
    api_keys::{r#impl::base::ApiKey, service::ApiKeyService},
    config::AppState,
    shared::handlers::{query::NetworkFilterQuery, traits::CrudHandlers},
};

impl CrudHandlers for ApiKey {
    type Service = ApiKeyService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.api_key_service
    }
}
