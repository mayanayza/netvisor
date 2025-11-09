use async_trait::async_trait;
use std::sync::Arc;

use crate::server::{
    groups::r#impl::base::Group,
    shared::{services::traits::CrudService, storage::generic::GenericPostgresStorage},
};

pub struct GroupService {
    group_storage: Arc<GenericPostgresStorage<Group>>,
}

#[async_trait]
impl CrudService<Group> for GroupService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Group>> {
        &self.group_storage
    }
}

impl GroupService {
    pub fn new(group_storage: Arc<GenericPostgresStorage<Group>>) -> Self {
        Self { group_storage }
    }
}
