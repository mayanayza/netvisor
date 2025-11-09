use crate::server::api_keys::r#impl::base::ApiKey;
use crate::server::api_keys::service::ApiKeyService;
use crate::server::shared::handlers::traits::CrudHandlers;

impl CrudHandlers for ApiKey {
    type Service = ApiKeyService;

    fn get_service(state: &crate::server::config::AppState) -> &Self::Service {
        &state.services.api_key_service
    }
}
