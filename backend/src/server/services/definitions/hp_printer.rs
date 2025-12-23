use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct HpPrinter;

impl ServiceDefinition for HpPrinter {
    fn name(&self) -> &'static str {
        "Hp Printer"
    }
    fn description(&self) -> &'static str {
        "An HP Printer"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Printer
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::AnyOf(vec![
                Pattern::Endpoint(PortType::Http, "", "LaserJet", None),
                Pattern::Endpoint(PortType::Http, "", "DeskJet", None),
                Pattern::Endpoint(PortType::Http, "", "OfficeJet", None),
                Pattern::Endpoint(PortType::Http8080, "", "LaserJet", None),
                Pattern::Endpoint(PortType::Http8080, "", "DeskJet", None),
                Pattern::Endpoint(PortType::Http8080, "", "OfficeJet", None),
            ]),
            Pattern::AnyOf(vec![
                Pattern::Port(PortType::Ipp),
                Pattern::Port(PortType::LdpTcp),
                Pattern::Port(PortType::LdpUdp),
            ]),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/hp.svg"
    }

    fn logo_needs_white_background(&self) -> bool {
        true
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<HpPrinter>));
