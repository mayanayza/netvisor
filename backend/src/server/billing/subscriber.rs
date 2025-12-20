use std::collections::HashMap;

use anyhow::Error;
use async_trait::async_trait;

use crate::server::{
    billing::service::BillingService,
    shared::{
        entities::{Entity, EntityDiscriminants},
        events::{
            bus::{EventFilter, EventSubscriber},
            types::{EntityOperation, Event},
        },
        services::traits::CrudService,
        storage::filter::EntityFilter,
    },
};

#[async_trait]
impl EventSubscriber for BillingService {
    fn event_filter(&self) -> EventFilter {
        EventFilter::entity_only(HashMap::from([
            (
                EntityDiscriminants::Network,
                Some(vec![EntityOperation::Created, EntityOperation::Deleted]),
            ),
            (
                EntityDiscriminants::User,
                Some(vec![EntityOperation::Created, EntityOperation::Deleted]),
            ),
        ]))
    }

    async fn handle_events(&self, events: Vec<Event>) -> Result<(), Error> {
        if events.is_empty() {
            return Ok(());
        }

        for event in events {
            if let Event::Entity(e) = event
                && let Some(org_id) = if let Some(org_id) = e.organization_id {
                    Some(org_id)
                } else if let Some(network_id) = e.network_id {
                    self.network_service
                        .get_by_id(&network_id)
                        .await?
                        .map(|n| n.base.organization_id)
                } else {
                    None
                }
                && let Some(org) = self.organization_service.get_by_id(&org_id).await?
            {
                match e.entity_type {
                    Entity::Network(_) | Entity::User(_) => {
                        let filter = EntityFilter::unfiltered().organization_id(&org_id);

                        let network_count =
                            self.network_service.get_all(filter.clone()).await?.len();

                        let seat_count = self.user_service.get_all(filter).await?.len();

                        // When user has just been created org won't yet have a billing plan
                        if org.base.plan.is_none() {
                            continue;
                        }

                        self.update_addon_prices(org, network_count as u64, seat_count as u64)
                            .await?;
                    }
                    _ => (),
                }
            }
        }

        Ok(())
    }

    fn name(&self) -> &str {
        "billing_quota_update"
    }
}
