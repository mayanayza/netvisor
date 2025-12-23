use serde::Deserialize;
use serde::de::DeserializeOwned;
use uuid::Uuid;

use crate::server::shared::storage::filter::EntityFilter;

/// Trait for query structs that can extract a parent ID for child entity filtering.
pub trait ParentQueryExtractor: DeserializeOwned + Send + Sync + Default {
    fn parent_id(&self) -> Option<Uuid>;
}

/// Trait for query structs that filter entities by network or organization.
pub trait FilterQueryExtractor: DeserializeOwned + Send + Sync + Default {
    /// Apply query parameters to the filter, respecting user's access permissions.
    fn apply_to_filter(
        &self,
        filter: EntityFilter,
        user_network_ids: &[Uuid],
        user_organization_id: Uuid,
    ) -> EntityFilter;
}

// ============================================================================
// Standard filter query types for CrudHandlers
// ============================================================================

/// Filter query for entities keyed by network_id.
/// Allows filtering to a specific network the user has access to.
#[derive(Deserialize, Default, Debug, Clone)]
pub struct NetworkFilterQuery {
    pub network_id: Option<Uuid>,
}

impl FilterQueryExtractor for NetworkFilterQuery {
    fn apply_to_filter(
        &self,
        filter: EntityFilter,
        user_network_ids: &[Uuid],
        _user_organization_id: Uuid,
    ) -> EntityFilter {
        match self.network_id {
            Some(id) if user_network_ids.contains(&id) => filter.network_ids(&[id]),
            Some(_) => filter.network_ids(&[]), // User doesn't have access - return empty
            None => filter.network_ids(user_network_ids),
        }
    }
}

/// Filter query for entities keyed by organization_id.
/// Allows filtering to the user's organization.
#[derive(Deserialize, Default, Debug, Clone)]
pub struct OrganizationFilterQuery {
    pub organization_id: Option<Uuid>,
}

impl FilterQueryExtractor for OrganizationFilterQuery {
    fn apply_to_filter(
        &self,
        filter: EntityFilter,
        _user_network_ids: &[Uuid],
        user_organization_id: Uuid,
    ) -> EntityFilter {
        match self.organization_id {
            Some(id) if id == user_organization_id => filter.organization_id(&id),
            Some(_) => filter.organization_id(&Uuid::nil()), // User doesn't have access
            None => filter.organization_id(&user_organization_id),
        }
    }
}

/// Empty filter query for entities that don't support query filtering.
/// Defaults to filtering by user's network_ids.
#[derive(Deserialize, Default, Debug, Clone)]
pub struct NoFilterQuery {}

impl FilterQueryExtractor for NoFilterQuery {
    fn apply_to_filter(
        &self,
        filter: EntityFilter,
        user_network_ids: &[Uuid],
        _user_organization_id: Uuid,
    ) -> EntityFilter {
        // Default to network filtering for backwards compatibility
        filter.network_ids(user_network_ids)
    }
}

/// Filter query for the Organization entity itself.
/// Filters by id = user's organization_id (since Organization doesn't have an organization_id column).
#[derive(Deserialize, Default, Debug, Clone)]
pub struct OrganizationEntityFilterQuery {}

impl FilterQueryExtractor for OrganizationEntityFilterQuery {
    fn apply_to_filter(
        &self,
        filter: EntityFilter,
        _user_network_ids: &[Uuid],
        user_organization_id: Uuid,
    ) -> EntityFilter {
        // Filter to only the user's own organization
        filter.entity_id(&user_organization_id)
    }
}

// ============================================================================
// Parent query types for ChildCrudHandlers
// ============================================================================

/// Query for filtering by host_id (used by Port, Interface, Service).
#[derive(Deserialize, Default, Debug, Clone)]
pub struct HostIdQuery {
    pub host_id: Option<Uuid>,
}

impl ParentQueryExtractor for HostIdQuery {
    fn parent_id(&self) -> Option<Uuid> {
        self.host_id
    }
}

/// Query for filtering by service_id (used by Binding).
#[derive(Deserialize, Default, Debug, Clone)]
pub struct ServiceIdQuery {
    pub service_id: Option<Uuid>,
}

impl ParentQueryExtractor for ServiceIdQuery {
    fn parent_id(&self) -> Option<Uuid> {
        self.service_id
    }
}

/// Query for filtering by subnet_id (used by Interface when filtering by subnet).
#[derive(Deserialize, Default, Debug, Clone)]
pub struct SubnetIdQuery {
    pub subnet_id: Option<Uuid>,
}

impl ParentQueryExtractor for SubnetIdQuery {
    fn parent_id(&self) -> Option<Uuid> {
        self.subnet_id
    }
}

/// Query for filtering by group_id (used by GroupBinding).
#[derive(Deserialize, Default, Debug, Clone)]
pub struct GroupIdQuery {
    pub group_id: Option<Uuid>,
}

impl ParentQueryExtractor for GroupIdQuery {
    fn parent_id(&self) -> Option<Uuid> {
        self.group_id
    }
}

// ============================================================================
// Macro for defining custom parent queries
// ============================================================================

/// Macro to define a parent query struct for child entities.
///
/// # Example
/// ```ignore
/// define_parent_query!(MyEntityParentQuery, my_parent_id);
/// ```
#[macro_export]
macro_rules! define_parent_query {
    ($name:ident, $field:ident) => {
        #[derive(serde::Deserialize, Default, Debug, Clone)]
        pub struct $name {
            pub $field: Option<uuid::Uuid>,
        }

        impl $crate::server::shared::handlers::query::ParentQueryExtractor for $name {
            fn parent_id(&self) -> Option<uuid::Uuid> {
                self.$field
            }
        }
    };
}

pub use define_parent_query;
