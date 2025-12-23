use chrono::{DateTime, Utc};
use email_address::EmailAddress;
use uuid::Uuid;

use crate::server::{
    shared::storage::traits::SqlValue, users::r#impl::permissions::UserOrgPermissions,
};

/// Builder pattern for common WHERE clauses
#[derive(Clone)]
pub struct EntityFilter {
    conditions: Vec<String>,
    values: Vec<SqlValue>,
}

impl EntityFilter {
    pub fn unfiltered() -> Self {
        Self {
            conditions: Vec::new(),
            values: Vec::new(),
        }
    }

    pub fn entity_id(mut self, id: &Uuid) -> Self {
        self.conditions
            .push(format!("id = ${}", self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    pub fn entity_ids(mut self, ids: &[Uuid]) -> Self {
        if ids.is_empty() {
            // Empty IN clause should match nothing
            self.conditions.push("FALSE".to_string());
            return self;
        }

        let placeholders: Vec<String> = ids
            .iter()
            .enumerate()
            .map(|(i, _)| format!("${}", self.values.len() + i + 1))
            .collect();

        self.conditions
            .push(format!("id IN ({})", placeholders.join(", ")));

        for id in ids {
            self.values.push(SqlValue::Uuid(*id));
        }

        self
    }

    pub fn network_ids(mut self, ids: &[Uuid]) -> Self {
        if ids.is_empty() {
            // Empty IN clause should match nothing
            self.conditions.push("FALSE".to_string());
            return self;
        }

        let placeholders: Vec<String> = ids
            .iter()
            .enumerate()
            .map(|(i, _)| format!("${}", self.values.len() + i + 1))
            .collect();

        self.conditions
            .push(format!("network_id IN ({})", placeholders.join(", ")));

        for id in ids {
            self.values.push(SqlValue::Uuid(*id));
        }

        self
    }

    pub fn user_id(mut self, id: &Uuid) -> Self {
        self.conditions
            .push(format!("user_id = ${}", self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    pub fn hidden_is(mut self, hidden: bool) -> Self {
        self.conditions
            .push(format!("hidden = ${}", self.values.len() + 1));
        self.values.push(SqlValue::Bool(hidden));
        self
    }

    pub fn host_id(mut self, id: &Uuid) -> Self {
        self.conditions
            .push(format!("host_id = ${}", self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    pub fn subnet_id(mut self, id: &Uuid) -> Self {
        self.conditions
            .push(format!("subnet_id = ${}", self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    pub fn group_id(mut self, id: &Uuid) -> Self {
        self.conditions
            .push(format!("group_id = ${}", self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    pub fn group_ids(mut self, ids: &[Uuid]) -> Self {
        if ids.is_empty() {
            self.conditions.push("FALSE".to_string());
            return self;
        }

        let placeholders: Vec<String> = ids
            .iter()
            .enumerate()
            .map(|(i, _)| format!("${}", self.values.len() + i + 1))
            .collect();

        self.conditions
            .push(format!("group_id IN ({})", placeholders.join(", ")));

        for id in ids {
            self.values.push(SqlValue::Uuid(*id));
        }

        self
    }

    pub fn binding_id(mut self, id: &Uuid) -> Self {
        self.conditions
            .push(format!("binding_id = ${}", self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    pub fn host_ids(mut self, ids: &[Uuid]) -> Self {
        if ids.is_empty() {
            // Empty IN clause should match nothing
            self.conditions.push("FALSE".to_string());
            return self;
        }

        let placeholders: Vec<String> = ids
            .iter()
            .enumerate()
            .map(|(i, _)| format!("${}", self.values.len() + i + 1))
            .collect();

        self.conditions
            .push(format!("host_id IN ({})", placeholders.join(", ")));

        for id in ids {
            self.values.push(SqlValue::Uuid(*id));
        }

        self
    }

    pub fn api_key(mut self, api_key: String) -> Self {
        self.conditions
            .push(format!("key = ${}", self.values.len() + 1));
        self.values.push(SqlValue::String(api_key));
        self
    }

    pub fn service_binding_id(mut self, id: &Uuid) -> Self {
        self.conditions.push(format!(
            "EXISTS (SELECT 1 FROM jsonb_array_elements(bindings) AS b WHERE b->>'id' = ${})",
            self.values.len() + 1
        ));
        self.values.push(SqlValue::String(id.to_string()));
        self
    }

    pub fn scheduled_discovery(mut self) -> Self {
        self.conditions
            .push("run_type->>'type' = 'Scheduled'".to_string());
        self.conditions
            .push("(run_type->>'enabled')::boolean = true".to_string());
        self
    }

    pub fn oidc_subject(mut self, subject: String) -> Self {
        self.conditions
            .push(format!("oidc_subject = ${}", self.values.len() + 1));
        self.values.push(SqlValue::String(subject));
        self.conditions
            .push("oidc_provider IS NOT NULL".to_string());
        self
    }

    pub fn email(mut self, email: &EmailAddress) -> Self {
        self.conditions
            .push(format!("email = ${}", self.values.len() + 1));
        self.values.push(SqlValue::Email(email.clone()));
        self
    }

    pub fn organization_id(mut self, organization_id: &Uuid) -> Self {
        self.conditions
            .push(format!("organization_id = ${}", self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*organization_id));
        self
    }

    pub fn topology_id(mut self, topology_id: &Uuid) -> Self {
        self.conditions
            .push(format!("topology_id = ${}", self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*topology_id));
        self
    }

    pub fn user_permissions(mut self, permissions: &UserOrgPermissions) -> Self {
        self.conditions
            .push(format!("permissions = ${}", self.values.len() + 1));
        self.values.push(SqlValue::UserOrgPermissions(*permissions));
        self
    }

    pub fn expires_before(mut self, timestamp: DateTime<Utc>) -> Self {
        self.conditions
            .push(format!("expires_at < ${}", self.values.len() + 1));
        self.values.push(SqlValue::Timestamp(timestamp));
        self
    }

    /// Generic UUID filter for any column name.
    /// Used by generic child entity handlers to filter by parent_column dynamically.
    pub fn uuid_column(mut self, column: &str, id: &Uuid) -> Self {
        self.conditions
            .push(format!("{} = ${}", column, self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    /// Generic UUID IN filter for any column name.
    /// Used by generic child entity services to filter by parent_column dynamically.
    pub fn uuid_columns(mut self, column: &str, ids: &[Uuid]) -> Self {
        if ids.is_empty() {
            self.conditions.push("FALSE".to_string());
            return self;
        }

        let placeholders: Vec<String> = ids
            .iter()
            .enumerate()
            .map(|(i, _)| format!("${}", self.values.len() + i + 1))
            .collect();

        self.conditions
            .push(format!("{} IN ({})", column, placeholders.join(", ")));

        for id in ids {
            self.values.push(SqlValue::Uuid(*id));
        }

        self
    }

    /// Filter by service_id (for bindings)
    pub fn service_id(mut self, id: &Uuid) -> Self {
        self.conditions
            .push(format!("service_id = ${}", self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    pub fn to_where_clause(&self) -> String {
        if self.conditions.is_empty() {
            String::new()
        } else {
            format!("WHERE {}", self.conditions.join(" AND "))
        }
    }

    pub fn values(&self) -> &[SqlValue] {
        &self.values
    }
}
