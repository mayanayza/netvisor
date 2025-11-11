use email_address::EmailAddress;
use uuid::Uuid;

use crate::server::{shared::storage::traits::SqlValue, users::r#impl::base::UserOrgPermissions};

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

    pub fn host_id(mut self, id: &Uuid) -> Self {
        self.conditions
            .push(format!("host_id = ${}", self.values.len() + 1));
        self.values.push(SqlValue::Uuid(*id));
        self
    }

    pub fn api_key(mut self, api_key: String) -> Self {
        self.conditions
            .push(format!("key = ${}", self.values.len() + 1));
        self.values.push(SqlValue::String(api_key));
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

    pub fn user_permissions(mut self, permissions: &UserOrgPermissions) -> Self {
        self.conditions
            .push(format!("permissions = ${}", self.values.len() + 1));
        self.values
            .push(SqlValue::UserOrgPermissions(permissions.clone()));
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
