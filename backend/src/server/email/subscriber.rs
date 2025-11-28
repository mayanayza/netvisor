use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    email::traits::EmailService,
    shared::events::{
        bus::{EventFilter, EventSubscriber},
        types::Event,
    },
};
use anyhow::Error;
use async_trait::async_trait;
use serde_json::Value;
use std::collections::HashMap;

#[async_trait]
impl EventSubscriber for EmailService {
    fn event_filter(&self) -> EventFilter {
        // All telemetry events
        EventFilter::telemetry_only(None)
    }

    async fn handle_events(&self, events: Vec<Event>) -> Result<(), Error> {
        if events.is_empty() {
            return Ok(());
        }

        for event in events {
            if let Event::Telemetry(e) = event
                && let AuthenticatedEntity::User { email, .. } = e.authentication
            {
                let mut metadata_map: HashMap<String, Value> = serde_json::from_value(e.metadata)?;

                let subscribed = metadata_map
                    .remove("subscribed")
                    .map(|v| serde_json::from_value::<bool>(v).unwrap_or(false))
                    .unwrap_or(false);

                let metadata = serde_json::to_value(metadata_map)?;

                self.track_event(
                    e.operation.to_string().to_lowercase(),
                    email,
                    subscribed,
                    metadata,
                )
                .await?;
            }
        }

        Ok(())
    }

    fn name(&self) -> &str {
        "email_triggers"
    }
}
