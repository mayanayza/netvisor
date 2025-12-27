use crate::server::{
    config::AppState,
    hosts::{r#impl::base::Host, service::HostService},
    shared::{
        handlers::{query::NetworkFilterQuery, traits::CrudHandlers},
        types::entities::EntitySource,
    },
};
use uuid::Uuid;

impl CrudHandlers for Host {
    type Service = HostService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.host_service
    }

    fn set_source(&mut self, source: EntitySource) {
        self.base.source = source;
    }

    fn preserve_immutable_fields(&mut self, existing: &Self) {
        // source is set at creation time (Manual or Discovery), cannot be changed
        self.base.source = existing.base.source.clone();
    }

    fn get_tags(&self) -> Option<&Vec<Uuid>> {
        Some(&self.base.tags)
    }

    fn set_tags(&mut self, tags: Vec<Uuid>) {
        self.base.tags = tags;
    }
}
