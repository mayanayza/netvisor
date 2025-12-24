import { derived, get, writable, type Readable } from 'svelte/store';
import type {
	AllInterfaces,
	CreateHostRequest,
	CreateInterfaceInput,
	CreatePortInput,
	Host,
	HostWithServicesRequest,
	Interface,
	Port,
	UpdateHostRequest
} from './types/base';
import { api } from '../../shared/utils/api';
import { pushSuccess } from '$lib/shared/stores/feedback';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';
import { isContainerSubnet } from '../subnets/store';
import { networks } from '../networks/store';
import { bulkUpdateServices, createService, deleteService } from '../services/store';
import type { Service } from '$lib/generated';

export const hosts = writable<Host[]>([]);
export const polling = writable(false);

export async function getHosts() {
	return await api.request<Host[]>(`/hosts`, hosts, (hosts) => hosts, { method: 'GET' });
}

/**
 * Transform Host form data to CreateHostRequest format for API
 */
function toCreateHostRequest(host: Host): CreateHostRequest {
	return {
		name: host.name,
		network_id: host.network_id,
		hostname: host.hostname,
		description: host.description,
		virtualization: host.virtualization,
		hidden: host.hidden,
		tags: host.tags,
		interfaces: host.interfaces.map(
			(iface): CreateInterfaceInput => ({
				subnet_id: iface.subnet_id,
				ip_address: iface.ip_address,
				mac_address: iface.mac_address,
				name: iface.name
			})
		),
		ports: host.ports.map(
			(port): CreatePortInput => ({
				number: port.number,
				protocol: port.protocol
			})
		)
	};
}

/**
 * Transform Host form data to UpdateHostRequest format for API
 */
function toUpdateHostRequest(host: Host): UpdateHostRequest {
	return {
		id: host.id,
		name: host.name,
		hostname: host.hostname,
		description: host.description,
		virtualization: host.virtualization,
		hidden: host.hidden,
		tags: host.tags
	};
}

export async function createHost(data: HostWithServicesRequest) {
	const request = toCreateHostRequest(data.host);

	const result = await api.request<Host, Host[]>(
		'/hosts',
		hosts,
		(createdHost, current) => [...current, createdHost],
		{ method: 'POST', body: JSON.stringify(request) }
	);

	return result;
}

export async function updateHost(data: HostWithServicesRequest) {
	const request = toUpdateHostRequest(data.host);

	const result = await api.request<Host, Host[]>(
		`/hosts/${data.host.id}`,
		hosts,
		(updatedHost, current) => {
			return current.map((n) => (n.id === data.host.id ? updatedHost : n));
		},
		{ method: 'PUT', body: JSON.stringify(request) }
	);

	// Handle service updates if services are provided
	if (data.services !== null && result?.success) {
		await bulkUpdateServices(data.host.id, data.services);
	}

	return result;
}

export async function deleteHost(id: string) {
	return await api.request<void, Host[]>(
		`/hosts/${id}`,
		hosts,
		(_, current) => current.filter((g) => g.id !== id),
		{ method: 'DELETE' }
	);
}

export async function bulkDeleteHosts(ids: string[]) {
	const result = await api.request<void, Host[]>(
		`/hosts/bulk-delete`,
		hosts,
		(_, current) => current.filter((k) => !ids.includes(k.id)),
		{ method: 'POST', body: JSON.stringify(ids) }
	);

	return result;
}

export async function consolidateHosts(destination_host_id: string, other_host_id: string) {
	const other_host_name = get(getHostFromId(other_host_id))?.name;

	return await api.request<Host, Host[]>(
		`/hosts/${destination_host_id}/consolidate/${other_host_id}`,
		hosts,
		(updatedHost, current) => {
			current = current.filter((g) => g.id !== other_host_id);
			pushSuccess(`Consolidated host "${other_host_name}" into host "${updatedHost.name}"`);
			return current.map((h) => (h.id == destination_host_id ? updatedHost : h));
		},
		{ method: 'PUT' }
	);
}

export function createEmptyHostFormData(): Host {
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
		? i.name ?? i.ip_address
		: (i.name ? i.name + ': ' : '') + i.ip_address;
}

export function getHostFromId(id: string): Readable<Host | null> {
	return derived([hosts], ([$hosts]) => {
		return $hosts.find((h) => h.id == id) || null;
	});
}

export function getHostFromInterfaceId(interface_id: string): Readable<Host | null> {
	return derived([hosts], ([$hosts]) => {
		return $hosts.find((h) => h.interfaces.some((i) => i.id == interface_id)) || null;
	});
}

export function getInterfaceFromId(id: string): Readable<Interface | null> {
	return derived([hosts], ([$hosts]) => {
		for (const host of $hosts) {
			const iface = host.interfaces.find((i) => i.id == id);
			if (iface) {
				return iface;
			}
		}
		return null;
	});
}

export function getPortFromId(id: string): Readable<Port | null> {
	return derived([hosts], ([$hosts]) => {
		for (const host of $hosts) {
			const port = host.ports.find((i) => i.id == id);
			if (port) {
				return port;
			}
		}
		return null;
	});
}
