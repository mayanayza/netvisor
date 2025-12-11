use anyhow::Error;
use async_trait::async_trait;

use crate::server::{
    logging::service::LoggingService,
    shared::events::{
        bus::{EventFilter, EventSubscriber},
        types::{Event, EventLogLevel},
    },
};

#[async_trait]
impl EventSubscriber for LoggingService {
    fn event_filter(&self) -> EventFilter {
        EventFilter::all()
    }

    async fn handle_events(&self, events: Vec<Event>) -> Result<(), Error> {
        // Log each event individually
        for event in events {
            let suppress_logs = event
                .metadata()
                .get("suppress_logs")
                .and_then(|v| serde_json::from_value::<bool>(v.clone()).ok())
                .unwrap_or(false);

            if !suppress_logs {
                match event.operation().log_level() {
                    EventLogLevel::Error => {
                        tracing::error!("{}", event);
                    }
                    EventLogLevel::Warn => {
                        tracing::warn!("{}", event);
                    }
                    EventLogLevel::Info => {
                        tracing::info!("{}", event);
                    }
                    EventLogLevel::Debug => {
                        tracing::debug!("{}", event);
                    }
                    EventLogLevel::Trace => {
                        tracing::trace!("{}", event);
                    }
                }
            }
        }

        Ok(())
    }

    fn name(&self) -> &str {
        "logging"
    }
}
