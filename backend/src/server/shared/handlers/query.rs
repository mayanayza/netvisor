use serde::Deserialize;
use serde::de::DeserializeOwned;
use utoipa::IntoParams;
use uuid::Uuid;

use crate::server::shared::storage::filter::EntityFilter;

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
#[derive(Deserialize, Default, Debug, Clone, IntoParams)]
pub struct NetworkFilterQuery {
    /// Filter by network ID
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

/// Empty filter query for entities that are scoped to org (or are the org itself) and don't support further filtering by query param
#[derive(Deserialize, Default, Debug, Clone, IntoParams)]
pub struct NoFilterQuery {}

impl FilterQueryExtractor for NoFilterQuery {
    fn apply_to_filter(
        &self,
        filter: EntityFilter,
        _user_network_ids: &[Uuid],
        _user_organization_id: Uuid,
    ) -> EntityFilter {
        // Don't apply additional filters (network_id / org_id permissioning is taken care of in handler)
        filter
    }
}

/// Query for filtering by group_id (used by GroupBinding).
#[derive(Deserialize, Default, Debug, Clone, IntoParams)]
pub struct GroupIdQuery {
    /// Filter by group ID
    pub group_id: Uuid,
    /// Filter by network ID
    pub network_id: Uuid
}

// ============================================================================
// Combined query types for child entities with network filtering
// ============================================================================

/// Query for filtering ports by host_id and/or network_id.
#[derive(Deserialize, Default, Debug, Clone, IntoParams)]
pub struct HostChildQuery {
    /// Filter by host ID
    pub host_id: Option<Uuid>,
    /// Filter by network ID
    pub network_id: Option<Uuid>,
}

impl FilterQueryExtractor for HostChildQuery {
    fn apply_to_filter(
        &self,
        filter: EntityFilter,
        user_network_ids: &[Uuid],
        _user_organization_id: Uuid,
    ) -> EntityFilter {
        let filter = match self.network_id {
            Some(id) if user_network_ids.contains(&id) => filter.network_ids(&[id]),
            Some(_) => filter.network_ids(&[]),
            None => filter.network_ids(user_network_ids),
        };
        match self.host_id {
            Some(id) => filter.host_id(&id),
            None => filter,
        }
    }
}

/// Query for filtering bindings by service_id and/or network_id.
#[derive(Deserialize, Default, Debug, Clone, IntoParams)]
pub struct BindingQuery {
    /// Filter by service ID
    pub service_id: Option<Uuid>,
    /// Filter by network ID
    pub network_id: Option<Uuid>,
    /// Filter by port ID
    pub port_id: Option<Uuid>,
    /// Filter by interface ID
    pub interface_id: Option<Uuid>
}

impl FilterQueryExtractor for BindingQuery {
    fn apply_to_filter(
        &self,
        filter: EntityFilter,
        user_network_ids: &[Uuid],
        _user_organization_id: Uuid,
    ) -> EntityFilter {
        let mut filter = match self.network_id {
            Some(id) if user_network_ids.contains(&id) => filter.network_ids(&[id]),
            Some(_) => filter.network_ids(&[]),
            None => filter.network_ids(user_network_ids),
        };
        filter = match self.service_id {
            Some(id) => filter.service_id(&id),
            None => filter,
        };
        filter = match self.port_id {
            Some(id) => filter.uuid_column("port_id", &id),
            None => filter,
        };
        filter = match self.interface_id {
            Some(id) => filter.uuid_column("interface_id", &id),
            None => filter
        };

        filter
    }
}

/// Query for filtering interfaces by host_id, subnet_id, and/or network_id.
#[derive(Deserialize, Default, Debug, Clone, IntoParams)]
pub struct InterfaceQuery {
    /// Filter by host ID
    pub host_id: Option<Uuid>,
    /// Filter by subnet ID
    pub subnet_id: Option<Uuid>,
    /// Filter by network ID
    pub network_id: Option<Uuid>,
}

impl FilterQueryExtractor for InterfaceQuery {
    fn apply_to_filter(
        &self,
        filter: EntityFilter,
        user_network_ids: &[Uuid],
        _user_organization_id: Uuid,
    ) -> EntityFilter {
        let mut filter = match self.network_id {
            Some(id) if user_network_ids.contains(&id) => filter.network_ids(&[id]),
            Some(_) => filter.network_ids(&[]),
            None => filter.network_ids(user_network_ids),
        };
        filter = match self.subnet_id {
            Some(id) => filter.subnet_id(&id),
            None => filter,
        };
        filter = match self.host_id {
            Some(id) => filter.host_id(&id),
            None => filter,
        };
        
        filter
    }
}

/// Query for filtering discoveries by network_id or daemon_id
#[derive(Deserialize, Default, Debug, Clone, IntoParams)]
pub struct DiscoveryQuery {
    /// Filter by network ID
    pub network_id: Option<Uuid>,
    /// Filter by daemon ID
    pub daemon_id: Option<Uuid>,
}

impl FilterQueryExtractor for DiscoveryQuery {
    fn apply_to_filter(
        &self,
        filter: EntityFilter,
        user_network_ids: &[Uuid],
        _user_organization_id: Uuid,
    ) -> EntityFilter {
        let mut filter = match self.network_id {
            Some(id) if user_network_ids.contains(&id) => filter.network_ids(&[id]),
            Some(_) => filter.network_ids(&[]),
            None => filter.network_ids(user_network_ids),
        };
        filter = match self.daemon_id {
            Some(id) => filter.uuid_column("daemon_id", &id),
            None => filter,
        };
        
        filter
    }
}
