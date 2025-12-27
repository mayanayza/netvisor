use crate::server::shared::services::traits::CrudService;
use crate::server::shared::types::api::ApiError;
use crate::server::tags::service::TagService;
use std::collections::HashSet;
use uuid::Uuid;

/// Validates that a user has access to a network.
/// Returns an error if the network_id is not in the user's allowed networks.
pub fn validate_network_access(
    network_id: Option<Uuid>,
    user_network_ids: &[Uuid],
    action: &str,
) -> Result<(), ApiError> {
    if let Some(network_id) = network_id
        && !user_network_ids.contains(&network_id)
    {
        return Err(ApiError::unauthorized(format!(
            "You aren't allowed to {} entities on this network",
            action
        )));
    }
    Ok(())
}

/// Validates that a user has access to an organization.
/// Returns an error if the organization_id doesn't match the user's organization.
pub fn validate_organization_access(
    entity_organization_id: Option<Uuid>,
    user_organization_id: Uuid,
    action: &str,
) -> Result<(), ApiError> {
    if let Some(organization_id) = entity_organization_id
        && organization_id != user_organization_id
    {
        return Err(ApiError::unauthorized(format!(
            "You aren't allowed to {} entities for this organization",
            action
        )));
    }
    Ok(())
}

/// Validates entity field constraints (custom validation logic).
/// Returns a bad request error if validation fails.
pub fn validate_entity<F>(validate_fn: F, entity_name: &str) -> Result<(), ApiError>
where
    F: FnOnce() -> Result<(), String>,
{
    validate_fn().map_err(|err| {
        ApiError::bad_request(&format!("{} validation failed: {}", entity_name, err))
    })
}

/// Combined validation for create operations.
/// Validates network access, organization access, and entity constraints.
pub fn validate_create_access(
    network_id: Option<Uuid>,
    organization_id: Option<Uuid>,
    user_network_ids: &[Uuid],
    user_organization_id: Uuid,
) -> Result<(), ApiError> {
    validate_network_access(network_id, user_network_ids, "create")?;
    validate_organization_access(organization_id, user_organization_id, "create")?;
    Ok(())
}

/// Combined validation for read/access operations.
/// Validates network access and organization access for viewing an entity.
pub fn validate_read_access(
    network_id: Option<Uuid>,
    organization_id: Option<Uuid>,
    user_network_ids: &[Uuid],
    user_organization_id: Uuid,
) -> Result<(), ApiError> {
    validate_network_access(network_id, user_network_ids, "access")?;
    validate_organization_access(organization_id, user_organization_id, "access")?;
    Ok(())
}

/// Combined validation for update operations.
/// Validates access to both existing entity AND new values being set.
pub fn validate_update_access(
    existing_network_id: Option<Uuid>,
    existing_organization_id: Option<Uuid>,
    new_network_id: Option<Uuid>,
    new_organization_id: Option<Uuid>,
    user_network_ids: &[Uuid],
    user_organization_id: Uuid,
) -> Result<(), ApiError> {
    // First check access to existing entity
    if let Some(network_id) = existing_network_id
        && !user_network_ids.contains(&network_id)
    {
        return Err(ApiError::unauthorized(
            "You don't have access to this entity".to_string(),
        ));
    }
    if let Some(organization_id) = existing_organization_id
        && organization_id != user_organization_id
    {
        return Err(ApiError::unauthorized(
            "You don't have access to this entity".to_string(),
        ));
    }

    // Then check access to new values being set
    if let Some(network_id) = new_network_id
        && !user_network_ids.contains(&network_id)
    {
        return Err(ApiError::unauthorized(
            "You can't move this entity to a network you don't have access to".to_string(),
        ));
    }
    if let Some(organization_id) = new_organization_id
        && organization_id != user_organization_id
    {
        return Err(ApiError::unauthorized(
            "You can't move this entity to a different organization".to_string(),
        ));
    }

    Ok(())
}

/// Combined validation for delete operations.
/// Validates network access and organization access for deleting an entity.
pub fn validate_delete_access(
    network_id: Option<Uuid>,
    organization_id: Option<Uuid>,
    user_network_ids: &[Uuid],
    user_organization_id: Uuid,
) -> Result<(), ApiError> {
    if let Some(network_id) = network_id
        && !user_network_ids.contains(&network_id)
    {
        return Err(ApiError::unauthorized(
            "You don't have access to delete this entity".to_string(),
        ));
    }
    if let Some(organization_id) = organization_id
        && organization_id != user_organization_id
    {
        return Err(ApiError::unauthorized(
            "You don't have access to delete this entity".to_string(),
        ));
    }
    Ok(())
}

/// Validation for bulk delete operations.
/// Validates network access and organization access for deleting multiple entities.
pub fn validate_bulk_delete_access(
    network_id: Option<Uuid>,
    organization_id: Option<Uuid>,
    user_network_ids: &[Uuid],
    user_organization_id: Uuid,
) -> Result<(), ApiError> {
    if let Some(network_id) = network_id
        && !user_network_ids.contains(&network_id)
    {
        return Err(ApiError::unauthorized(
            "You don't have access to delete one or more of these entities".to_string(),
        ));
    }
    if let Some(organization_id) = organization_id
        && organization_id != user_organization_id
    {
        return Err(ApiError::unauthorized(
            "You don't have access to delete one or more of these entities".to_string(),
        ));
    }
    Ok(())
}

/// Validates and deduplicates a list of tag UUIDs.
/// - Removes duplicate UUIDs
/// - Validates all tags exist and belong to the specified organization
///
/// Returns the deduplicated list of valid tag UUIDs, or an error if any tag is invalid.
pub async fn validate_and_dedupe_tags(
    tags: Vec<Uuid>,
    organization_id: Uuid,
    tag_service: &TagService,
) -> Result<Vec<Uuid>, ApiError> {
    // Deduplicate
    let unique_tags: Vec<Uuid> = tags
        .into_iter()
        .collect::<HashSet<_>>()
        .into_iter()
        .collect();

    if unique_tags.is_empty() {
        return Ok(unique_tags);
    }

    // Validate all tags exist and belong to the organization
    for tag_id in &unique_tags {
        match tag_service.get_by_id(tag_id).await {
            Ok(Some(tag)) => {
                if tag.base.organization_id != organization_id {
                    return Err(ApiError::bad_request(&format!(
                        "Tag {} does not belong to this organization",
                        tag_id
                    )));
                }
            }
            Ok(None) => {
                return Err(ApiError::bad_request(&format!("Tag {} not found", tag_id)));
            }
            Err(e) => {
                return Err(ApiError::internal_error(&format!(
                    "Failed to validate tag {}: {}",
                    tag_id, e
                )));
            }
        }
    }

    Ok(unique_tags)
}
