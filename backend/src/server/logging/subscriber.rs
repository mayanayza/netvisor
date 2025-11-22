use anyhow::Error;
use async_trait::async_trait;

use crate::server::{
    logging::service::LoggingService,
    shared::events::{
        bus::{EventFilter, EventSubscriber},
        types::Event,
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
            event.log();
            tracing::debug!("{}", event);
        }

        Ok(())
    }

    fn debounce_window_ms(&self) -> u64 {
        0 // No batching for logging - we want immediate logs
    }

    fn name(&self) -> &str {
        "logging"
    }
}
