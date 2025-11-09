use crate::server::daemons::r#impl::base::Daemon;
use crate::server::daemons::service::DaemonService;
use crate::server::shared::handlers::traits::CrudHandlers;

impl CrudHandlers for Daemon {
    type Service = DaemonService;

    fn get_service(state: &crate::server::config::AppState) -> &Self::Service {
        &state.services.daemon_service
    }
}
