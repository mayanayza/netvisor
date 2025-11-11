use crate::server::billing::types::base::BillingPlan;
use crate::server::organizations::service::OrganizationService;
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::types::metadata::TypeMetadataProvider;
use crate::server::users::service::UserService;
use anyhow::Error;
use anyhow::anyhow;
use stripe_checkout::checkout_session::CreateCheckoutSessionCustomerUpdate;
use stripe_checkout::checkout_session::CreateCheckoutSessionCustomerUpdateAddress;
use stripe_checkout::checkout_session::CreateCheckoutSessionCustomerUpdateName;
use stripe_product::Price;
use std::sync::Arc;
use std::sync::OnceLock;
use stripe::Client;
use stripe_billing::{Subscription, SubscriptionStatus};
use stripe_checkout::checkout_session::{
    CreateCheckoutSession, CreateCheckoutSessionLineItems, CreateCheckoutSessionTaxIdCollection,
};
use stripe_checkout::{
    CheckoutSession, CheckoutSessionBillingAddressCollection, CheckoutSessionMode,
};
use stripe_core::customer::CreateCustomer;
use stripe_core::{CustomerId, EventType};
use stripe_product::price::CreatePriceRecurring;
use stripe_product::price::SearchPrice;
use stripe_product::price::{CreatePrice, CreatePriceRecurringUsageType};
use stripe_product::product::{CreateProduct, RetrieveProduct};
use stripe_webhook::{EventObject, Webhook};
use uuid::Uuid;
pub struct BillingService {
    pub stripe: stripe::Client,
    pub organization_service: Arc<OrganizationService>,
    pub user_service: Arc<UserService>,
    pub plans: OnceLock<Vec<BillingPlan>>
}

impl BillingService {
    pub fn new(
        stripe_secret: String,
        organization_service: Arc<OrganizationService>,
        user_service: Arc<UserService>,
    ) -> Self {
        Self {
            stripe: Client::new(stripe_secret),
            organization_service,
            user_service,
            plans: OnceLock::new()
        }
    }

    pub fn get_plans(&self) -> Vec<BillingPlan> {
        self.plans.get().map(|v| v.to_vec()).unwrap_or_default()
    }

    pub async fn get_price_from_lookup_key(&self, lookup_key: String) -> Result<Option<Price>, Error> {
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

            match self.get_price_from_lookup_key(plan.stripe_price_lookup_key()).await? {
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

        let _ = self.plans.set(created_plans);

        Ok(())
    }

    /// Create checkout session for upgrading
    pub async fn create_checkout_session(
        &self,
        organization_id: Uuid,
        plan: BillingPlan,
        success_url: String,
        cancel_url: String,
    ) -> Result<CheckoutSession, Error> {

        // Get or create Stripe customer
        let customer_id = self.get_or_create_customer(organization_id).await?;

        let price = self.get_price_from_lookup_key(plan.stripe_price_lookup_key()).await?.ok_or_else(|| anyhow!("Could not find price for selected plan"))?;

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
                } else { None },
                shipping: None
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
            .metadata([("organization_id".to_string(), organization_id.to_string())]);

        create_checkout_session
            .send(&self.stripe)
            .await
            .map_err(|e| anyhow!(e.to_string()))
    }

    /// Get existing customer or create new one
    async fn get_or_create_customer(&self, organization_id: Uuid) -> Result<CustomerId, Error> {
        // Check if org already has stripe_customer_id
        let mut organization = self
            .organization_service
            .get_by_id(&organization_id)
            .await?
            .ok_or_else(|| anyhow!("Organization {} doesn't exist.", organization_id))?;

        if let Some(customer_id) = organization.base.stripe_customer_id {
            return Ok(CustomerId::from(customer_id));
        }

        let organization_owner = self
            .user_service
            .get_organization_owner(&organization_id)
            .await?
            .ok_or_else(|| anyhow!("Organization {} doesn't have an owner.", organization_id))?;

        // Create new customer
        let create_customer = CreateCustomer::new()
            .metadata([("organization_id".to_string(), organization_id.to_string())])
            .email(organization_owner.base.email);

        let customer = create_customer.send(&self.stripe).await?;

        organization.base.stripe_customer_id = Some(customer.id.to_string());

        self.organization_service.update(&mut organization).await?;

        Ok(customer.id)
    }

    /// Handle webhook events
    pub async fn handle_webhook(&self, payload: &str, signature: &str) -> Result<(), Error> {
        let webhook_secret = std::env::var("STRIPE_WEBHOOK_SECRET")?;
        let event = Webhook::construct_event(payload, signature, &webhook_secret)?;

        match event.type_ {
            EventType::CustomerSubscriptionCreated | EventType::CustomerSubscriptionUpdated => {
                if let EventObject::CustomerSubscriptionCreated(sub) = event.data.object {
                    self.handle_subscription_update(sub).await?;
                } else if let EventObject::CustomerSubscriptionUpdated(sub) = event.data.object {
                    self.handle_subscription_update(sub).await?;
                }
            }
            EventType::CustomerSubscriptionDeleted => {
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
                tracing::debug!("Unhandled webhook event: {:?}", event.type_);
            }
        }

        Ok(())
    }

    async fn handle_subscription_update(&self, sub: Subscription) -> Result<(), Error> {
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

        organization.base.plan_status = Some(sub.status);

        self.organization_service.update(&mut organization).await?;

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

        organization.base.plan_status = Some(SubscriptionStatus::Canceled);

        self.organization_service.update(&mut organization).await?;

        tracing::info!("Canceled subscription for organization {}", org_id);
        Ok(())
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
