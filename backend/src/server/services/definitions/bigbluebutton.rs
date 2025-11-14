use crate::server::hosts::r#impl::ports::PortBase;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct BigBlueButton;

impl ServiceDefinition for BigBlueButton {
    fn name(&self) -> &'static str {
        "BigBlueButton"
    }
    fn description(&self) -> &'static str {
        "Web conferencing system"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Web
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortBase::Http, "/bigbluebutton/api", "", Some(200..300))
    }
    fn logo_url(&self) -> &'static str {
        "https://simpleicons.org/icons/bigbluebutton.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(
    create_service::<BigBlueButton>
));
