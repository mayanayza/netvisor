use crate::server::auth::middleware::AuthenticatedEntity;
use crate::server::billing::types::base::BillingPlan;
use crate::server::networks::service::NetworkService;
use crate::server::organizations::service::OrganizationService;
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::types::metadata::TypeMetadataProvider;
use crate::server::users::r#impl::permissions::UserOrgPermissions;
use crate::server::users::service::UserService;
use anyhow::Error;
use anyhow::anyhow;
use std::sync::Arc;
use std::sync::OnceLock;
use stripe::Client;
use stripe_billing::billing_portal_session::CreateBillingPortalSession;
use stripe_billing::{Subscription, SubscriptionStatus};
use stripe_checkout::checkout_session::CreateCheckoutSessionCustomerUpdate;
use stripe_checkout::checkout_session::CreateCheckoutSessionCustomerUpdateAddress;
use stripe_checkout::checkout_session::CreateCheckoutSessionCustomerUpdateName;
use stripe_checkout::checkout_session::CreateCheckoutSessionSubscriptionData;
use stripe_checkout::checkout_session::{
    CreateCheckoutSession, CreateCheckoutSessionLineItems, CreateCheckoutSessionTaxIdCollection,
};
use stripe_checkout::{
    CheckoutSession, CheckoutSessionBillingAddressCollection, CheckoutSessionMode,
};
use stripe_core::customer::CreateCustomer;
use stripe_core::{CustomerId, EventType};
use stripe_product::Price;
use stripe_product::price::CreatePriceRecurring;
use stripe_product::price::SearchPrice;
use stripe_product::price::{CreatePrice, CreatePriceRecurringUsageType};
use stripe_product::product::{CreateProduct, RetrieveProduct};
use stripe_webhook::{EventObject, Webhook};
use uuid::Uuid;
pub struct BillingService {
    pub stripe: stripe::Client,
    pub webhook_secret: String,
    pub organization_service: Arc<OrganizationService>,
    pub user_service: Arc<UserService>,
    pub network_service: Arc<NetworkService>,
    pub plans: OnceLock<Vec<BillingPlan>>,
}

impl BillingService {
    pub fn new(
        stripe_secret: String,
        webhook_secret: String,
        organization_service: Arc<OrganizationService>,
        user_service: Arc<UserService>,
        network_service: Arc<NetworkService>,
    ) -> Self {
        Self {
            stripe: Client::new(stripe_secret),
            webhook_secret,
            organization_service,
            network_service,
            user_service,
            plans: OnceLock::new(),
        }
    }

    pub fn get_plans(&self) -> Vec<BillingPlan> {
        self.plans.get().map(|v| v.to_vec()).unwrap_or_default()
    }

    pub async fn get_price_from_lookup_key(
        &self,
        lookup_key: String,
    ) -> Result<Option<Price>, Error> {
        let price = SearchPrice::new(format!("lookup_key: \"{}\"", lookup_key))
            .limit(1)
            .send(&self.stripe)
            .await?
            .data
            .first()
            .cloned();

        Ok(price)
    }

    pub async fn initialize_products(&self, plans: Vec<BillingPlan>) -> Result<(), Error> {
        let mut created_plans = Vec::new();

        tracing::info!(
            plan_count = plans.len(),
            "Initializing Stripe products and prices"
        );

        for plan in plans {
            // Check if product exists, create if not
            let product_id = plan.stripe_product_id();
            let product = match RetrieveProduct::new(product_id.clone())
                .send(&self.stripe)
                .await
            {
                Ok(p) => {
                    tracing::info!("Product {} already exists", p.id);
                    p
                }
                Err(_) => {
                    // Create product
                    let create_product = CreateProduct::new(plan.name())
                        .id(product_id)
                        .description(plan.description());

                    let product = create_product.send(&self.stripe).await?;

                    tracing::info!("Created product: {}", plan.name());
                    product
                }
            };

            match self
                .get_price_from_lookup_key(plan.stripe_price_lookup_key())
                .await?
            {
                Some(p) => {
                    tracing::info!("Price {} already exists", p.id);
                }
                None => {
                    // Create price
                    let create_price = CreatePrice::new(stripe_types::Currency::USD)
                        .lookup_key(plan.stripe_price_lookup_key())
                        .product(product.id)
                        .unit_amount(plan.price().cents)
                        .recurring(CreatePriceRecurring {
                            interval: plan.price().stripe_recurring_interval(),
                            interval_count: Some(1),
                            trial_period_days: Some(plan.trial_days()),
                            meter: None,
                            usage_type: Some(CreatePriceRecurringUsageType::Licensed),
                        });

                    let price = create_price.send(&self.stripe).await?;

                    tracing::info!("Created price: {}", price.id);
                }
            };

            created_plans.push(plan)
        }

        let _ = self.plans.set(created_plans.clone());

        tracing::info!(
            initialized_plans = created_plans.len(),
            "Successfully initialized all Stripe products"
        );

        Ok(())
    }

    /// Create checkout session for upgrading
    pub async fn create_checkout_session(
        &self,
        organization_id: Uuid,
        plan: BillingPlan,
        success_url: String,
        cancel_url: String,
        authentication: AuthenticatedEntity,
    ) -> Result<CheckoutSession, Error> {
        // Get or create Stripe customer
        let customer_id = self
            .get_or_create_customer(organization_id, authentication)
            .await?;

        tracing::info!(
            organization_id = %organization_id,
            plan = %plan.name(),
            customer_id = %customer_id,
            "Creating checkout session"
        );

        let price = self
            .get_price_from_lookup_key(plan.stripe_price_lookup_key())
            .await?
            .ok_or_else(|| anyhow!("Could not find price for selected plan"))?;

        let create_checkout_session = CreateCheckoutSession::new()
            .customer(customer_id)
            .success_url(success_url)
            .cancel_url(cancel_url)
            .mode(CheckoutSessionMode::Subscription)
            .billing_address_collection(CheckoutSessionBillingAddressCollection::Auto)
            .customer_update(CreateCheckoutSessionCustomerUpdate {
                name: Some(CreateCheckoutSessionCustomerUpdateName::Auto),
                address: if plan.is_business_plan() {
                    Some(CreateCheckoutSessionCustomerUpdateAddress::Auto)
                } else {
                    None
                },
                shipping: None,
            })
            .tax_id_collection(CreateCheckoutSessionTaxIdCollection::new(
                plan.is_business_plan(),
            ))
            .line_items(vec![CreateCheckoutSessionLineItems {
                price: Some(price.id.to_string()),
                quantity: Some(1),
                adjustable_quantity: None,
                price_data: None,
                tax_rates: None,
                dynamic_tax_rates: None,
            }])
            .metadata([("organization_id".to_string(), organization_id.to_string())])
            .subscription_data(CreateCheckoutSessionSubscriptionData {
                metadata: Some(
                    [
                        ("organization_id".to_string(), organization_id.to_string()),
                        ("plan".to_string(), serde_json::to_string(&plan)?),
                    ]
                    .into(),
                ),
                ..Default::default()
            });

        let session = create_checkout_session
            .send(&self.stripe)
            .await
            .map_err(|e| anyhow!(e.to_string()))?;

        tracing::info!(
            organization_id = %organization_id,
            plan = %plan.name(),
            session_id = %session.id,
            "Checkout session created successfully"
        );

        Ok(session)
    }

    /// Get existing customer or create new one
    async fn get_or_create_customer(
        &self,
        organization_id: Uuid,
        authentication: AuthenticatedEntity,
    ) -> Result<CustomerId, Error> {
        // Check if org already has stripe_customer_id
        let mut organization = self
            .organization_service
            .get_by_id(&organization_id)
            .await?
            .ok_or_else(|| anyhow!("Organization {} doesn't exist.", organization_id))?;

        if let Some(customer_id) = organization.base.stripe_customer_id {
            return Ok(CustomerId::from(customer_id));
        }

        let organization_owners = self
            .user_service
            .get_organization_owners(&organization_id)
            .await?;

        let first_owner = organization_owners
            .first()
            .ok_or_else(|| anyhow!("Organization {} doesn't have an owner.", organization_id))?;

        // Create new customer
        let create_customer = CreateCustomer::new()
            .metadata([("organization_id".to_string(), organization_id.to_string())])
            .email(first_owner.base.email.clone());

        let customer = create_customer.send(&self.stripe).await?;

        tracing::info!(
            organization_id = %organization_id,
            customer_id = %customer.id,
            customer_email = %first_owner.base.email,
            "Created new Stripe customer"
        );

        organization.base.stripe_customer_id = Some(customer.id.to_string());

        self.organization_service
            .update(&mut organization, authentication)
            .await?;

        Ok(customer.id)
    }

    /// Handle webhook events
    pub async fn handle_webhook(&self, payload: &str, signature: &str) -> Result<(), Error> {
        let event = Webhook::construct_event(payload, signature, &self.webhook_secret)?;

        tracing::debug!(
            event_type = ?event.type_,
            event_id = %event.id,
            "Received Stripe webhook"
        );

        match event.type_ {
            EventType::CustomerSubscriptionCreated | EventType::CustomerSubscriptionUpdated => {
                if let EventObject::CustomerSubscriptionCreated(sub) = event.data.object {
                    self.handle_subscription_update(sub).await?;
                } else if let EventObject::CustomerSubscriptionUpdated(sub) = event.data.object {
                    self.handle_subscription_update(sub).await?;
                }
            }
            EventType::CustomerSubscriptionPaused | EventType::CustomerSubscriptionDeleted => {
                if let EventObject::CustomerSubscriptionDeleted(sub) = event.data.object {
                    self.handle_subscription_deleted(sub).await?;
                }
            }
            // EventType::InvoicePaymentSucceeded => {
            //     if let EventObject::Invoice(invoice) = event.data.object {
            //         self.handle_payment_succeeded(invoice).await?;
            //     }
            // }
            // EventType::InvoicePaymentFailed => {
            //     if let EventObject::Invoice(invoice) = event.data.object {
            //         self.handle_payment_failed(invoice).await?;
            //     }
            // }
            _ => {
                tracing::debug!(
                    event_type = ?event.type_,
                    "Unhandled webhook event type"
                );
            }
        }

        Ok(())
    }

    async fn handle_subscription_update(&self, sub: Subscription) -> Result<(), Error> {
        let org_id = sub
            .metadata
            .get("organization_id")
            .ok_or_else(|| anyhow!("No organization_id in subscription metadata"))?;

        let plan_str = sub
            .metadata
            .get("plan")
            .ok_or_else(|| anyhow!("No plan in subscription metadata"))?;

        let plan: BillingPlan = serde_json::from_str(plan_str)?;

        tracing::info!(
            organization_id = %org_id,
            plan = %plan.name(),
            subscription_status = ?sub.status,
            subscription_id = %sub.id,
            "Subscription updated"
        );

        let org_id = Uuid::parse_str(org_id)?;

        let mut organization = self
            .organization_service
            .get_by_id(&org_id)
            .await?
            .ok_or_else(|| anyhow!("Could not find organization to update subscriptions status"))?;

        // Update enabled features to match new plan
        if let Some(max_networks) = plan.features().max_networks {
            let networks = self
                .network_service
                .get_all(EntityFilter::unfiltered().organization_id(&org_id))
                .await?;
            let keep_ids = networks
                .iter()
                .take(max_networks)
                .map(|n| n.id)
                .collect::<Vec<Uuid>>();

            for network in networks {
                if !keep_ids.contains(&network.id) {
                    self.network_service
                        .delete(&network.id, AuthenticatedEntity::System)
                        .await?;
                    tracing::info!(
                        organization_id = %org_id,
                        network_id = %network.id,
                        "Deleted network due to plan downgrade"
                    );
                }
            }
        }

        match plan {
            BillingPlan::Starter { .. } => {
                let mut users = self
                    .user_service
                    .get_all(EntityFilter::unfiltered().organization_id(&org_id))
                    .await?;
                for user in &mut users {
                    if user.base.permissions != UserOrgPermissions::Owner {
                        user.base.permissions = UserOrgPermissions::None;
                        self.user_service
                            .update(user, AuthenticatedEntity::System)
                            .await?;
                    }
                }
            }
            BillingPlan::Pro { .. } => {
                let mut users = self
                    .user_service
                    .get_all(EntityFilter::unfiltered().organization_id(&org_id))
                    .await?;
                for user in &mut users {
                    if user.base.permissions != UserOrgPermissions::Owner {
                        user.base.permissions = UserOrgPermissions::Visualizer;
                        self.user_service
                            .update(user, AuthenticatedEntity::System)
                            .await?;
                    }
                }
            }
            BillingPlan::Team { .. } => {}
            BillingPlan::Community { .. } => {}
        }

        organization.base.plan_status = Some(sub.status.to_string());
        organization.base.plan = Some(plan);

        self.organization_service
            .update(&mut organization, AuthenticatedEntity::System)
            .await?;

        tracing::info!(
            "Updated organization {} subscription status to {}",
            org_id,
            sub.status
        );
        Ok(())
    }

    async fn handle_subscription_deleted(&self, sub: Subscription) -> Result<(), Error> {
        let org_id = sub
            .metadata
            .get("organization_id")
            .ok_or_else(|| anyhow!("No organization_id in subscription metadata"))?;
        let org_id = Uuid::parse_str(org_id)?;

        let mut organization = self
            .organization_service
            .get_by_id(&org_id)
            .await?
            .ok_or_else(|| anyhow!("Could not find organization to update subscriptions status"))?;

        self.organization_service
            .revoke_org_invites(&organization.id)
            .await?;

        organization.base.plan_status = Some(SubscriptionStatus::Canceled.to_string());

        self.organization_service
            .update(&mut organization, AuthenticatedEntity::System)
            .await?;

        tracing::info!(
            organization_id = %org_id,
            subscription_id = %sub.id,
            "Subscription canceled, invites revoked"
        );
        Ok(())
    }

    pub async fn create_portal_session(
        &self,
        organization_id: Uuid,
        return_url: String,
    ) -> Result<String, Error> {
        // Get customer ID
        let organization = self
            .organization_service
            .get_by_id(&organization_id)
            .await?
            .ok_or_else(|| anyhow!("Organization not found"))?;

        let customer_id = organization
            .base
            .stripe_customer_id
            .ok_or_else(|| anyhow!("No Stripe customer ID"))?;

        let session = CreateBillingPortalSession::new(CustomerId::from(customer_id.clone()))
            .return_url(return_url)
            .send(&self.stripe)
            .await?;

        tracing::info!(
            organization_id = %organization_id,
            customer_id = %customer_id,
            "Created billing portal session"
        );

        Ok(session.url)
    }

    // async fn handle_payment_succeeded(&self, _invoice: Invoice) -> Result<(), Error> {
    //     // Optional: log successful payments, update last_payment_at, etc.
    //     Ok(())
    // }

    // async fn handle_payment_failed(&self, invoice: Invoice) -> Result<()> {
    //     // Optional: send email notifications, update grace period, etc.
    //     tracing::warn!("Payment failed for invoice {}", invoice.id);
    //     Ok(())
    // }
}
