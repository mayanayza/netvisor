use serde::{Deserialize, Serialize};
use std::hash::Hash;
use uuid::Uuid;

#[derive(Copy, Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(tag = "type", content = "config")]
pub enum HostTarget {
    // ID of service's binding
    ServiceBinding(Uuid),
    Hostname,
    None,
}
