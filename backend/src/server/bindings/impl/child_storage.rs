use uuid::Uuid;

use crate::server::{bindings::r#impl::base::Binding, shared::storage::child::ChildStorableEntity};

impl ChildStorableEntity for Binding {
    fn parent_column() -> &'static str {
        "service_id"
    }

    fn parent_id(&self) -> Uuid {
        self.service_id()
    }
}
