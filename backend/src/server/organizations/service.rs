use crate::server::{
    organizations::r#impl::base::Organization,
    shared::{services::traits::CrudService, storage::generic::GenericPostgresStorage},
};
use async_trait::async_trait;
use std::sync::Arc;

pub struct OrganizationService {
    storage: Arc<GenericPostgresStorage<Organization>>,
}

#[async_trait]
impl CrudService<Organization> for OrganizationService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Organization>> {
        &self.storage
    }
}

impl OrganizationService {
    pub fn new(storage: Arc<GenericPostgresStorage<Organization>>) -> Self {
        Self { storage }
    }
}
