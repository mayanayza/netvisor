use crate::server::auth::middleware::auth::AuthenticatedEntity;
use crate::server::auth::middleware::features::{BlockedInDemoMode, RequireFeature};
use crate::server::auth::middleware::permissions::RequireOwner;
use crate::server::auth::middleware::{auth::AuthenticatedUser, permissions::RequireMember};
use crate::server::auth::service::hash_password;
use crate::server::billing::types::base::BillingPlan;
use crate::server::config::AppState;
use crate::server::organizations::r#impl::base::Organization;
use crate::server::shared::handlers::traits::{CrudHandlers, update_handler};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::storage::traits::StorableEntity;
use crate::server::shared::types::api::ApiError;
use crate::server::shared::types::api::ApiResponse;
use crate::server::shared::types::api::ApiResult;
use crate::server::users::r#impl::base::{User, UserBase};
use crate::server::users::r#impl::permissions::UserOrgPermissions;
use anyhow::anyhow;
use axum::Json;
use axum::Router;
use axum::extract::Path;
use axum::extract::State;
use axum::routing::{get, post, put};
use email_address::EmailAddress;
use std::sync::Arc;
use uuid::Uuid;

pub fn create_router() -> Router<Arc<AppState>> {
    Router::new()
        .route("/{id}", put(update_org_name))
        .route("/", get(get_by_id_handler))
        .route("/{id}/reset", post(reset))
        .route("/{id}/populate-demo", post(populate_demo_data))
}

pub async fn update_org_name(
    State(state): State<Arc<AppState>>,
    RequireOwner(user): RequireOwner,
    _demo_check: RequireFeature<BlockedInDemoMode>,
    Path(id): Path<Uuid>,
    Json(name): Json<String>,
) -> ApiResult<Json<ApiResponse<Organization>>> {
    let mut org = state
        .services
        .organization_service
        .get_by_id(&id)
        .await?
        .ok_or_else(|| anyhow!("Could not find org"))?;

    org.base.name = name;

    update_handler::<Organization>(
        axum::extract::State(state),
        RequireMember(user),
        axum::extract::Path(id),
        axum::extract::Json(org),
    )
    .await
}

pub async fn get_by_id_handler(
    State(state): State<Arc<AppState>>,
    user: AuthenticatedUser,
) -> ApiResult<Json<ApiResponse<Organization>>> {
    let service = Organization::get_service(&state);
    let entity = service
        .get_by_id(&user.organization_id)
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?
        .ok_or_else(|| {
            ApiError::not_found(format!("Organization '{}' not found", user.organization_id))
        })?;

    Ok(Json(ApiResponse::success(entity)))
}

/// Reset all organization data (delete all entities except organization and owner user)
pub async fn reset(
    State(state): State<Arc<AppState>>,
    RequireOwner(user): RequireOwner,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    // Verify organization exists
    let org = state
        .services
        .organization_service
        .get_by_id(&id)
        .await?
        .ok_or_else(|| ApiError::not_found("Organization not found".to_string()))?;

    if org.id != user.organization_id {
        return Err(ApiError::forbidden("Cannot reset another organization"));
    }

    let auth: AuthenticatedEntity = user.clone().into();

    reset_organization_data(&state, &org.id, auth).await?;

    Ok(Json(ApiResponse::success(())))
}

/// Populate demo data (only available for demo organizations)
pub async fn populate_demo_data(
    State(state): State<Arc<AppState>>,
    RequireOwner(user): RequireOwner,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<()>>> {
    use crate::server::organizations::demo_data::{DemoData, generate_groups};
    use crate::server::services::r#impl::base::Service;

    let org = state
        .services
        .organization_service
        .get_by_id(&id)
        .await?
        .ok_or_else(|| ApiError::not_found("Organization not found".to_string()))?;

    if org.id != user.organization_id {
        return Err(ApiError::forbidden(
            "Cannot populate demo data for another organization",
        ));
    }

    // Only available for demo organizations
    if !matches!(org.base.plan, Some(BillingPlan::Demo(_))) {
        return Err(ApiError::forbidden(
            "Populate demo data is only available for demo organizations",
        ));
    }

    // Preserve admin user ID so that users don't get logged out
    let admin_user_id = state
        .services
        .user_service
        .get_all(
            EntityFilter::unfiltered()
                .organization_id(&org.id)
                .user_permissions(&UserOrgPermissions::Admin),
        )
        .await?
        .first()
        .map(|u| u.id)
        .unwrap_or(Uuid::new_v4());

    let auth: AuthenticatedEntity = user.clone().into();

    // First, reset all existing data
    reset_organization_data(&state, &id, auth.clone()).await?;

    // Generate demo data
    let demo_data = DemoData::generate(id);

    // Insert entities in dependency order:
    // 1. Tags (no dependencies) - keep track of created tags for group generation
    let mut created_tags = Vec::new();
    for tag in demo_data.tags {
        let created = state.services.tag_service.create(tag, auth.clone()).await?;
        created_tags.push(created);
    }

    // 2. Networks (depends on organization, tags) - keep track for group generation
    let mut created_networks = Vec::new();
    for network in demo_data.networks {
        let created = state
            .services
            .network_service
            .create(network, auth.clone())
            .await?;
        created_networks.push(created);
    }

    // 3. Subnets (depends on networks)
    for subnet in demo_data.subnets {
        state
            .services
            .subnet_service
            .create(subnet, auth.clone())
            .await?;
    }

    // 4. Hosts with Services - collect created services for group generation
    let mut all_created_services: Vec<Service> = Vec::new();
    for host_with_services in demo_data.hosts_with_services {
        let host_response = state
            .services
            .host_service
            .discover_host(
                host_with_services.host,
                host_with_services.interfaces,
                host_with_services.ports,
                host_with_services.services,
                auth.clone(),
            )
            .await?;
        all_created_services.extend(host_response.services);
    }

    // 5. Daemons (depends on hosts, networks, subnets)
    for daemon in demo_data.daemons {
        state
            .services
            .daemon_service
            .create(daemon, auth.clone())
            .await?;
    }

    // 6. API Keys (depends on networks)
    for api_key in demo_data.api_keys {
        state
            .services
            .api_key_service
            .create(api_key, auth.clone())
            .await?;
    }

    // 7. Groups - generate with actual created services to get correct binding IDs
    let groups = generate_groups(&created_networks, &all_created_services, &created_tags);
    for group in groups {
        state
            .services
            .group_service
            .create(group, auth.clone())
            .await?;
    }

    // 8. Topologies (depends on networks)
    for topology in demo_data.topologies {
        state
            .services
            .topology_service
            .create(topology, auth.clone())
            .await?;
    }

    // Create admin user
    let password = hash_password("password123")?;
    let mut demo_admin = User::new(UserBase::new_password(
        EmailAddress::new_unchecked("demo@scanopy.net"),
        password,
        org.id,
        UserOrgPermissions::Admin,
        vec![],
        None,
    ));
    demo_admin.id = admin_user_id;
    state
        .services
        .user_service
        .create(demo_admin, auth.clone())
        .await?;

    Ok(Json(ApiResponse::success(())))
}

/// Internal function to reset organization data (reused by populate_demo_data)
async fn reset_organization_data(
    state: &Arc<AppState>,
    organization_id: &Uuid,
    auth: AuthenticatedEntity,
) -> Result<(), ApiError> {
    let org_filter = EntityFilter::unfiltered().organization_id(organization_id);
    let network_ids: Vec<Uuid> = state
        .services
        .network_service
        .get_all(org_filter.clone())
        .await?
        .iter()
        .map(|n| n.id)
        .collect();

    // Delete all data except org and owner user
    // Order matters due to foreign keys:
    // 1. Groups depend on services
    // 2. Discoveries depend on daemons/networks
    // 3. Daemons depend on hosts/networks
    // 4. Services depend on hosts
    // 5. Hosts depend on networks/subnets
    // 6. Subnets depend on networks
    // 7. API keys depend on networks
    // 8. Tags (no dependencies, but referenced by other entities)

    // Delete all data except org and owner user
    // Order matters due to foreign keys:
    // 1. Discoveries depend on daemons/networks
    // 2. Daemons depend on hosts/networks
    // 3. Hosts/services depend on networks
    // 4. API keys depend on networks
    state
        .services
        .discovery_service
        .delete_all_for_org(organization_id, &network_ids, auth.clone())
        .await?;
    state
        .services
        .daemon_service
        .delete_all_for_org(organization_id, &network_ids, auth.clone())
        .await?;
    state
        .services
        .host_service
        .delete_all_for_org(organization_id, &network_ids, auth.clone())
        .await?;
    state
        .services
        .topology_service
        .delete_all_for_org(organization_id, &network_ids, auth.clone())
        .await?;
    state
        .services
        .api_key_service
        .delete_all_for_org(organization_id, &network_ids, auth.clone())
        .await?;
    state
        .services
        .network_service
        .delete_all_for_org(organization_id, &network_ids, auth.clone())
        .await?;
    state
        .services
        .invite_service
        .delete_all_for_org(organization_id, &network_ids, auth.clone())
        .await?;
    state
        .services
        .tag_service
        .delete_all_for_org(organization_id, &network_ids, auth.clone())
        .await?;

    // Delete non-owner users
    let non_owner_user_ids: Vec<Uuid> = state
        .services
        .user_service
        .get_all(org_filter)
        .await?
        .iter()
        .filter_map(|u| {
            if u.base.permissions != UserOrgPermissions::Owner {
                Some(u.id)
            } else {
                None
            }
        })
        .collect();

    state
        .services
        .user_service
        .delete_many(&non_owner_user_ids, auth)
        .await?;

    Ok(())
}
