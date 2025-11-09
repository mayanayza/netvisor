use crate::daemon::discovery::types::base::DiscoveryCriticalError;
use crate::server::services::r#impl::base::Service;
use crate::server::services::r#impl::endpoints::{Endpoint, EndpointResponse};
use anyhow::anyhow;
use anyhow::{Error, Result};
use dhcproto::Encodable;
use dhcproto::v4::{self, Decodable, Encoder, Message, MessageType};
use futures::stream::FuturesUnordered;
use futures::stream::StreamExt;
use rand::{Rng, SeedableRng};
use rsntp::AsyncSntpClient;
use snmp2::{AsyncSession, Oid};
use std::net::{IpAddr, SocketAddr};
use std::time::Duration;
use tokio::net::UdpSocket;
use tokio::{net::TcpStream, time::timeout};
use tokio_util::sync::CancellationToken;
use trust_dns_resolver::TokioAsyncResolver;
use trust_dns_resolver::config::{NameServerConfig, Protocol, ResolverConfig, ResolverOpts};

use crate::server::hosts::r#impl::ports::{PortBase, TransportProtocol};

pub const SCAN_TIMEOUT: Duration = Duration::from_millis(800);

/// Generic batch scanner that maintains constant parallelism
/// This is the core RustScan pattern extracted into a reusable function
///
/// # Arguments
/// * `items` - Items to scan
/// * `batch_size` - Number of concurrent operations to maintain
/// * `cancel` - Cancellation token
/// * `scan_fn` - Async function that scans an item and returns Option<Result>
///
/// # Returns
/// Vector of successfully scanned results
async fn batch_scan<T, O, F, Fut>(
    items: Vec<T>,
    batch_size: usize,
    cancel: CancellationToken,
    scan_fn: F,
) -> Vec<O>
where
    T: Send + 'static,
    O: Send + 'static,
    F: Fn(T) -> Fut,
    Fut: std::future::Future<Output = Option<O>> + Send + 'static,
{
    let mut results = Vec::new();
    let mut item_iter = items.into_iter();
    let mut futures = FuturesUnordered::new();

    // Fill initial batch
    for _ in 0..batch_size {
        if cancel.is_cancelled() {
            break;
        }

        if let Some(item) = item_iter.next() {
            futures.push(scan_fn(item));
        } else {
            break;
        }
    }

    // Process results and maintain constant parallelism
    while let Some(result) = futures.next().await {
        if cancel.is_cancelled() {
            break;
        }

        if let Some(output) = result {
            results.push(output);
        }

        // Immediately add next item to maintain batch size
        if let Some(item) = item_iter.next() {
            futures.push(scan_fn(item));
        }
    }

    results
}

/// Scan ports and endpoints, automatically filtering endpoints to open TCP ports
pub async fn scan_ports_and_endpoints(
    ip: IpAddr,
    cancel: CancellationToken,
    port_scan_batch_size: usize, // ← Removed filter parameter
) -> Result<(Vec<PortBase>, Vec<EndpointResponse>), Error> {
    if cancel.is_cancelled() {
        return Err(anyhow!("Operation cancelled"));
    }

    let mut open_ports = Vec::new();
    let mut endpoint_responses = Vec::new();

    // Scan TCP ports with batching
    let tcp_ports = scan_tcp_ports(ip, cancel.clone(), port_scan_batch_size).await?;
    open_ports.extend(tcp_ports.clone());

    if cancel.is_cancelled() {
        return Err(anyhow!("Operation cancelled"));
    }

    // Scan UDP ports with batching
    let udp_ports = scan_udp_ports(ip, cancel.clone(), port_scan_batch_size).await?;
    open_ports.extend(udp_ports);

    if cancel.is_cancelled() {
        return Err(anyhow!("Operation cancelled"));
    }

    // OPTIMIZATION: Only scan endpoints on open TCP ports
    // (We determined this internally from the scan results)
    let endpoints = scan_endpoints(
        ip,
        cancel.clone(),
        Some(tcp_ports), // ← Filter determined HERE, not passed in
        port_scan_batch_size,
    )
    .await?;
    endpoint_responses.extend(endpoints);

    tracing::debug!(
        "Scan results for {}: found {} open ports, {} endpoint responses",
        ip,
        open_ports.len(),
        endpoint_responses.len()
    );

    Ok((open_ports, endpoint_responses))
}

pub async fn scan_tcp_ports(
    ip: IpAddr,
    cancel: CancellationToken,
    batch_size: usize,
) -> Result<Vec<PortBase>, Error> {
    let discovery_ports = Service::all_discovery_ports();
    let ports: Vec<u16> = discovery_ports
        .iter()
        .filter(|p| p.protocol() == TransportProtocol::Tcp)
        .map(|p| p.number())
        .collect();

    let total_ports = ports.len();

    tracing::debug!(
        "Scanning {} TCP ports on {} with batch size {}",
        total_ports,
        ip,
        batch_size
    );

    let open_ports = batch_scan(ports, batch_size, cancel, |port| async move {
        let socket = SocketAddr::new(ip, port);
        match timeout(SCAN_TIMEOUT, TcpStream::connect(socket)).await {
            Ok(Ok(_)) => {
                tracing::debug!("Found open TCP port {}:{}", ip, port);
                Some(PortBase::new_tcp(port))
            }
            Ok(Err(e)) => {
                if DiscoveryCriticalError::is_critical_error(e.to_string()) {
                    tracing::error!("Critical error scanning {}:{}: {}", socket.ip(), port, e);
                }
                None
            }
            Err(_) => None, // Timeout
        }
    })
    .await;

    Ok(open_ports)
}

pub async fn scan_udp_ports(
    ip: IpAddr,
    cancel: CancellationToken,
    batch_size: usize,
) -> Result<Vec<PortBase>, Error> {
    let discovery_ports = Service::all_discovery_ports();
    let ports: Vec<u16> = discovery_ports
        .iter()
        .filter(|p| p.protocol() == TransportProtocol::Udp)
        .map(|p| p.number())
        .collect();

    let total_ports = ports.len();

    // UDP is slower and less reliable, cap at 10 concurrent
    let udp_batch_size = std::cmp::min(batch_size, 10);

    tracing::debug!(
        "Scanning {} UDP ports on {} with batch size {}",
        total_ports,
        ip,
        udp_batch_size
    );

    let open_ports = batch_scan(ports, udp_batch_size, cancel, |port| async move {
        let result = match port {
            53 => test_dns_service(ip).await,
            123 => test_ntp_service(ip).await,
            161 => test_snmp_service(ip).await,
            67 => test_dhcp_service(ip).await,
            _ => Ok(None),
        };

        match result {
            Ok(Some(detected_port)) => {
                tracing::debug!("Found open UDP port {}:{}", ip, detected_port);
                Some(PortBase::new_udp(detected_port))
            }
            Ok(None) => None,
            Err(e) => {
                if DiscoveryCriticalError::is_critical_error(e.to_string()) {
                    tracing::error!("Critical error scanning UDP {}:{}: {}", ip, port, e);
                }
                None
            }
        }
    })
    .await;

    Ok(open_ports)
}

pub async fn scan_endpoints(
    ip: IpAddr,
    cancel: CancellationToken,
    filter_ports: Option<Vec<PortBase>>,
    batch_size: usize,
) -> Result<Vec<EndpointResponse>, Error> {
    use std::collections::HashMap;

    let client = reqwest::Client::builder()
        .timeout(SCAN_TIMEOUT)
        .build()
        .map_err(|e| anyhow!("Could not build client {}", e))?;

    let all_endpoints: Vec<Endpoint> = Service::all_discovery_endpoints()
        .into_iter()
        .filter_map(|e| {
            if let Some(filter_ports) = &filter_ports {
                if filter_ports.contains(&e.port_base) {
                    return Some(e);
                }
                None
            } else {
                Some(e)
            }
        })
        .collect();

    // Group endpoints by (port, path) to avoid duplicate requests
    let mut unique_endpoints: HashMap<(u16, String), Endpoint> = HashMap::new();
    for endpoint in all_endpoints {
        let key = (endpoint.port_base.number(), endpoint.path.clone());
        unique_endpoints.entry(key).or_insert(endpoint);
    }

    let endpoints: Vec<Endpoint> = unique_endpoints.into_values().collect();
    let total_endpoints = endpoints.len();

    // Endpoints are slower (HTTP requests), use smaller batch
    let endpoint_batch_size = std::cmp::min(batch_size / 2, 50);

    tracing::debug!(
        "Scanning {} unique endpoints on {} with batch size {}",
        total_endpoints,
        ip,
        endpoint_batch_size
    );

    let responses = batch_scan(endpoints, endpoint_batch_size, cancel, |endpoint| {
        let client = client.clone();
        async move {
            let endpoint_with_ip = endpoint.use_ip(ip);
            let url = endpoint_with_ip.to_string();

            match client.get(&url).send().await {
                Ok(response) if response.status().is_success() => match response.text().await {
                    Ok(text) => Some(EndpointResponse {
                        endpoint: endpoint_with_ip,
                        response: text,
                    }),
                    Err(_) => None,
                },
                Ok(_) => None,
                Err(e) => {
                    if DiscoveryCriticalError::is_critical_error(e.to_string()) {
                        tracing::error!("Critical error scanning endpoint {}: {}", url, e);
                    }
                    None
                }
            }
        }
    })
    .await;

    Ok(responses)
}

pub async fn test_dns_service(ip: IpAddr) -> Result<Option<u16>, Error> {
    // Use the simpler approach - create resolver with custom config directly
    let mut config = ResolverConfig::new();
    let name_server = NameServerConfig::new(SocketAddr::new(ip, 53), Protocol::Udp);
    config.add_name_server(name_server);

    let test_resolver = TokioAsyncResolver::tokio(config, ResolverOpts::default());

    match timeout(
        Duration::from_millis(2000),
        test_resolver.lookup_ip("google.com"),
    )
    .await
    {
        Ok(Ok(_)) => {
            tracing::debug!("DNS server responding at {}:53", ip);
            Ok(Some(53))
        }
        _ => {
            tracing::debug!("DNS server not responding at {}:53", ip);
            Ok(None)
        }
    }
}

pub async fn test_ntp_service(ip: IpAddr) -> Result<Option<u16>, Error> {
    let client = AsyncSntpClient::new();
    let server_addr = format!("{}:123", ip);

    match timeout(
        Duration::from_millis(2000),
        client.synchronize(&server_addr),
    )
    .await
    {
        Ok(Ok(result)) => {
            // Validate that we got a meaningful time response
            if let Ok(datetime) = result.datetime().unix_timestamp() {
                if datetime > Duration::from_secs(0) {
                    // Sanity check for valid timestamp
                    tracing::debug!(
                        "NTP server responding at {}:123 with time {}",
                        ip,
                        datetime.as_millis()
                    );
                    Ok(Some(123))
                } else {
                    tracing::debug!("Invalid NTP response from {}:123", ip);
                    Ok(None)
                }
            } else {
                tracing::debug!("Invalid NTP response from {}:123", ip);
                Ok(None)
            }
        }
        Ok(Err(e)) => {
            tracing::debug!("NTP error from {}:123 - {}", ip, e);
            Ok(None)
        }
        Err(_) => {
            tracing::debug!("NTP timeout from {}:123", ip);
            Ok(None)
        }
    }
}

pub async fn test_snmp_service(ip: IpAddr) -> Result<Option<u16>, Error> {
    let target = format!("{}:161", ip);
    let community = b"public";

    match AsyncSession::new_v2c(&target, community, 0).await {
        Ok(mut session) => {
            let sys_descr_oid = Oid::from(&[1, 3, 6, 1, 2, 1, 1, 1, 0])
                .map_err(|e| anyhow!("Invalid Oid: {:?}", e))?;

            match timeout(Duration::from_millis(2000), session.get(&sys_descr_oid)).await {
                Ok(Ok(mut response)) => {
                    if let Some(_varbind) = response.varbinds.next() {
                        tracing::debug!("SNMP server responding at {}:161", ip);
                        Ok(Some(161))
                    } else {
                        tracing::debug!("Empty SNMP response from {}:161", ip);
                        Ok(None)
                    }
                }
                Ok(Err(e)) => {
                    tracing::debug!("SNMP error from {}:161 - {}", ip, e);
                    Ok(None)
                }
                Err(_) => {
                    tracing::debug!("SNMP timeout from {}:161", ip);
                    Ok(None)
                }
            }
        }
        Err(e) => {
            tracing::debug!("SNMP session creation failed for {}:161 - {}", ip, e);
            Ok(None)
        }
    }
}

/// Test if a host is running a DHCP server on port 67
pub async fn test_dhcp_service(ip: IpAddr) -> Result<Option<u16>, Error> {
    let socket = UdpSocket::bind("0.0.0.0:0").await?;
    let target = SocketAddr::new(ip, 67);

    // Create a minimal DHCP DISCOVER message
    let mut rng = rand::rngs::StdRng::from_os_rng();
    let mac_addr: [u8; 6] = rng.random();
    let transaction_id = rng.random::<u32>();

    let mut msg = Message::default();
    msg.set_opcode(v4::Opcode::BootRequest)
        .set_htype(v4::HType::Eth)
        .set_xid(transaction_id)
        .set_flags(v4::Flags::default().set_broadcast())
        .set_chaddr(&mac_addr);

    msg.opts_mut()
        .insert(v4::DhcpOption::MessageType(MessageType::Discover));

    // Encode and send DHCP DISCOVER packet
    let mut buf = Vec::new();
    let mut encoder = Encoder::new(&mut buf);
    msg.encode(&mut encoder)?;
    socket.send_to(&buf, target).await?;

    // Wait for DHCP OFFER response
    let mut response_buf = [0u8; 1500];
    match timeout(
        Duration::from_millis(2000),
        socket.recv_from(&mut response_buf),
    )
    .await
    {
        Ok(Ok((len, _))) if len > 0 => {
            // Try to parse as DHCP message and validate response type
            match Message::decode(&mut dhcproto::Decoder::new(&response_buf[..len])) {
                Ok(response_msg) => {
                    let is_valid_response = response_msg.opts().iter().any(|(_, opt)| {
                        matches!(
                            opt,
                            v4::DhcpOption::MessageType(MessageType::Offer)
                                | v4::DhcpOption::MessageType(MessageType::Ack)
                        )
                    });

                    if is_valid_response {
                        tracing::debug!("DHCP server responding at {}:67", ip);
                        Ok(Some(67))
                    } else {
                        tracing::debug!("Invalid DHCP response from {}:67", ip);
                        Ok(None)
                    }
                }
                Err(_) => {
                    tracing::debug!("Failed to parse DHCP response from {}:67", ip);
                    Ok(None)
                }
            }
        }
        _ => {
            tracing::debug!("DHCP timeout from {}:67", ip);
            Ok(None)
        }
    }
}
