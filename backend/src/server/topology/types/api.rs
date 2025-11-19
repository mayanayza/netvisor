use crate::server::topology::types::edges::Edge;
use crate::server::topology::types::nodes::Node;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone, Default, PartialEq, Eq, Hash)]
pub struct RefreshDataResponse {
    pub nodes: Vec<Node>,
    pub edges: Vec<Edge>,
}
