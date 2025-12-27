use crate::server::{
    config::AppState,
    discovery::{r#impl::base::Discovery, service::DiscoveryService},
    shared::handlers::{query::DiscoveryQuery, traits::CrudHandlers},
};
use uuid::Uuid;

impl CrudHandlers for Discovery {
    type Service = DiscoveryService;
    type FilterQuery = DiscoveryQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.discovery_service
    }

    fn get_tags(&self) -> Option<&Vec<Uuid>> {
        Some(&self.base.tags)
    }

    fn set_tags(&mut self, tags: Vec<Uuid>) {
        self.base.tags = tags;
    }
}
