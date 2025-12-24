use crate::server::{
    config::AppState,
    daemons::{r#impl::base::Daemon, service::DaemonService},
    shared::handlers::{query::HostChildQuery, traits::CrudHandlers},
};

impl CrudHandlers for Daemon {
    type Service = DaemonService;
    type FilterQuery = HostChildQuery;

    fn get_service(state: &AppState) -> &Self::Service {
        &state.services.daemon_service
    }
}
