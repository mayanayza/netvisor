use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct PfBlockerNg;

impl ServiceDefinition for PfBlockerNg {
    fn name(&self) -> &'static str {
        "pfBlockerNG"
    }
    fn description(&self) -> &'static str {
        "PfSense package for DNS/IP blocking"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::AdBlock
    }

    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::AllOf(vec![
            Pattern::AllOf(vec![
                Pattern::Port(PortType::DnsTcp),
                Pattern::Port(PortType::DnsUdp),
            ]),
            Pattern::Endpoint(PortType::Http, "/pfblockerng", "pfblockerng", None),
        ])
    }

    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pfsense.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<PfBlockerNg>));
