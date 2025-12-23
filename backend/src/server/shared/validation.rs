use crate::server::shared::types::api::ApiError;
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
