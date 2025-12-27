use serde::{Deserialize, Serialize};
use strum::{Display, EnumIter, EnumString, IntoStaticStr};
use utoipa::ToSchema;

#[derive(
    Debug,
    Clone,
    Copy,
    Serialize,
    Deserialize,
    PartialEq,
    Eq,
    Hash,
    Default,
    ToSchema,
    EnumIter,
    IntoStaticStr,
    Display,
    EnumString,
)]
pub enum Color {
    Pink,
    Rose,
    Red,
    Orange,
    #[default]
    Yellow,
    Green,
    Emerald,
    Teal,
    Cyan,
    Blue,
    Indigo,
    Purple,
    Gray,
}
