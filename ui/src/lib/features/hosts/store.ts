import { derived, get, writable, type Readable } from 'svelte/store';
import type {
	AllInterfaces,
	CreateHostRequest,
	CreateHostWithServicesRequest,
	CreateInterfaceInput,
	CreatePortInput,
	Host,
	HostFormData,
	HostResponse,
	Interface,
	Port,
	UpdateHostRequest,
	UpdateHostWithServicesRequest,
	UpdateInterfaceInput,
	UpdatePortInput
} from './types/base';
import { apiClient, type ApiResponse } from '$lib/api/client';
import { pushSuccess } from '$lib/shared/stores/feedback';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting'; // uuidv4Sentinel still used in createEmptyHostFormData
import { isContainerSubnet } from '../subnets/store';
import { networks } from '../networks/store';
import { bulkUpdateServices, services } from '../services/store';
import {
	interfaces,
	syncInterfaces,
	syncInterfacesForHost,
	removeInterfacesForHost
} from '../interfaces/store';
import { ports, syncPorts, syncPortsForHost, removePortsForHost } from '../ports/store';

// Store for host primitives (without embedded children)
export const hosts = writable<Host[]>([]);
export const polling = writable(false);

/**
 * Extract Host primitive from HostResponse (removes embedded children)
 */
export function toHostPrimitive(response: HostResponse): Host {
	return {
		id: response.id,
		created_at: response.created_at,
		updated_at: response.updated_at,
		name: response.name,
		network_id: response.network_id,
		hostname: response.hostname ?? null,
		description: response.description ?? null,
		source: response.source,
		virtualization: response.virtualization ?? null,
		hidden: response.hidden,
		tags: response.tags
	};
}

/**
 * Extract Host primitive from HostFormData (removes embedded children)
 */
export function formDataToHostPrimitive(formData: HostFormData): Host {
	return {
		id: formData.id,
		created_at: formData.created_at,
		updated_at: formData.updated_at,
		name: formData.name,
		network_id: formData.network_id,
		hostname: formData.hostname,
		description: formData.description,
		source: formData.source,
		virtualization: formData.virtualization,
		hidden: formData.hidden,
		tags: formData.tags
	};
}

/**
 * Sync all child entities from HostResponse data to their stores
 */
function syncChildrenFromResponse(response: HostResponse) {
	syncInterfacesForHost(response.id, response.interfaces);
	syncPortsForHost(response.id, response.ports);
	// Services are synced via services.update to handle ordering
	services.update((current) => {
		const other = current.filter((s) => s.host_id !== response.id);
		return [...other, ...response.services];
	});
}

/**
 * Sync all child entities from multiple HostResponse objects
 */
function syncChildrenFromResponses(responses: HostResponse[]) {
	const allInterfaces = responses.flatMap((r) => r.interfaces);
	const allPorts = responses.flatMap((r) => r.ports);
	const allServices = responses.flatMap((r) => r.services);

	syncInterfaces(allInterfaces);
	syncPorts(allPorts);
	services.set(allServices);
}

export async function getHosts() {
	const { data } = await apiClient.GET('/api/hosts');
	if (data?.success && data.data) {
		// Store host primitives
		hosts.set(data.data.map(toHostPrimitive));
		// Sync children to their stores
		syncChildrenFromResponses(data.data);
	}
	return data as ApiResponse<HostResponse[]>;
}

/**
 * Transform HostFormData to CreateHostRequest format for API
 */
function toCreateHostRequest(formData: HostFormData): CreateHostRequest {
	return {
		name: formData.name,
		network_id: formData.network_id,
		hostname: formData.hostname,
		description: formData.description,
		virtualization: formData.virtualization,
		hidden: formData.hidden,
		tags: formData.tags,
		interfaces: formData.interfaces.map(
			(iface): CreateInterfaceInput => ({
				subnet_id: iface.subnet_id,
				ip_address: iface.ip_address,
				mac_address: iface.mac_address,
				name: iface.name
			})
		),
		ports: formData.ports.map(
			(port): CreatePortInput => ({
				number: port.number,
				protocol: port.protocol
			})
		)
	};
}

/**
 * Transform host and optional children to UpdateHostRequest format for API.
 * Uses global stores to determine if an interface/port is new (not yet saved).
 * Includes expected_updated_at for optimistic locking to detect concurrent modifications.
 */
function toUpdateHostRequest(
	host: Host,
	formInterfaces: Interface[] | null,
	formPorts: Port[] | null
): UpdateHostRequest {
	// Get current saved interfaces/ports from stores to detect new items
	const savedInterfaceIds = new Set(get(interfaces).map((i) => i.id));
	const savedPortIds = new Set(get(ports).map((p) => p.id));

	return {
		id: host.id,
		name: host.name,
		hostname: host.hostname,
		description: host.description,
		virtualization: host.virtualization,
		hidden: host.hidden,
		tags: host.tags,
		// Include expected_updated_at for optimistic locking
		// If the host was modified since we loaded it (e.g., by discovery), the server will reject
		expected_updated_at: host.updated_at,
		// Convert interfaces to input format if provided
		// New interfaces (not in store) get id: null so server creates them
		interfaces: formInterfaces
			? formInterfaces.map(
					(iface): UpdateInterfaceInput => ({
						id: savedInterfaceIds.has(iface.id) ? iface.id : null,
						subnet_id: iface.subnet_id,
						ip_address: iface.ip_address,
						mac_address: iface.mac_address,
						name: iface.name
					})
				)
			: null,
		// Convert ports to input format if provided
		// New ports (not in store) get id: null so server creates them
		ports: formPorts
			? formPorts.map(
					(port): UpdatePortInput => ({
						id: savedPortIds.has(port.id) ? port.id : null,
						number: port.number,
						protocol: port.protocol
					})
				)
			: null
	};
}

export async function createHost(data: CreateHostWithServicesRequest) {
	const request = toCreateHostRequest(data.host);

	const { data: result } = await apiClient.POST('/api/hosts', { body: request });
	if (result?.success && result.data) {
		// Store host primitive
		hosts.update((current) => [...current, toHostPrimitive(result.data!)]);
		// Sync children
		syncChildrenFromResponse(result.data);
	}

	return result as ApiResponse<HostResponse>;
}

export async function updateHost(data: UpdateHostWithServicesRequest) {
	const request = toUpdateHostRequest(data.host, data.interfaces, data.ports);

	const { data: result } = await apiClient.PUT('/api/hosts/{id}', {
		params: { path: { id: data.host.id } },
		body: request
	});
	if (result?.success && result.data) {
		// Store host primitive
		hosts.update((current) =>
			current.map((n) => (n.id === data.host.id ? toHostPrimitive(result.data!) : n))
		);
		// Sync children from response (includes newly created interfaces/ports with real IDs)
		syncChildrenFromResponse(result.data);
	}

	// Handle service updates if services are provided
	if (data.services !== null && result?.success) {
		await bulkUpdateServices(data.host.id, data.services);
	}

	return result as ApiResponse<HostResponse>;
}

export async function deleteHost(id: string) {
	const { data: result } = await apiClient.DELETE('/api/hosts/{id}', {
		params: { path: { id } }
	});
	if (result?.success) {
		hosts.update((current) => current.filter((g) => g.id !== id));
		// Remove children from their stores
		removeInterfacesForHost(id);
		removePortsForHost(id);
		services.update((current) => current.filter((s) => s.host_id !== id));
	}
	return result;
}

export async function bulkDeleteHosts(ids: string[]) {
	const { data: result } = await apiClient.POST('/api/hosts/bulk-delete', {
		body: ids
	});
	if (result?.success) {
		hosts.update((current) => current.filter((k) => !ids.includes(k.id)));
		// Remove children from their stores
		for (const id of ids) {
			removeInterfacesForHost(id);
			removePortsForHost(id);
		}
		services.update((current) => current.filter((s) => !ids.includes(s.host_id)));
	}
	return result;
}

export async function consolidateHosts(destination_host_id: string, other_host_id: string) {
	const other_host_name = get(getHostFromId(other_host_id))?.name;

	const { data: result } = await apiClient.PUT(
		'/api/hosts/{destination_host}/consolidate/{other_host}',
		{
			params: { path: { destination_host: destination_host_id, other_host: other_host_id } }
		}
	);
	if (result?.success && result.data) {
		// Remove the consolidated host
		hosts.update((current) => {
			current = current.filter((g) => g.id !== other_host_id);
			pushSuccess(`Consolidated host "${other_host_name}" into host "${result.data!.name}"`);
			return current.map((h) => (h.id == destination_host_id ? toHostPrimitive(result.data!) : h));
		});
		// Remove children of consolidated host
		removeInterfacesForHost(other_host_id);
		removePortsForHost(other_host_id);
		services.update((current) => current.filter((s) => s.host_id !== other_host_id));
		// Sync updated destination host children
		syncChildrenFromResponse(result.data);
	}
	return result as ApiResponse<HostResponse>;
}

/**
 * Create empty form data for creating a new host.
 */
export function createEmptyHostFormData(): HostFormData {
	return {
		id: uuidv4Sentinel,
		created_at: utcTimeZoneSentinel,
		updated_at: utcTimeZoneSentinel,
		name: '',
		description: null,
		tags: [],
		hostname: null,
		services: [],
		interfaces: [],
		ports: [],
		source: {
			type: 'Manual'
		},
		virtualization: null,
		network_id: get(networks)[0]?.id || '',
		hidden: false
	};
}

export function formatInterface(i: Interface | AllInterfaces): string {
	if (i.id == null) return i.name;
	return get(isContainerSubnet(i.subnet_id))
		? (i.name ?? i.ip_address)
		: (i.name ? i.name + ': ' : '') + i.ip_address;
}

export function getHostFromId(id: string): Readable<Host | null> {
	return derived([hosts], ([$hosts]) => {
		return $hosts.find((h) => h.id == id) || null;
	});
}

export function getHostFromInterfaceId(interface_id: string): Readable<Host | null> {
	return derived([hosts, interfaces], ([$hosts, $interfaces]) => {
		const iface = $interfaces.find((i) => i.id === interface_id);
		if (!iface) return null;
		return $hosts.find((h) => h.id === iface.host_id) || null;
	});
}

// Note: getInterfaceFromId and getPortFromId have been moved to their respective stores:
// - getInterfaceFromId: import from '$lib/features/interfaces/store'
// - getPortFromId: import from '$lib/features/ports/store'

/**
 * Hydrate a Host primitive to HostFormData by looking up children from stores.
 * Used for form editing where the full form structure is needed.
 */
export function hydrateHostToFormData(host: Host): HostFormData {
	const hostInterfaces = get(interfaces).filter((i) => i.host_id === host.id);
	const hostPorts = get(ports).filter((p) => p.host_id === host.id);
	const hostServices = get(services).filter((s) => s.host_id === host.id);

	return {
		...host,
		interfaces: hostInterfaces,
		ports: hostPorts,
		services: hostServices
	};
}
