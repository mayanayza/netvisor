use axum::Json;
use axum::http::header::CACHE_CONTROL;
use axum::response::IntoResponse;
use serde::Serialize;
use strum::{IntoDiscriminant, IntoEnumIterator};

use crate::server::{
    billing::types::{base::BillingPlan, features::Feature},
    discovery::r#impl::types::DiscoveryType,
    groups::r#impl::types::GroupType,
    ports::r#impl::base::PortType,
    services::definitions::ServiceDefinitionRegistry,
    shared::{concepts::Concept, entities::EntityDiscriminants, types::api::ApiResponse},
    subnets::r#impl::types::SubnetType,
    topology::types::edges::EdgeType,
    users::r#impl::permissions::UserOrgPermissions,
};

#[derive(Serialize, Debug, Clone)]
pub struct MetadataRegistry {
    pub service_definitions: Vec<TypeMetadata>,
    pub subnet_types: Vec<TypeMetadata>,
    pub edge_types: Vec<TypeMetadata>,
    pub group_types: Vec<TypeMetadata>,
    pub entities: Vec<EntityMetadata>,
    pub ports: Vec<TypeMetadata>,
    pub discovery_types: Vec<TypeMetadata>,
    pub billing_plans: Vec<TypeMetadata>,
    pub features: Vec<TypeMetadata>,
    pub permissions: Vec<TypeMetadata>,
    pub concepts: Vec<EntityMetadata>,
}

#[derive(Serialize, Debug, Clone)]
pub struct TypeMetadata {
    pub id: &'static str,
    pub name: Option<&'static str>,
    pub description: Option<&'static str>,
    pub category: Option<&'static str>,
    pub icon: Option<&'static str>,
    pub color: Option<&'static str>,
    pub metadata: Option<serde_json::Value>,
}

#[derive(Serialize, Debug, Clone)]
pub struct EntityMetadata {
    pub id: &'static str,
    pub color: &'static str,
    pub icon: &'static str,
}

pub trait HasId {
    fn id(&self) -> &'static str;
}

pub trait MetadataProvider<T>: HasId {
    fn to_metadata(&self) -> T;
}

pub trait EntityMetadataProvider: MetadataProvider<EntityMetadata> {
    fn color(&self) -> &'static str;
    fn icon(&self) -> &'static str;
}

pub trait TypeMetadataProvider: EntityMetadataProvider + MetadataProvider<TypeMetadata> {
    fn name(&self) -> &'static str;
    fn description(&self) -> &'static str {
        ""
    }
    fn category(&self) -> &'static str {
        ""
    }
    fn metadata(&self) -> serde_json::Value {
        serde_json::json!({})
    }
}

impl<T> MetadataProvider<EntityMetadata> for T
where
    T: EntityMetadataProvider,
{
    fn to_metadata(&self) -> EntityMetadata {
        EntityMetadata {
            id: self.id(),
            color: self.color(),
            icon: self.icon(),
        }
    }
}

impl<T> MetadataProvider<TypeMetadata> for T
where
    T: TypeMetadataProvider,
{
    fn to_metadata(&self) -> TypeMetadata {
        let id = self.id();
        let name = self.name();
        let description = self.description();
        let category = self.category();
        let icon = self.icon();
        let color = self.color();
        let metadata = self.metadata();

        TypeMetadata {
            id,
            name: (!name.is_empty()).then_some(name),
            description: (!description.is_empty()).then_some(description),
            category: (!category.is_empty()).then_some(category),
            icon: (!icon.is_empty()).then_some(icon),
            color: (!color.is_empty()).then_some(color),
            metadata: (!metadata.as_object().is_some_and(|obj| obj.is_empty())).then_some(metadata),
        }
    }
}

pub async fn get_metadata_registry() -> impl IntoResponse {
    let registry = MetadataRegistry {
        service_definitions: ServiceDefinitionRegistry::all_service_definitions()
            .iter()
            .map(|t| t.to_metadata())
            .collect(),
        subnet_types: SubnetType::iter().map(|t| t.to_metadata()).collect(),
        group_types: GroupType::iter()
            .map(|t| t.discriminant().to_metadata())
            .collect(),
        edge_types: EdgeType::iter().map(|t| t.to_metadata()).collect(),
        entities: EntityDiscriminants::iter()
            .map(|e| e.to_metadata())
            .collect(),
        concepts: Concept::iter().map(|e| e.to_metadata()).collect(),
        ports: PortType::iter().map(|p| p.to_metadata()).collect(),
        discovery_types: DiscoveryType::iter().map(|d| d.to_metadata()).collect(),
        billing_plans: BillingPlan::iter().map(|p| p.to_metadata()).collect(),
        features: Feature::iter().map(|f| f.to_metadata()).collect(),
        permissions: UserOrgPermissions::iter()
            .map(|p| p.to_metadata())
            .collect(),
    };

    (
        [(CACHE_CONTROL, "no-store, no-cache, must-revalidate")],
        Json(ApiResponse::success(registry)),
    )
}
