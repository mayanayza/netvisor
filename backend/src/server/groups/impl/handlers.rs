use crate::server::{
    config::AppState,
    groups::{r#impl::base::Group, service::GroupService},
    shared::{
        handlers::{query::NetworkFilterQuery, traits::CrudHandlers},
        types::entities::EntitySource,
    },
};
use uuid::Uuid;

impl CrudHandlers for Group {
    type Service = GroupService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.group_service
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
