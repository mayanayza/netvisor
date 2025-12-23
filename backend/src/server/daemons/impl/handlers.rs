use crate::server::{
    config::AppState,
    daemons::{r#impl::base::Daemon, service::DaemonService},
    shared::handlers::{query::NetworkFilterQuery, traits::CrudHandlers},
};

impl CrudHandlers for Daemon {
    type Service = DaemonService;
    type FilterQuery = NetworkFilterQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.daemon_service
    }
}
