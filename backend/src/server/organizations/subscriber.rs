use anyhow::Error;
use async_trait::async_trait;

use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    organizations::service::OrganizationService,
    shared::{
        events::{
            bus::{EventFilter, EventSubscriber},
            types::Event,
        },
        services::traits::CrudService,
    },
};

#[async_trait]
impl EventSubscriber for OrganizationService {
    fn event_filter(&self) -> EventFilter {
        EventFilter::telemetry_only(None)
    }

    async fn handle_events(&self, events: Vec<Event>) -> Result<(), Error> {
        if events.is_empty() {
            return Ok(());
        }

        for event in events {
            if let Event::Telemetry(event) = event {
                let is_onboarding_step = event
                    .metadata
                    .get("is_onboarding_step")
                    .and_then(|v| serde_json::from_value::<bool>(v.clone()).ok())
                    .unwrap_or(false);

                if let Some(mut organization) = self.get_by_id(&event.organization_id).await?
                    && is_onboarding_step
                    && organization.not_onboarded(&event.operation)
                {
                    organization.base.onboarding.push(event.operation);
                    self.update(&mut organization, AuthenticatedEntity::System)
                        .await?;
                }
            }
        }

        Ok(())
    }

    fn name(&self) -> &str {
        "organization_onboarding"
    }
}
