use uuid::Uuid;

use crate::server::{ports::r#impl::base::Port, shared::storage::child::ChildStorableEntity};

impl ChildStorableEntity for Port {
    fn parent_column() -> &'static str {
        "host_id"
    }

    fn parent_id(&self) -> Uuid {
        self.base.host_id
    }
}
