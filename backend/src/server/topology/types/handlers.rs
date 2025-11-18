use crate::server::shared::storage::traits::StorableEntity;
use crate::server::{
    shared::handlers::traits::CrudHandlers,
    topology::{service::main::TopologyService, types::base::Topology},
};

impl CrudHandlers for Topology {
    type Service = TopologyService;

    fn get_service(state: &crate::server::config::AppState) -> &Self::Service {
        &state.services.topology_service
    }

    fn entity_name() -> &'static str {
        Self::table_name()
    }

    fn validate(&self) -> Result<(), String> {
        Ok(())
    }
}
