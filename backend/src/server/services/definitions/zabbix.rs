use crate::server::ports::r#impl::base::PortType;
use crate::server::services::definitions::{ServiceDefinitionFactory, create_service};
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::services::r#impl::definitions::ServiceDefinition;
use crate::server::services::r#impl::patterns::Pattern;

#[derive(Default, Clone, Eq, PartialEq, Hash)]
pub struct Zabbix;

impl ServiceDefinition for Zabbix {
    fn name(&self) -> &'static str {
        "Zabbix"
    }
    fn description(&self) -> &'static str {
        "Enterprise monitoring solution"
    }
    fn category(&self) -> ServiceCategory {
        ServiceCategory::Monitoring
    }
    fn discovery_pattern(&self) -> Pattern<'_> {
        Pattern::Endpoint(PortType::Http, "/zabbix", "zabbix", None)
    }
    fn logo_url(&self) -> &'static str {
        "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/zabbix.svg"
    }
}

inventory::submit!(ServiceDefinitionFactory::new(create_service::<Zabbix>));
