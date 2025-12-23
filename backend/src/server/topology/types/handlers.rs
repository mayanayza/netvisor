use crate::server::{
    config::AppState,
    shared::{
        handlers::{query::NetworkFilterQuery, traits::CrudHandlers},
        storage::traits::StorableEntity,
    },
    topology::{service::main::TopologyService, types::base::Topology},
};

impl CrudHandlers for Topology {
    type Service = TopologyService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.topology_service
    }

    fn entity_name() -> &'static str {
        Self::table_name()
    }

    fn validate(&self) -> Result<(), String> {
        Ok(())
    }
}
